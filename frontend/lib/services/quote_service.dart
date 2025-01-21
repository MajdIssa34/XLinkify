import 'package:flutter_session_jwt/flutter_session_jwt.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuoteService {
  static const String baseUrl = "http://localhost:8000/api/quotes";

  Future<Map<String, String>> getDailyQuote() async {
    final token = await FlutterSessionJwt.retrieveToken(); // Retrieve the token
    if (token == null) {
      throw Exception('No token found. User not logged in.');
    }

    final url = Uri.parse("$baseUrl/");
    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token", // Add the token to the headers
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Expecting 'quote' and 'author' keys
        if (data['quote'] != null && data['author'] != null) {
          return {
            "quote": data['quote'],
            "author": data['author'],
          };
        } else {
          throw Exception('Invalid response format from server.');
        }
      } else {
        final error = jsonDecode(response.body)['message'] ??
            'Failed to fetch daily quote';
        throw Exception(error);
      }
    } catch (error) {
      throw Exception('Error fetching daily quote: $error');
    }
  }
}
