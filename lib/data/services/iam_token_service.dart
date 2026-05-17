import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../config/watsonx_config.dart';

/// Service for managing IBM Cloud IAM tokens
///
/// Handles token generation, caching, and automatic refresh.
/// Tokens expire after 1 hour, so we cache and refresh as needed.
class IamTokenService {
  String? _cachedToken;
  DateTime? _tokenExpiration;

  /// Get a valid IAM token, using cache if available
  ///
  /// Automatically generates a new token if:
  /// - No token is cached
  /// - Cached token is expired or about to expire (within 5 minutes)
  Future<String> getToken(String apiKey) async {
    // Check if cached token is still valid (with 5 minute buffer)
    if (_cachedToken != null &&
        _tokenExpiration != null &&
        DateTime.now()
            .add(const Duration(minutes: 5))
            .isBefore(_tokenExpiration!)) {
      debugPrint(
        'watsonx.ai - Using cached IAM token (expires in ${timeUntilExpiration?.inMinutes} minutes)',
      );
      return _cachedToken!;
    }

    // Generate new token
    return await _generateToken(apiKey);
  }

  /// Generate a new IAM token from API key
  Future<String> _generateToken(String apiKey) async {
    try {
      debugPrint('watsonx.ai - Requesting new IAM token...');
      final response = await http.post(
        Uri.parse(WatsonxConfig.resolvedIamTokenUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body:
            'grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=$apiKey',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _cachedToken = data['access_token'] as String;

        // Token expires in 1 hour, but we'll refresh 5 minutes early
        final expiresIn = data['expires_in'] as int;
        _tokenExpiration = DateTime.now().add(
          Duration(seconds: expiresIn - 300), // 5 minutes buffer
        );

        debugPrint(
          'watsonx.ai - IAM Token requested successfully (expires in ${expiresIn}s)',
        );
        return _cachedToken!;
      } else {
        debugPrint(
          'watsonx.ai - IAM Token request failed: ${response.statusCode}',
        );
        throw IamTokenException(
          'Failed to generate IAM token: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      if (e is IamTokenException) rethrow;
      throw IamTokenException('Error generating IAM token: $e');
    }
  }

  /// Clear cached token (useful for testing or forcing refresh)
  void clearToken() {
    _cachedToken = null;
    _tokenExpiration = null;
  }

  /// Check if a token is currently cached and valid
  bool get hasValidToken {
    return _cachedToken != null &&
        _tokenExpiration != null &&
        DateTime.now().isBefore(_tokenExpiration!);
  }

  /// Get time until token expiration (null if no token)
  Duration? get timeUntilExpiration {
    if (_tokenExpiration == null) return null;
    return _tokenExpiration!.difference(DateTime.now());
  }
}

/// Exception thrown when IAM token generation fails
class IamTokenException implements Exception {
  final String message;

  IamTokenException(this.message);

  @override
  String toString() => 'IamTokenException: $message';
}

// Made with Bob
