import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "http://localhost:8000/api/auth";

  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse("$baseUrl/login");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Login failed');
    }
  }

  Future<Map<String, dynamic>> signup(Map<String, String> userData) async {
    final url = Uri.parse("$baseUrl/signup");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(userData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Signup failed');
    }
  }

  Future<void> logout() async {
    final url = Uri.parse("$baseUrl/logout");
    final response = await http.post(url);

    if (response.statusCode != 200) {
      throw Exception('Logout failed');
    }
  }

  Future<Map<String, dynamic>> getUserDetails(String token) async {
    final url = Uri.parse("$baseUrl/me");
    final response = await http.get(url, headers: {"Authorization": "Bearer $token"});

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch user details');
    }
  }
}
