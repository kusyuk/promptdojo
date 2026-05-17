import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../config/watsonx_config.dart';
import '../models/prompt_evaluation.dart';
import '../../core/constants/prompts.dart';
import 'iam_token_service.dart';

/// Service for interacting with IBM watsonx.ai API
///
/// Handles prompt evaluation using the granite-guardian-3-8b model.
/// Includes automatic token management and retry logic.
class WatsonxService {
  final IamTokenService _tokenService = IamTokenService();

  /// Evaluate a user's prompt and return quality score + feedback
  ///
  /// Throws [WatsonxException] if the API call fails after retries
  Future<PromptEvaluation> evaluatePrompt(String userPrompt) async {
    if (userPrompt.trim().isEmpty) {
      throw WatsonxException('User prompt cannot be empty');
    }

    // Validate configuration
    if (!WatsonxConfig.isConfigured) {
      throw WatsonxException(
        'watsonx.ai not configured: ${WatsonxConfig.configStatus}',
      );
    }

    // Try up to 3 times with exponential backoff
    int attempts = 0;
    const maxAttempts = 3;

    while (attempts < maxAttempts) {
      try {
        attempts++;
        return await _makeApiCall(userPrompt);
      } catch (e) {
        if (attempts >= maxAttempts) {
          rethrow;
        }

        // Exponential backoff: 1s, 2s, 4s
        final delay = Duration(seconds: 1 << (attempts - 1));
        await Future.delayed(delay);
      }
    }

    throw WatsonxException('Failed after $maxAttempts attempts');
  }

  /// Make the actual API call to watsonx.ai
  Future<PromptEvaluation> _makeApiCall(String userPrompt) async {
    try {
      // Get IAM token
      final token = await _tokenService.getToken(WatsonxConfig.apiKey);

      // Build request URL
      final url =
          '${WatsonxConfig.endpoint}/ml/v1/text/generation?version=2023-05-29';

      // Build prompt with system instructions
      final fullPrompt = Prompts.buildPrompt(userPrompt);

      debugPrint('watsonx.ai - Sending request to: $url');
      debugPrint('watsonx.ai - Input prompt: $userPrompt');

      // Make API request
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'input': fullPrompt,
              'parameters': {
                'decoding_method': 'greedy',
                'max_new_tokens': 200,
                'temperature': 0.7,
                'stop_sequences': ['}'],
              },
              'model_id': WatsonxConfig.modelId,
              'project_id': WatsonxConfig.projectId,
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw WatsonxException('API request timed out after 30 seconds');
            },
          );

      // Check response status
      debugPrint('watsonx.ai - Response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint('watsonx.ai - Error response: ${response.body}');
        throw WatsonxException(
          'API returned ${response.statusCode}: ${response.body}',
        );
      }

      // Parse response
      final responseData = jsonDecode(response.body);
      final generatedText =
          responseData['results'][0]['generated_text'] as String;
      debugPrint('watsonx.ai - Generated text: $generatedText');

      // Extract JSON from generated text
      // The model should return pure JSON, but we'll handle edge cases
      final jsonText = _extractJson(generatedText);
      final evaluationJson = jsonDecode(jsonText);

      // Create and return evaluation
      return PromptEvaluation.fromJson(evaluationJson);
    } on FormatException catch (e) {
      throw WatsonxException('Failed to parse API response: $e');
    } catch (e) {
      if (e is WatsonxException) rethrow;
      throw WatsonxException('API call failed: $e');
    }
  }

  /// Extract JSON from generated text
  ///
  /// Handles cases where the model might include extra text or markdown
  String _extractJson(String text) {
    // Remove markdown code blocks if present
    text = text.replaceAll('```json', '').replaceAll('```', '');

    // Find JSON object boundaries
    final startIndex = text.indexOf('{');
    final endIndex = text.lastIndexOf('}');

    if (startIndex == -1 || endIndex == -1 || startIndex >= endIndex) {
      throw FormatException('No valid JSON object found in response: $text');
    }

    return text.substring(startIndex, endIndex + 1).trim();
  }

  /// Clear cached IAM token (useful for testing)
  void clearTokenCache() {
    _tokenService.clearToken();
  }

  /// Check if the Watsonx service is available and configured
  ///
  /// Attempts to fetch a token to verify API key validity.
  /// Returns false if the sandbox session has expired or config is missing.
  Future<bool> checkHealth() async {
    try {
      if (!WatsonxConfig.isConfigured) return false;

      // Attempt to get a token
      await _tokenService.getToken(WatsonxConfig.apiKey);
      return true;
    } catch (e) {
      // If token generation fails (e.g. 400 Bad Request due to expired session),
      // the service is considered unavailable.
      return false;
    }
  }
}

/// Exception thrown when watsonx.ai API calls fail
class WatsonxException implements Exception {
  final String message;

  WatsonxException(this.message);

  @override
  String toString() => 'WatsonxException: $message';
}

// Made with Bob
