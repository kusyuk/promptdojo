/// Configuration for IBM watsonx.ai API
///
/// Uses Compile-Time Variables (Dart Defines) for security.
/// Pass these via --dart-define when running/building.
class WatsonxConfig {
  /// Project ID from watsonx.ai
  static const String projectId = String.fromEnvironment(
    'WATSONX_PROJECT_ID',
    defaultValue: '',
  );

  /// IBM Cloud API Key
  static const String apiKey = String.fromEnvironment(
    'WATSONX_API_KEY',
    defaultValue: '',
  );

  /// watsonx.ai endpoint (Dallas region)
  static const String endpoint = String.fromEnvironment(
    'WATSONX_ENDPOINT',
    defaultValue: 'https://us-south.ml.cloud.ibm.com',
  );

  /// Model ID to use for prompt evaluation
  static const String modelId = String.fromEnvironment(
    'WATSONX_MODEL_ID',
    defaultValue: 'ibm/granite-8b-code-instruct',
  );

  /// IAM token endpoint for authentication
  static const String iamTokenUrl = 'https://iam.cloud.ibm.com/identity/token';

  /// Validate that all required configuration is present
  static bool get isConfigured {
    return projectId.isNotEmpty &&
        apiKey.isNotEmpty &&
        endpoint.isNotEmpty &&
        modelId.isNotEmpty;
  }

  /// Get configuration status message
  static String get configStatus {
    if (isConfigured) {
      return 'watsonx.ai configured successfully';
    }

    final missing = <String>[];
    if (projectId.isEmpty) missing.add('WATSONX_PROJECT_ID');
    if (apiKey.isEmpty) missing.add('WATSONX_API_KEY');
    if (endpoint.isEmpty) missing.add('WATSONX_ENDPOINT');
    if (modelId.isEmpty) missing.add('WATSONX_MODEL_ID');

    return 'Missing configuration: ${missing.join(', ')}';
  }
}

// Made with Bob
