import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../services/api_exception.dart';
import '../services/token_service.dart';

/// Low-level HTTP client.
///
/// Uses [TokenService] for token storage — never reads SharedPreferences
/// directly.  All callers go through this class; never call http directly.
class ApiService {
  final TokenService _tokenService = TokenService();
  bool _isRefreshing = false;

  /// Global callback triggered when session refresh fails and user must be logged out.
  static VoidCallback? onSessionExpired;

  Future<Map<String, String>> _headers() async {
    final token = await _tokenService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<bool> _refreshSession() async {
    if (_isRefreshing) return false;
    _isRefreshing = true;
    try {
      final refreshToken = await _tokenService.getRefreshToken();
      if (refreshToken == null) {
        _isRefreshing = false;
        await _tokenService.removeTokens();
        onSessionExpired?.call();
        return false;
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final data = decoded['data'];
          final newAccess = data['accessToken'] as String?;
          if (newAccess != null) {
            await _tokenService.saveToken(newAccess);
            _isRefreshing = false;
            return true;
          }
        }
      }
    } catch (_) {
      // Ignore
    }
    _isRefreshing = false;
    await _tokenService.removeTokens();
    onSessionExpired?.call();
    return false;
  }

  bool _isTokenError(http.Response response) {
    if (response.statusCode == 401) return true;
    if (response.statusCode == 500) {
      try {
        final data = jsonDecode(response.body);
        final msg = data['message']?.toString().toLowerCase() ?? '';
        if (msg.contains('jwt') || msg.contains('token') || msg.contains('unauthorized')) {
          return true;
        }
      } catch (_) {}
    }
    return false;
  }

  // ─── GET ──────────────────────────────────────────────────────────────────

  Future<dynamic> get(String endpoint) async {
    var response = await http.get(
      Uri.parse(ApiConstants.baseUrl + endpoint),
      headers: await _headers(),
    );
    if (_isTokenError(response)) {
      final success = await _refreshSession();
      if (success) {
        response = await http.get(
          Uri.parse(ApiConstants.baseUrl + endpoint),
          headers: await _headers(),
        );
      }
    }
    return _processResponse(response);
  }

  // ─── POST ─────────────────────────────────────────────────────────────────

  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    var response = await http.post(
      Uri.parse(ApiConstants.baseUrl + endpoint),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    if (_isTokenError(response)) {
      final success = await _refreshSession();
      if (success) {
        response = await http.post(
          Uri.parse(ApiConstants.baseUrl + endpoint),
          headers: await _headers(),
          body: jsonEncode(body),
        );
      }
    }
    return _processResponse(response);
  }

  // ─── PATCH ────────────────────────────────────────────────────────────────

  Future<dynamic> patch(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    var response = await http.patch(
      Uri.parse(ApiConstants.baseUrl + endpoint),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    if (_isTokenError(response)) {
      final success = await _refreshSession();
      if (success) {
        response = await http.patch(
          Uri.parse(ApiConstants.baseUrl + endpoint),
          headers: await _headers(),
          body: jsonEncode(body),
        );
      }
    }
    return _processResponse(response);
  }

  // ─── PUT ──────────────────────────────────────────────────────────────────

  Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    var response = await http.put(
      Uri.parse(ApiConstants.baseUrl + endpoint),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    if (_isTokenError(response)) {
      final success = await _refreshSession();
      if (success) {
        response = await http.put(
          Uri.parse(ApiConstants.baseUrl + endpoint),
          headers: await _headers(),
          body: jsonEncode(body),
        );
      }
    }
    return _processResponse(response);
  }

  // ─── DELETE ───────────────────────────────────────────────────────────────

  Future<dynamic> delete(String endpoint) async {
    var response = await http.delete(
      Uri.parse(ApiConstants.baseUrl + endpoint),
      headers: await _headers(),
    );
    if (_isTokenError(response)) {
      final success = await _refreshSession();
      if (success) {
        response = await http.delete(
          Uri.parse(ApiConstants.baseUrl + endpoint),
          headers: await _headers(),
        );
      }
    }
    return _processResponse(response);
  }

  // ─── MULTIPART POST ───────────────────────────────────────────────────────

  Future<dynamic> postMultipart(
    String endpoint,
    Map<String, String> fields, {
    List<String>? imagePaths,
    String fileFieldName = 'images',
  }) async {
    final token = await _tokenService.getToken();
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConstants.baseUrl + endpoint),
    );
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['Accept'] = 'application/json';
    request.fields.addAll(fields);

    if (imagePaths != null && imagePaths.isNotEmpty) {
      for (final path in imagePaths) {
        request.files.add(await http.MultipartFile.fromPath(fileFieldName, path));
      }
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (_isTokenError(response)) {
      final success = await _refreshSession();
      if (success) {
        final newToken = await _tokenService.getToken();
        var retryReq = http.MultipartRequest(
          'POST',
          Uri.parse(ApiConstants.baseUrl + endpoint),
        );
        if (newToken != null) {
          retryReq.headers['Authorization'] = 'Bearer $newToken';
        }
        retryReq.headers['Accept'] = 'application/json';
        retryReq.fields.addAll(fields);
        if (imagePaths != null && imagePaths.isNotEmpty) {
          for (final path in imagePaths) {
            retryReq.files.add(await http.MultipartFile.fromPath(fileFieldName, path));
          }
        }
        var retryStreamed = await retryReq.send();
        response = await http.Response.fromStream(retryStreamed);
      }
    }
    return _processResponse(response);
  }

  // ─── MULTIPART PUT ────────────────────────────────────────────────────────

  Future<dynamic> putMultipart(
    String endpoint,
    Map<String, String> fields, {
    List<String>? imagePaths,
    String fileFieldName = 'images',
  }) async {
    final token = await _tokenService.getToken();
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse(ApiConstants.baseUrl + endpoint),
    );
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['Accept'] = 'application/json';
    request.fields.addAll(fields);

    if (imagePaths != null && imagePaths.isNotEmpty) {
      for (final path in imagePaths) {
        request.files.add(await http.MultipartFile.fromPath(fileFieldName, path));
      }
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (_isTokenError(response)) {
      final success = await _refreshSession();
      if (success) {
        final newToken = await _tokenService.getToken();
        var retryReq = http.MultipartRequest(
          'PUT',
          Uri.parse(ApiConstants.baseUrl + endpoint),
        );
        if (newToken != null) {
          retryReq.headers['Authorization'] = 'Bearer $newToken';
        }
        retryReq.headers['Accept'] = 'application/json';
        retryReq.fields.addAll(fields);
        if (imagePaths != null && imagePaths.isNotEmpty) {
          for (final path in imagePaths) {
            retryReq.files.add(await http.MultipartFile.fromPath(fileFieldName, path));
          }
        }
        var retryStreamed = await retryReq.send();
        response = await http.Response.fromStream(retryStreamed);
      }
    }
    return _processResponse(response);
  }

  // ─── Response processor ───────────────────────────────────────────────────

  dynamic _processResponse(http.Response response) {
    final contentType = response.headers['content-type'] ?? '';
    final isJson = contentType.contains('application/json');

    if (!isJson) {
      final bodyText = response.body.trim();
      if (contentType.contains('text/html') ||
          bodyText.startsWith('<!DOCTYPE html>') ||
          bodyText.startsWith('<html')) {
        throw ApiException(
          message: 'Server returned HTML instead of JSON. Check API endpoint.',
          statusCode: response.statusCode,
        );
      }
      throw ApiException(
        message: 'Server returned unexpected content: $contentType',
        statusCode: response.statusCode,
      );
    }

    final data = jsonDecode(response.body);

    switch (response.statusCode) {
      case 200:
      case 201:
        return data;

      case 400:
        throw ApiException(
          message: data['message'] ?? 'Bad Request',
          statusCode: 400,
        );

      case 401:
        throw ApiException(
          message: 'Session Expired. Please log in again.',
          statusCode: 401,
        );

      case 403:
        throw ApiException(
          message: 'Forbidden',
          statusCode: 403,
        );

      case 404:
        throw ApiException(
          message: 'Not Found',
          statusCode: 404,
        );

      case 500:
        final msg = data['message']?.toString().toLowerCase() ?? '';
        if (msg.contains('jwt') || msg.contains('token') || msg.contains('unauthorized')) {
          throw ApiException(
            message: 'Session Expired. Please log in again.',
            statusCode: 401,
          );
        }
        throw ApiException(
          message: data['message'] ?? 'Internal Server Error',
          statusCode: 500,
        );

      default:
        throw ApiException(
          message: data['message'] ?? 'Something went wrong',
          statusCode: response.statusCode,
        );
    }
  }
}
