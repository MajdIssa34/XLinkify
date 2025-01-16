import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  static const String baseUrl = "http://localhost:8000/api/users";

  Future<Map<String, dynamic>> getUserProfile(String username) async {
    final url = Uri.parse("$baseUrl/profile/$username");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch user profile');
    }
  }

  Future<void> followUser(String userId) async {
    final url = Uri.parse("$baseUrl/follow/$userId");
    final response = await http.post(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to follow/unfollow user');
    }
  }

  Future<List<dynamic>> getSuggestedUsers() async {
    final url = Uri.parse("$baseUrl/suggested");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch suggested users');
    }
  }

  Future<void> updateUser(Map<String, dynamic> userData) async {
    final url = Uri.parse("$baseUrl/update");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(userData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user');
    }
  }
}
