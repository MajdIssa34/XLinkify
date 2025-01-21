import 'dart:convert';
import 'package:flutter_session_jwt/flutter_session_jwt.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "https://xlinkify.onrender.com/api/auth";

  /// Login the user and save the JWT token
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse("$baseUrl/login");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Ensure the response contains the token
        if (data.containsKey('token')) {
          await FlutterSessionJwt.saveToken(data['token']); // Save the token
          // Save the token
          return data;
        } else {
          throw Exception('Token not found in response');
        }
      } else {
        final error = jsonDecode(response.body)['message'] ?? 'Login failed';
        throw Exception(error);
      }
    } catch (error) {
      throw Exception('Error during login: $error');
    }
  }

  /// Sign up a new user
  Future<Map<String, dynamic>> signup(Map<String, String> userData) async {
    final url = Uri.parse("$baseUrl/signup");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body)['message'] ?? 'Signup failed';
        throw Exception(error);
      }
    } catch (error) {
      throw Exception('Error during signup: $error');
    }
  }

  /// Logout the user and clear the JWT token
  Future<void> logout() async {
    final url = Uri.parse("$baseUrl/logout");
    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        await FlutterSessionJwt.deleteToken(); // Clear the token
      } else {
        throw Exception('Logout failed');
      }
    } catch (error) {
      throw Exception('Error during logout: $error');
    }
  }

  /// Fetch user details using the JWT token
  Future<Map<String, dynamic>> getUserDetails() async {
    final token = await FlutterSessionJwt.retrieveToken(); // Retrieve the token
    if (token == null) {
      throw Exception('No token found. User not logged in.');
    }

    final url = Uri.parse("$baseUrl/me");
    try {
      final response =
          await http.get(url, headers: {"Authorization": "Bearer $token"});
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body)['message'] ??
            'Failed to fetch user details';
        throw Exception(error);
      }
    } catch (error) {
      throw Exception('Error fetching user details: $error');
    }
  }
}
