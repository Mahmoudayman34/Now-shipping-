import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:now_shipping/config/env.dart';
import 'package:now_shipping/core/exceptions/api_exception.dart';

class ApiService {
  final http.Client _client;
  final String _baseUrl;
  
  ApiService({
    http.Client? client,
    String? baseUrl,
  }) : 
    _client = client ?? http.Client(),
    _baseUrl = baseUrl ?? AppConfig.apiBaseUrl;
  
  Map<String, String> _getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      // Using Bearer token format as required
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
  
  Future<dynamic> get(
    String endpoint, {
    String? token,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint').replace(
        queryParameters: queryParams,
      );
      
      print('DEBUG API: GET request to $uri');
      print('DEBUG API: Headers: ${_getHeaders(token: token)}');
      
      final response = await _client.get(
        uri,
        headers: _getHeaders(token: token),
      ).timeout(const Duration(seconds: 30));
      
      print('DEBUG API: Response status code: ${response.statusCode}');
      print('DEBUG API: Response body starts with: ${response.body.length > 100 ? "${response.body.substring(0, 100)}..." : response.body}');
      
      return _handleResponse(response);
    } on SocketException {
      print('DEBUG API: SocketException - No internet connection');
      throw ApiException(message: 'No internet connection');
    } on HttpException {
      print('DEBUG API: HttpException - HTTP error occurred');
      throw ApiException(message: 'HTTP error occurred');
    } on FormatException {
      print('DEBUG API: FormatException - Invalid response format');
      throw ApiException(message: 'Invalid response format');
    } catch (e) {
      print('DEBUG API: Unknown error: $e');
      throw ApiException(message: 'Unknown error: $e');
    }
  }
  
  Future<dynamic> post(
    String endpoint, {
    required dynamic body,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      
      print('DEBUG API: POST request to $uri');
      print('DEBUG API: Headers: ${_getHeaders(token: token)}');
      print('DEBUG API: Request body: ${json.encode(body)}');
      
      final response = await _client.post(
        uri,
        headers: _getHeaders(token: token),
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));
      
      print('DEBUG API: Response status code: ${response.statusCode}');
      print('DEBUG API: Response body: ${response.body}');
      
      return _handleResponse(response);
    } on SocketException {
      print('DEBUG API: SocketException - No internet connection');
      throw ApiException(message: 'No internet connection');
    } on HttpException {
      print('DEBUG API: HttpException - HTTP error occurred');
      throw ApiException(message: 'HTTP error occurred');
    } on FormatException {
      print('DEBUG API: FormatException - Invalid response format');
      throw ApiException(message: 'Invalid response format');
    } catch (e) {
      print('DEBUG API: Unknown error in POST request: $e');
      throw ApiException(message: 'Unknown error: $e');
    }
  }
  
  Future<dynamic> put(
    String endpoint, {
    required dynamic body,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      
      final response = await _client.put(
        uri,
        headers: _getHeaders(token: token),
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));
      
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection');
    } on HttpException {
      throw ApiException(message: 'HTTP error occurred');
    } on FormatException {
      throw ApiException(message: 'Invalid response format');
    } catch (e) {
      throw ApiException(message: 'Unknown error: $e');
    }
  }
  
  Future<dynamic> delete(
    String endpoint, {
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      
      final response = await _client.delete(
        uri,
        headers: _getHeaders(token: token),
      ).timeout(const Duration(seconds: 30));
      
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection');
    } on HttpException {
      throw ApiException(message: 'HTTP error occurred');
    } on FormatException {
      throw ApiException(message: 'Invalid response format');
    } catch (e) {
      throw ApiException(message: 'Unknown error: $e');
    }
  }
  
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        print('DEBUG API: Response body is empty, returning null');
        return null;
      }
      
      // Check if response is a binary file (Excel, PDF, etc.)
      final contentType = response.headers['content-type'] ?? '';
      if (contentType.contains('application/vnd.openxmlformats-officedocument') ||
          contentType.contains('application/octet-stream') ||
          contentType.contains('application/pdf') ||
          response.body.startsWith('PK') || // ZIP/Excel file signature
          response.body.startsWith('%PDF')) { // PDF file signature
        print('DEBUG API: Binary file response detected, returning raw bytes');
        return {
          'type': 'binary',
          'data': response.bodyBytes,
          'contentType': contentType,
          'filename': _extractFilename(response.headers),
        };
      }
      
      try {
        final decoded = json.decode(response.body);
        print('DEBUG API: Successfully decoded JSON, type: ${decoded.runtimeType}');
        return decoded;
      } catch (e) {
        print('DEBUG API: Error decoding JSON: $e');
        throw ApiException(message: 'Invalid JSON response: $e');
      }
    } else {
      print('DEBUG API: Request failed with status: ${response.statusCode}');
      print('DEBUG API: Error response: ${response.body}');
      throw ApiException(
        message: 'Request failed with status: ${response.statusCode}',
        statusCode: response.statusCode,
        response: response.body,
      );
    }
  }

  String? _extractFilename(Map<String, String> headers) {
    final contentDisposition = headers['content-disposition'];
    if (contentDisposition != null) {
      // Try to extract filename from Content-Disposition header
      // Format: attachment; filename="filename.xlsx" or attachment; filename=filename.xlsx
      final filenameMatch = RegExp(r'filename[^;=\n]*=([^;\n]*)').firstMatch(contentDisposition);
      if (filenameMatch != null) {
        String filename = filenameMatch.group(1) ?? '';
        // Remove quotes if present
        filename = filename.replaceAll('"', '').replaceAll("'", '').trim();
        if (filename.isNotEmpty) {
          return filename;
        }
      }
    }
    return 'export.xlsx'; // Default filename
  }
}
