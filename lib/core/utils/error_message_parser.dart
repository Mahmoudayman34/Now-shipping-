import 'dart:convert';
import '../exceptions/api_exception.dart';

/// Utility class to parse and convert technical error messages to user-friendly messages
class ErrorMessageParser {
  /// Converts a technical error message to a user-friendly message
  static String parseError(dynamic error) {
    if (error == null) {
      return 'An unexpected error occurred. Please try again.';
    }

    String errorString = error.toString();

    // Handle ApiException
    if (error is ApiException) {
      return _parseApiException(error);
    }

    // Extract the innermost error message by removing nested exception prefixes
    errorString = _extractInnermostError(errorString);

    // Handle common HTTP status codes
    if (errorString.contains('400') || errorString.contains('Bad Request')) {
      return _parse400Error(errorString);
    }

    if (errorString.contains('401') || errorString.contains('Unauthorized')) {
      return 'Your session has expired. Please log in again.';
    }

    if (errorString.contains('403') || errorString.contains('Forbidden')) {
      return 'You do not have permission to perform this action.';
    }

    if (errorString.contains('404') || errorString.contains('Not Found')) {
      return 'The requested resource was not found.';
    }

    if (errorString.contains('500') || errorString.contains('Internal Server Error')) {
      return 'A server error occurred. Please try again later.';
    }

    if (errorString.contains('502') || errorString.contains('Bad Gateway')) {
      return 'Service temporarily unavailable. Please try again later.';
    }

    if (errorString.contains('503') || errorString.contains('Service Unavailable')) {
      return 'Service is temporarily unavailable. Please try again later.';
    }

    // Handle network errors
    if (errorString.contains('No internet connection') || 
        errorString.contains('SocketException') ||
        errorString.contains('Network is unreachable')) {
      return 'No internet connection. Please check your network and try again.';
    }

    // Handle timeout errors
    if (errorString.contains('TimeoutException') || errorString.contains('timeout')) {
      return 'Request timed out. Please check your connection and try again.';
    }

    // Handle authentication errors
    if (errorString.contains('Authentication token not found') ||
        errorString.contains('Unauthorized') ||
        errorString.contains('Invalid token')) {
      return 'Your session has expired. Please log in again.';
    }

    // Handle validation errors
    if (errorString.contains('validation') || errorString.contains('Validation')) {
      return _extractValidationMessage(errorString);
    }

    // Handle specific order creation errors
    if (errorString.contains('Failed to create order')) {
      return _parseOrderCreationError(errorString);
    }

    // Remove technical prefixes
    errorString = _removeTechnicalPrefixes(errorString);

    // If the message is still too technical, provide a generic friendly message
    if (errorString.contains('Exception:') || 
        errorString.contains('ApiException:') ||
        errorString.contains('Status:')) {
      return 'An error occurred while processing your request. Please try again.';
    }

    // Return cleaned up message or default
    return errorString.isNotEmpty ? errorString : 'An unexpected error occurred. Please try again.';
  }

  /// Parse ApiException to extract user-friendly message
  static String _parseApiException(ApiException error) {
    // Try to extract message from response body if available
    if (error.response != null && error.response!.isNotEmpty) {
      try {
        // Try to parse JSON response
        final responseBody = error.response!;
        final message = _extractMessageFromResponse(responseBody);
        if (message != null && message.isNotEmpty) {
          return message;
        }
      } catch (e) {
        // If parsing fails, continue with status code handling
      }
    }

    // Handle by status code
    switch (error.statusCode) {
      case 400:
        return _parse400Error(error.message);
      case 401:
        return 'Your session has expired. Please log in again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 422:
        return 'Please check your input and try again.';
      case 500:
        return 'A server error occurred. Please try again later.';
      case 502:
      case 503:
        return 'Service is temporarily unavailable. Please try again later.';
      default:
        return _removeTechnicalPrefixes(error.message);
    }
  }

  /// Parse 400 Bad Request errors
  static String _parse400Error(String errorString) {
    // Check for specific validation errors
    if (errorString.contains('amountCashCollection') || 
        errorString.contains('Cash Collection amount')) {
      return 'Please enter a valid amount for Cash Collection.';
    }

    if (errorString.contains('customer') || errorString.contains('Customer')) {
      return 'Please provide valid customer information.';
    }

    if (errorString.contains('address') || errorString.contains('Address')) {
      return 'Please provide a valid address.';
    }

    if (errorString.contains('phone') || errorString.contains('Phone')) {
      return 'Please provide a valid phone number.';
    }

    if (errorString.contains('orderType') || errorString.contains('Order Type')) {
      return 'Please select a valid order type.';
    }

    // Generic 400 error
    return 'Invalid information provided. Please check your input and try again.';
  }

  /// Parse order creation specific errors
  static String _parseOrderCreationError(String errorString) {
    // Remove the "Failed to create order:" prefix
    String cleaned = errorString.replaceAll('Failed to create order:', '').trim();
    
    // Remove nested exception prefixes
    cleaned = _extractInnermostError(cleaned);
    
    // Check for specific error patterns
    if (cleaned.contains('amountCashCollection') || cleaned.contains('Cash Collection')) {
      return 'Please enter a valid amount for Cash Collection.';
    }

    if (cleaned.contains('validation') || cleaned.contains('Validation')) {
      return _extractValidationMessage(cleaned);
    }

    // Return cleaned message or default
    cleaned = _removeTechnicalPrefixes(cleaned);
    return cleaned.isNotEmpty 
        ? cleaned 
        : 'Unable to create order. Please check your information and try again.';
  }

  /// Extract validation message from error string
  static String _extractValidationMessage(String errorString) {
    // Try to extract field-specific validation messages
    final patterns = [
      RegExp(r'([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)\s+(?:is|are)\s+(?:required|invalid)', caseSensitive: false),
      RegExp(r'Invalid\s+([a-z\s]+)', caseSensitive: false),
      RegExp(r'([A-Z][a-z]+)\s+field\s+(?:is|are)\s+(?:required|invalid)', caseSensitive: false),
    ];

    for (var pattern in patterns) {
      final match = pattern.firstMatch(errorString);
      if (match != null) {
        return 'Please provide a valid ${match.group(1)?.toLowerCase() ?? 'value'}.';
      }
    }

    return 'Please check your input and try again.';
  }

  /// Extract the innermost error message from nested exceptions
  static String _extractInnermostError(String errorString) {
    // Remove nested "Exception:" prefixes
    String cleaned = errorString;
    
    // Remove all "Exception:" prefixes
    while (cleaned.contains('Exception:')) {
      final index = cleaned.lastIndexOf('Exception:');
      if (index != -1) {
        cleaned = cleaned.substring(index + 'Exception:'.length).trim();
      } else {
        break;
      }
    }

    // Remove "Failed to create order:" prefixes
    while (cleaned.contains('Failed to create order:')) {
      final index = cleaned.lastIndexOf('Failed to create order:');
      if (index != -1) {
        cleaned = cleaned.substring(index + 'Failed to create order:'.length).trim();
      } else {
        break;
      }
    }

    return cleaned;
  }

  /// Remove technical prefixes from error messages
  static String _removeTechnicalPrefixes(String errorString) {
    String cleaned = errorString;
    
    // Remove common technical prefixes
    final prefixes = [
      'ApiException:',
      'Exception:',
      'Failed to create order:',
      'Failed to update order:',
      'Request failed with status:',
      'Status:',
      'Unknown error:',
    ];

    for (var prefix in prefixes) {
      cleaned = cleaned.replaceAll(prefix, '').trim();
    }

    // Remove status code patterns like "(Status: 400)"
    cleaned = cleaned.replaceAll(RegExp(r'\(Status:\s*\d+\)'), '').trim();

    return cleaned;
  }

  /// Extract message from API response body
  static String? _extractMessageFromResponse(dynamic response) {
    if (response is String) {
      try {
        // Try to parse as JSON string first
        try {
          final decoded = json.decode(response);
          if (decoded is Map) {
            return _extractMessageFromMap(decoded);
          }
        } catch (e) {
          // If JSON parsing fails, try regex extraction
        }
        
        // Look for common error message fields using regex
        if (response.contains('"message"')) {
          final match = RegExp(r'"message"\s*:\s*"([^"]+)"').firstMatch(response);
          if (match != null) {
            return match.group(1);
          }
        }
        if (response.contains('"error"')) {
          final match = RegExp(r'"error"\s*:\s*"([^"]+)"').firstMatch(response);
          if (match != null) {
            return match.group(1);
          }
        }
      } catch (e) {
        // If parsing fails, return null
      }
    } else if (response is Map) {
      return _extractMessageFromMap(response);
    }

    return null;
  }

  /// Extract message from a Map response
  static String? _extractMessageFromMap(Map response) {
    // Check for common error message fields
    if (response.containsKey('message')) {
      final message = response['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    if (response.containsKey('error')) {
      final error = response['error'];
      if (error is String && error.isNotEmpty) {
        return error;
      }
    }
    if (response.containsKey('errors')) {
      final errors = response['errors'];
      if (errors is List && errors.isNotEmpty) {
        final firstError = errors.first;
        if (firstError is String) {
          return firstError;
        }
        return firstError.toString();
      }
      if (errors is Map && errors.isNotEmpty) {
        final firstError = errors.values.first;
        if (firstError is String) {
          return firstError;
        }
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
        return firstError.toString();
      }
    }
    return null;
  }
}

