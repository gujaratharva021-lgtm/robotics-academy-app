  import 'dart:convert';
  import 'package:http/http.dart' as http;

  class AiService {
    // Your live AI Tutor backend
    static const String _endpoint =
        'https://ai-tutor-backend.atharv-robotics.workers.dev';

    static Future<String> ask(String question) async {
      try {
        final response = await http.post(
          Uri.parse(_endpoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'question': question}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['answer'] ?? "Sorry, I couldn't generate a response.";
        } else {
          return "Sorry, something went wrong (error ${response.statusCode}). Please try again.";
        }
      } catch (e) {
        return "Sorry, I couldn't reach the AI Tutor. Please check your internet connection and try again.";
      }
    }
  }