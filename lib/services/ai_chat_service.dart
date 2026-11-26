import 'dart:convert';
import 'package:http/http.dart' as http;
import '../database/db_helper.dart';

class AIChatService {
  static const String _apiKey = 'YOUR_GROQ_API_KEY';
  static const String _groqUrl = 'https://api.groq.com/openai/v1/chat/completions';

  static Future<String> getReply({
    required String prompt,
    required String studentName,
  }) async {
    final info = await DBHelper.instance.getHostelInfo();

    final systemPrompt = '''
You are HostelMate AI for GreenView Student Residency.
Address the student warmly (current user: $studentName).
Reply in the same language used by the student (English or Roman Urdu).
Keep answers clear, helpful, and concise.

Current Today's Mess Menu:
- Breakfast: ${info.breakfast}
- Lunch: ${info.lunch}
- Dinner: ${info.dinner}

Current Hostel Notice:
- ${info.noticeTitle}: ${info.noticeBody}

Fixed Hostel Rules & Info:
- Main Gate Closes: 10:30 PM
- Monthly Rent: 2-Seater PKR 18,000 | 3-Seater PKR 15,000
- Rent Due Date: 5th of every month | Late Fine: PKR 200/day after 10th
- Laundry Pickup: Tuesday & Friday, 9:00 AM
- Quiet Hours: 11:00 PM - 6:00 AM | Visitors: Lobby till 8:00 PM
- Warden: Mr. Tariq Mehmood (+92-300-1234567)
''';

    if (_groqApiKey == 'YOUR_GROQ_API_KEY_HERE' || _groqApiKey.trim().isEmpty) {
      return _offlineFallback(
        prompt: prompt,
        breakfast: info.breakfast,
        lunch: info.lunch,
        dinner: info.dinner,
      );
    }

    try {
      final res = await http
          .post(
        Uri.parse(_groqUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_groqApiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.1-8b-instant',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.5,
          'max_tokens': 250,
        }),
      )
          .timeout(const Duration(seconds: 12));

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        final content = decoded['choices']?[0]?['message']?['content'];
        if (content != null && content.toString().trim().isNotEmpty) {
          return content.toString().trim();
        }
      }
      return _offlineFallback(
        prompt: prompt,
        breakfast: info.breakfast,
        lunch: info.lunch,
        dinner: info.dinner,
      );
    } catch (_) {
      return _offlineFallback(
        prompt: prompt,
        breakfast: info.breakfast,
        lunch: info.lunch,
        dinner: info.dinner,
      );
    }
  }

  static String _offlineFallback({
    required String prompt,
    required String breakfast,
    required String lunch,
    required String dinner,
  }) {
    final q = prompt.toLowerCase();

    if (q.contains('dinner')) {
      return 'Aaj dinner mein $dinner hai.';
    }
    if (q.contains('lunch')) {
      return 'Aaj lunch mein $lunch hai.';
    }
    if (q.contains('breakfast') || q.contains('nashta')) {
      return 'Aaj breakfast mein $breakfast hai.';
    }
    if (q.contains('mess') || q.contains('khana') || q.contains('menu')) {
      return 'Aaj ka Mess Menu:\n• Breakfast: $breakfast\n• Lunch: $lunch\n• Dinner: $dinner';
    }
    if (q.contains('rent') || q.contains('fee') || q.contains('due') || q.contains('fine')) {
      return 'Monthly rent ki due date 5th of every month hai (2-Seater: PKR 18,000 | 3-Seater: PKR 15,000). 10th ke baad PKR 200/day late fine lagta hai.';
    }
    if (q.contains('laundry') || q.contains('kapray')) {
      return 'Laundry pickup har Tuesday aur Friday subah 9:00 AM hota hai.';
    }
    if (q.contains('gate') || q.contains('time') || q.contains('timing')) {
      return 'Main gate raat 10:30 PM band hota hai. Quiet hours 11:00 PM - 6:00 AM hain.';
    }
    if (q.contains('complaint') || q.contains('wifi') || q.contains('fan') || q.contains('room')) {
      return 'Room issue ke liye neeche "Complaints" tab mein apni complaint submit karein—wo auto-route hokar Warden Desk par show hoti hai.';
    }
    return 'Assalam-o-Alaikum! Aaj dinner mein $dinner hai, aur monthly rent ki due date 5th of every month hai. Mazeed mess timings, laundry, ya rules ke baare mein poochein.';
  }
}
