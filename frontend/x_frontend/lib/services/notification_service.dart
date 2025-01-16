import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  static const String baseUrl = "http://localhost:8000/api/notifications";

  Future<List<dynamic>> getNotifications() async {
    final url = Uri.parse(baseUrl);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['notifications'];
    } else {
      throw Exception('Failed to fetch notifications');
    }
  }

  Future<void> clearNotifications() async {
    final url = Uri.parse(baseUrl);
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete notifications');
    }
  }
}
