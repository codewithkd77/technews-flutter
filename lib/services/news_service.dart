import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsService {
  static const String apiUrl = "Your api route here";
  static const String aiNewsApiUrl = "Your api route here";

  // Fetch Tech News
  Future<List<dynamic>> fetchNews() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        return json.decode(response.body); // Expecting List
      } else {
        throw Exception("Failed to load news");
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  // Fetch AI News
  Future<List<dynamic>> fetchAiNews() async {
    try {
      final response = await http.get(Uri.parse(aiNewsApiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("API Response: $data"); // Debugging print

        if (data is Map<String, dynamic> && data.containsKey('data')) {
          return data['data']
              as List<dynamic>; // Extracting the actual news list
        } else {
          throw Exception("Unexpected API response format");
        }
      } else {
        throw Exception("Failed to load AI news");
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }
}
