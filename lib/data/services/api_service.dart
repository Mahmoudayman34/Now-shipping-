import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:tes1/config/env.dart';
import 'package:tes1/core/exceptions/api_exception.dart';

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
      
      final response = await _client.get(
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
  
  Future<dynamic> post(
    String endpoint, {
    required dynamic body,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      
      final response = await _client.post(
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
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    } else {
      throw ApiException(
        message: 'Request failed with status: ${response.statusCode}',
        statusCode: response.statusCode,
        response: response.body,
      );
    }
  }
}
