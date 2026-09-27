import 'dart:convert';
import 'package:http/http.dart' as http;

class WikipediaService {
  static const String baseUrl =
      'https://en.wikipedia.org/api/rest_v1';

  static Future<Map<String, dynamic>?> getFirearmInfo(
    String firearmName,
  ) async {
    try {
      final encodedName = Uri.encodeComponent(firearmName.trim());

      final url = Uri.parse(
        '$baseUrl/page/summary/$encodedName',
      );

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      print('Wikipedia API error: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Wikipedia API error: $e');
      return null;
    }
  }
}