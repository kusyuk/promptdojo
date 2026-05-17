import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  final envFile = File('.env').readAsStringSync();
  final env = <String, String>{};
  for (final line in envFile.split('\n')) {
    if (line.trim().isEmpty || line.startsWith('#')) continue;
    final parts = line.split('=');
    if (parts.length >= 2) {
      env[parts[0].trim()] = parts.sublist(1).join('=').trim();
    }
  }

  final projectId = env['WATSONX_PROJECT_ID'];
  final apiKey = env['WATSONX_API_KEY'];
  final endpoint = env['WATSONX_ENDPOINT'] ?? 'https://us-south.ml.cloud.ibm.com';
  final modelId = 'ibm/granite-8b-code-instruct';

  // 1. Get IAM token
  print('Getting IAM token...');
  final tokenResponse = await http.post(
    Uri.parse('https://iam.cloud.ibm.com/identity/token'),
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
    },
    body: {
      'grant_type': 'urn:ibm:params:oauth:grant-type:apikey',
      'apikey': apiKey!,
    },
  );
  
  final token = jsonDecode(tokenResponse.body)['access_token'];

  // 2. Call watsonx.ai
  final url = '$endpoint/ml/v1/text/generation?version=2023-05-29';
  
  final systemPrompt = '''
You are the "Scrying Terminal Evaluator" for a gamified coding simulator. Your job is to evaluate the quality of a user's prompt (their "incantation") based on software engineering best practices.

You must act as "Archmage Bob," a strict but wise senior software architect.

EVALUATION CRITERIA:
Score the user's prompt on a scale of 1 to 10 based on the following:
- Clarity (1-3 pts): Is the end goal highly specific, or vague?
- Constraints (1-4 pts): Did they define the tech stack, rules, UI requirements, or limitations?
- Context (1-3 pts): Did they mention a "Blueprint" (PRD), architectural patterns, or provide background information?

SCORING GUIDE:
- 1 to 3 (Chaotic Vibe-Coding): "Build me an app." "Make a trading portal." (Vague, no context, massive hallucination risk).
- 4 to 7 (Apprentice Level): "Build a React trading portal with a login page." (Has a goal and a stack, but missing deep constraints or logic).
- 8 to 10 (Architect Level): "Act as a senior frontend dev. Build a React authentication portal using Firebase. Refer to the attached Blueprint PRD for the user flow. Ensure the UI uses Tailwind CSS and includes error handling for invalid emails." (Perfect context, role, and constraints).

OUTPUT FORMAT:
You must output ONLY a valid, raw JSON object. Do not include markdown formatting, code blocks, or conversational text. Use this exact schema:
{
  "quality_score": <integer between 1 and 10>,
  "archmage_feedback": "<A short, 1-2 sentence critique spoken in the character of Archmage Bob. Be sharp, witty, and reference magic, blueprints, or mana>"
}
''';

  final userPrompt = "Build an app";
  
  // Granite-8b-code-instruct uses <|system|>, <|user|>, <|assistant|> or just normal prompting
  final fullPrompt = '$systemPrompt\n\nUser Input: $userPrompt\nOutput:';

  print('Calling watsonx.ai with model $modelId...');
  final response = await http.post(
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
      'model_id': modelId,
      'project_id': projectId,
    }),
  );

  print('Status: ${response.statusCode}');
  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    final generatedText = responseData['results'][0]['generated_text'];
    print('Generated text:\n$generatedText');
  } else {
    print('Error: ${response.body}');
  }
}
