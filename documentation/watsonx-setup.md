# IBM watsonx.ai Setup Guide

This guide provides step-by-step instructions for setting up IBM watsonx.ai for the PromptDojo project.

## Overview

PromptDojo uses IBM watsonx.ai's **granite-4-h-small** model to evaluate user prompts in real-time. The setup requires:
- IBM Cloud account
- watsonx.ai project in Dallas region
- API key for authentication
- IAM token generation

---

## Prerequisites

- Valid email address for IBM Cloud account
- Credit card (for account verification, free tier available)
- Internet connection
- Text editor for storing credentials

---

## Step 1: Create IBM Cloud Account

### 1.1 Sign Up
1. Go to [IBM Cloud](https://cloud.ibm.com/registration)
2. Fill in your details:
   - Email address
   - First and last name
   - Country/Region
   - Password (must meet complexity requirements)
3. Accept the terms and conditions
4. Click **"Create Account"**
5. Check your email for verification link
6. Click the verification link to activate your account

### 1.2 Verify Account
1. Log in to [IBM Cloud Console](https://cloud.ibm.com/)
2. Complete any additional verification steps if prompted
3. Add payment method (required even for free tier)
   - Note: You won't be charged unless you exceed free tier limits

**Expected Result:** You should see the IBM Cloud dashboard

---

## Step 2: Access watsonx.ai

### 2.1 Navigate to watsonx.ai
1. From IBM Cloud dashboard, click the **hamburger menu** (☰) in top-left
2. Select **"AI / Machine Learning"**
3. Click **"watsonx.ai"** (or search for "watsonx" in the search bar)
4. Click **"Launch watsonx.ai"** button

**Alternative Direct Link:** [https://dataplatform.cloud.ibm.com/wx/home](https://dataplatform.cloud.ibm.com/wx/home)

### 2.2 First-Time Setup
If this is your first time accessing watsonx.ai:
1. You may see a welcome screen - click **"Get Started"**
2. Review the overview (optional)
3. You'll be directed to the watsonx.ai home page

**Expected Result:** You should see the watsonx.ai interface with options to create projects

---

## Step 3: Create a watsonx.ai Project

### 3.1 Create New Project
1. Click **"Projects"** in the left sidebar
2. Click **"New project"** button (top-right)
3. Select **"Create an empty project"**
4. Fill in project details:
   - **Name:** `PromptDojo` (or your preferred name)
   - **Description:** `Hackathon project for prompt engineering game`
   - **Storage:** Select or create a Cloud Object Storage instance
     - If you don't have storage, click **"Add"** and follow prompts to create one
5. Click **"Create"**

### 3.2 Note Your Project ID
1. Once project is created, you'll be in the project view
2. Click the **"Manage"** tab
3. Look for **"General"** section
4. Find and copy your **Project ID** (format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`)
5. **SAVE THIS ID** - you'll need it for API calls

**Expected Result:** You have a project with a unique Project ID

---

## Step 4: Verify Dallas Region

### 4.1 Check Region
1. In the top-right corner of IBM Cloud console, check the region selector
2. Ensure it shows **"Dallas"** or **"us-south"**
3. If not, click the region selector and choose **"Dallas (us-south)"**

### 4.2 Note the Endpoint URL
For Dallas region, the watsonx.ai endpoint is:
```
https://us-south.ml.cloud.ibm.com
```

**IMPORTANT:** PromptDojo requires the Dallas region endpoint. Other regions will not work.

**Expected Result:** You're working in the Dallas region

---

## Step 5: Generate API Key

### 5.1 Navigate to API Keys
1. Click your **profile icon** in the top-right corner
2. Select **"Profile and settings"** or **"Manage"**
3. In the left sidebar, click **"API keys"**
4. Or go directly to: [https://cloud.ibm.com/iam/apikeys](https://cloud.ibm.com/iam/apikeys)

### 5.2 Create API Key
1. Click **"Create"** button (or **"Create an IBM Cloud API key"**)
2. Fill in details:
   - **Name:** `PromptDojo-API-Key` (or your preferred name)
   - **Description:** `API key for PromptDojo hackathon project`
3. Click **"Create"**
4. **IMPORTANT:** A dialog will appear with your API key
5. Click **"Copy"** to copy the API key
6. Click **"Download"** to save it as a file (recommended)
7. **SAVE THIS KEY SECURELY** - you cannot retrieve it again!

**Security Note:** 
- Never commit API keys to version control
- Store in environment variables or secure configuration
- Treat API keys like passwords

**Expected Result:** You have an API key saved securely

---

## Step 6: Test API Access

### 6.1 Generate IAM Token
Before making API calls, you need to generate an IAM access token from your API key.

**Using cURL (Terminal/Command Prompt):**
```bash
curl -X POST 'https://iam.cloud.ibm.com/identity/token' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d 'grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=YOUR_API_KEY_HERE'
```

Replace `YOUR_API_KEY_HERE` with your actual API key.

**Expected Response:**
```json
{
  "access_token": "eyJhbGciOiJIUz...",
  "refresh_token": "...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "expiration": 1234567890
}
```

Copy the `access_token` value - this is your IAM token (valid for 1 hour).

### 6.2 Test watsonx.ai API Call
Test the API with a simple prompt evaluation:

```bash
curl -X POST 'https://us-south.ml.cloud.ibm.com/ml/v1/text/generation?version=2023-05-29' \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H 'Authorization: Bearer YOUR_IAM_TOKEN_HERE' \
  -d '{
    "input": "You are a prompt evaluator. Rate this prompt from 1-10: \"Build me an app\"",
    "parameters": {
      "decoding_method": "greedy",
      "max_new_tokens": 200,
      "temperature": 0.7
    },
    "model_id": "ibm/granite-4-h-small",
    "project_id": "YOUR_PROJECT_ID_HERE"
  }'
```

Replace:
- `YOUR_IAM_TOKEN_HERE` with your IAM token
- `YOUR_PROJECT_ID_HERE` with your Project ID

**Expected Response:**
```json
{
  "model_id": "ibm/granite-4-h-small",
  "created_at": "2024-01-01T00:00:00.000Z",
  "results": [
    {
      "generated_text": "I would rate this prompt 2/10...",
      "generated_token_count": 50,
      "input_token_count": 20,
      "stop_reason": "eos_token"
    }
  ]
}
```

If you receive a successful response, your API setup is working! ✅

---

## Step 7: Configure PromptDojo

### 7.1 Create Environment Configuration
Create a `.env` file in your project root (add to `.gitignore`):

```env
# IBM watsonx.ai Configuration
WATSONX_PROJECT_ID=your-project-id-here
WATSONX_API_KEY=your-api-key-here
WATSONX_ENDPOINT=https://us-south.ml.cloud.ibm.com
WATSONX_MODEL_ID=ibm/granite-4-h-small
```

### 7.2 Alternative: Configuration File
Or create `lib/config/watsonx_config.dart`:

```dart
class WatsonxConfig {
  // IMPORTANT: Never commit real credentials to version control
  // Use environment variables or secure storage in production
  
  static const String projectId = 'YOUR_PROJECT_ID';
  static const String apiKey = 'YOUR_API_KEY'; // Use secure storage!
  static const String endpoint = 'https://us-south.ml.cloud.ibm.com';
  static const String modelId = 'ibm/granite-4-h-small';
  static const String iamTokenUrl = 'https://iam.cloud.ibm.com/identity/token';
}
```

### 7.3 Add to .gitignore
Ensure your `.gitignore` includes:
```
.env
lib/config/watsonx_config.dart
**/credentials.json
```

**Expected Result:** Your credentials are configured and secured

---

## Step 8: Implement Token Management in Flutter

### 8.1 Create IAM Token Service
Create `lib/data/services/iam_token_service.dart`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class IamTokenService {
  static const String _tokenUrl = 'https://iam.cloud.ibm.com/identity/token';
  
  String? _cachedToken;
  DateTime? _tokenExpiration;
  
  Future<String> getToken(String apiKey) async {
    // Check if cached token is still valid
    if (_cachedToken != null && 
        _tokenExpiration != null && 
        DateTime.now().isBefore(_tokenExpiration!)) {
      return _cachedToken!;
    }
    
    // Generate new token
    final response = await http.post(
      Uri.parse(_tokenUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: 'grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=$apiKey',
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _cachedToken = data['access_token'];
      
      // Token expires in 1 hour, refresh 5 minutes early
      final expiresIn = data['expires_in'] as int;
      _tokenExpiration = DateTime.now().add(
        Duration(seconds: expiresIn - 300)
      );
      
      return _cachedToken!;
    } else {
      throw Exception('Failed to generate IAM token: ${response.body}');
    }
  }
  
  void clearToken() {
    _cachedToken = null;
    _tokenExpiration = null;
  }
}
```

### 8.2 Create Watsonx Service
Create `lib/data/services/watsonx_service.dart`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'iam_token_service.dart';
import '../models/prompt_evaluation.dart';

class WatsonxService {
  final String projectId;
  final String apiKey;
  final String endpoint;
  final IamTokenService _tokenService = IamTokenService();
  
  WatsonxService({
    required this.projectId,
    required this.apiKey,
    required this.endpoint,
  });
  
  Future<PromptEvaluation> evaluatePrompt(String userPrompt) async {
    // Get IAM token
    final token = await _tokenService.getToken(apiKey);
    
    // Build request
    final url = '$endpoint/ml/v1/text/generation?version=2023-05-29';
    final systemPrompt = _buildSystemPrompt();
    
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'input': '$systemPrompt\n\nUser Input: $userPrompt',
        'parameters': {
          'decoding_method': 'greedy',
          'max_new_tokens': 200,
          'temperature': 0.7,
        },
        'model_id': 'ibm/granite-4-h-small',
        'project_id': projectId,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final generatedText = data['results'][0]['generated_text'];
      
      // Parse JSON from generated text
      final evaluation = jsonDecode(generatedText);
      return PromptEvaluation.fromJson(evaluation);
    } else {
      throw Exception('API call failed: ${response.body}');
    }
  }
  
  String _buildSystemPrompt() {
    // System prompt from PRD
    return '''You are the "Scrying Terminal Evaluator" for a gamified coding simulator...
    [Full system prompt from PRD]''';
  }
}
```

**Expected Result:** You can make API calls from Flutter

---

## Troubleshooting

### Issue: "Invalid API Key"
**Solution:**
- Verify API key is copied correctly (no extra spaces)
- Ensure API key has not been deleted in IBM Cloud
- Generate a new API key if needed

### Issue: "Project not found"
**Solution:**
- Verify Project ID is correct
- Ensure project exists in Dallas region
- Check you're using the correct IBM Cloud account

### Issue: "Region not supported"
**Solution:**
- Verify you're using Dallas region endpoint: `https://us-south.ml.cloud.ibm.com`
- Do not use other region endpoints (Tokyo, Frankfurt, etc.)

### Issue: "Token expired"
**Solution:**
- IAM tokens expire after 1 hour
- Implement token refresh logic (see Step 8.1)
- Generate new token before each API call if needed

### Issue: "Rate limit exceeded"
**Solution:**
- Free tier has rate limits
- Implement retry logic with exponential backoff
- Consider upgrading plan if needed for hackathon

### Issue: "Model not available"
**Solution:**
- Verify model ID: `ibm/granite-4-h-small`
- Check model is available in your region
- Try alternative granite models if needed

---

## Security Best Practices

### ✅ DO:
- Store API keys in environment variables
- Use `.gitignore` to exclude credential files
- Implement token caching to reduce API calls
- Use HTTPS for all API calls
- Rotate API keys periodically

### ❌ DON'T:
- Commit API keys to version control
- Share API keys in public forums
- Hardcode credentials in source code
- Use API keys in client-side code (for production)
- Store credentials in plain text files

---

## Cost Management

### Free Tier Limits
- Check current limits at: [IBM Cloud Pricing](https://www.ibm.com/cloud/watson-studio/pricing)
- Monitor usage in IBM Cloud dashboard
- Set up billing alerts

### Optimization Tips
- Cache API responses during development
- Use mock responses for testing
- Implement request throttling
- Monitor token usage

---

## Additional Resources

### Documentation
- [watsonx.ai Documentation](https://dataplatform.cloud.ibm.com/docs/content/wsj/getting-started/welcome-main.html)
- [IBM Cloud API Docs](https://cloud.ibm.com/apidocs)
- [Granite Models Overview](https://www.ibm.com/products/watsonx-ai/foundation-models)

### Support
- [IBM Cloud Support](https://cloud.ibm.com/unifiedsupport/supportcenter)
- [watsonx.ai Community](https://community.ibm.com/community/user/watsonx/home)
- [Stack Overflow - IBM Watson](https://stackoverflow.com/questions/tagged/ibm-watson)

---

## Quick Reference

### Essential URLs
- IBM Cloud Console: https://cloud.ibm.com/
- watsonx.ai: https://dataplatform.cloud.ibm.com/wx/home
- API Keys: https://cloud.ibm.com/iam/apikeys
- IAM Token Endpoint: https://iam.cloud.ibm.com/identity/token
- Dallas Endpoint: https://us-south.ml.cloud.ibm.com

### Key Information to Save
- ✅ Project ID: `________________________________________`
- ✅ API Key: `________________________________________` (keep secure!)
- ✅ Region: Dallas (us-south)
- ✅ Model: ibm/granite-4-h-small

---

## Next Steps

After completing this setup:
1. ✅ Verify all credentials are saved securely
2. ✅ Test API connection with sample request
3. ✅ Implement token management in Flutter
4. ✅ Create watsonx service in your app
5. ✅ Begin Phase 2 of development (see `development-plan.md`)

**Setup Complete!** 🎉 You're ready to integrate watsonx.ai into PromptDojo.