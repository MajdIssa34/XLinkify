import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_session_jwt/flutter_session_jwt.dart';
import 'package:x_frontend/models/post.model.dart';

class PostService {
  static const String baseUrl = "http://localhost:8000/api/posts";

  /// Fetch all posts
  Future<List<Post>> getAllPosts() async {
  final token = await FlutterSessionJwt.retrieveToken(); // Retrieve the token
  if (token == null) {
    throw Exception('No token found. User not logged in.');
  }

  final url = Uri.parse("$baseUrl/all");
  final response = await http.get(
    url,
    headers: {"Authorization": "Bearer $token"}, // Include the token
  );

  if (response.statusCode == 200) {
    final List<dynamic> jsonList = jsonDecode(response.body); // Parse JSON into a list
    return jsonList.map((json) => Post.fromJson(json)).toList(); // Convert each JSON to Post
  } else {
    final error = jsonDecode(response.body)['message'] ?? 'Failed to fetch posts';
    throw Exception(error);
  }
}

}
