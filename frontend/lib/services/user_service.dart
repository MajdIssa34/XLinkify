import 'dart:convert';
import 'package:flutter_session_jwt/flutter_session_jwt.dart';
import 'package:http/http.dart' as http;

class UserService {
  static const String baseUrl = "https://xlinkify.onrender.com/api/users";

  /// Fetch user profile by username
  Future<Map<String, dynamic>> getUserProfile(String username) async {
    final token = await FlutterSessionJwt.retrieveToken(); // Retrieve the token
    if (token == null) {
      throw Exception('No token found. User not logged in.');
    }

    final url = Uri.parse("$baseUrl/profile/$username");
    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token"
        }, // Add the token to the headers
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body)['message'] ??
            'Failed to fetch user profile';
        throw Exception(error);
      }
    } catch (error) {
      throw Exception('Error fetching user profile: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getUserWatchlist(String username) async {
    final token = await FlutterSessionJwt.retrieveToken(); // Retrieve the token
    if (token == null) {
      throw Exception('No token found. User not logged in.');
    }
    final response =
        await http.get(Uri.parse("$baseUrl/watchlist/$username"), headers: {
      'Authorization': 'Bearer $token', // Replace with your auth token
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to fetch watchlist');
    }
  }

  Future<Map<String, dynamic>> addToWatchlist(String userId) async {
    final token = await FlutterSessionJwt.retrieveToken(); // Retrieve the token
    if (token == null) {
      throw Exception('No token found. User not logged in.');
    }

    final url = Uri.parse('$baseUrl/watchlist/$userId');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to update watchlist: ${response.body}');
    }
  }

  Future<List<dynamic>> searchUsers(String query) async {
    final token = await FlutterSessionJwt.retrieveToken();
    final url = Uri.parse("$baseUrl/search?query=$query");

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body); // Decode the JSON response
      return data['users']; // Extract the 'users' list
    } else {
      throw Exception('Failed to search users');
    }
  }

  /// Update user information
  Future<Map<String, dynamic>> updateUser(Map<String, dynamic> userData) async {
    final token = await FlutterSessionJwt.retrieveToken(); // Example for token
    final url = Uri.parse('$baseUrl/update'); // Replace with your API endpoint

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(
          response.body); // Parse and return the updated profile data
    } else {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }
}
