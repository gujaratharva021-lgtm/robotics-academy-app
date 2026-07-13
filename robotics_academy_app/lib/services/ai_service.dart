import 'dart:convert';
import 'package:http/http.dart' as http;

/// ---------------------------------------------------------------
/// PUT YOUR ANTHROPIC API KEY HERE (or load it from a secure config
/// / environment variable — never hardcode a real key in a published app).
/// Get a key at https://console.anthropic.com
/// ---------------------------------------------------------------
const String kAnthropicApiKey = 'YOUR_API_KEY_HERE';

const String _systemPrompt =
    "You are the AI Tutor inside 'AI Robotics & Automation Academy', a learning app "
    "for robotics, AI/ML, IoT, PLC & automation, and 3D printing. Answer clearly and "
    "concisely (2-5 short paragraphs or bullet points max) in a friendly, encouraging "
    "teacher tone suited to students from school to professional level. Use simple "
    "language unless the question is advanced.";

class AiService {
  static Future<String> ask(String userMessage) async {
    if (kAnthropicApiKey == 'YOUR_API_KEY_HERE' || kAnthropicApiKey.isEmpty) {
      // No key configured yet — return a helpful mock response so the app
      // still works out of the box while you're wiring up your key.
      await Future.delayed(const Duration(milliseconds: 700));
      return _mockReply(userMessage);
    }

    try {
      final response = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': kAnthropicApiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-sonnet-4-6',
          'max_tokens': 400,
          'system': _systemPrompt,
          'messages': [
            {'role': 'user', 'content': userMessage}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['content'] as List<dynamic>;
        final textBlock = content.firstWhere(
          (b) => b['type'] == 'text',
          orElse: () => null,
        );
        return textBlock != null
            ? textBlock['text'] as String
            : "Sorry, I couldn't process that. Try asking again!";
      } else {
        return "The AI Tutor is having trouble right now (error ${response.statusCode}). Please try again shortly.";
      }
    } catch (e) {
      return "I'm having trouble connecting. Check your internet connection and try again.";
    }
  }

  static String _mockReply(String q) {
    return "Great question about \"$q\"! \n\n"
        "(This is a placeholder reply — add your Anthropic API key in "
        "lib/services/ai_service.dart to get real AI Tutor answers.)\n\n"
        "Once connected, I'll explain concepts, answer doubts, and help with "
        "your robotics, AI, and automation coursework in real time.";
  }
}
