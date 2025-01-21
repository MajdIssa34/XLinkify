import 'dart:convert';
import 'package:flutter_session_jwt/flutter_session_jwt.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static const String baseUrl = "https://xlinkify.onrender.com/api/notifications";

  /// Fetch notifications for the logged-in user
  Future<List<dynamic>> getNotifications() async {
    final token = await FlutterSessionJwt.retrieveToken(); // Retrieve the token
    if (token == null) {
      throw Exception('No token found. User not logged in.');
    }

    final url = Uri.parse(baseUrl);

    try {
      final response = await http.get(url, headers: {
        'Authorization': "Bearer $token",
        'Content-Type': 'application/json', // Explicitly define content type
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['notifications'] ?? [];
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access. Please log in again.');
      } else {
        throw Exception('Failed to fetch notifications. Status: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('An error occurred while fetching notifications: $error');
    }
  }

  /// Clear all notifications for the logged-in user
  Future<void> clearNotifications() async {
    final token = await FlutterSessionJwt.retrieveToken(); // Retrieve the token
    if (token == null) {
      throw Exception('No token found. User not logged in.');
    }

    final url = Uri.parse(baseUrl);

    try {
      final response = await http.delete(url, headers: {
        'Authorization': "Bearer $token",
        'Content-Type': 'application/json', // Explicitly define content type
      });

      if (response.statusCode == 200) {
        return; // Successfully cleared notifications
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access. Please log in again.');
      } else {
        throw Exception('Failed to delete notifications. Status: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('An error occurred while deleting notifications: $error');
    }
  }
}
