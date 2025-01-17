import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter_session_jwt/flutter_session_jwt.dart';
import 'package:x_frontend/models/post.model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
      final List<dynamic> jsonList =
          jsonDecode(response.body); // Parse JSON into a list
      return jsonList
          .map((json) => Post.fromJson(json))
          .toList(); // Convert each JSON to Post
    } else {
      final error =
          jsonDecode(response.body)['message'] ?? 'Failed to fetch posts';
      throw Exception(error);
    }
  }

  Future<void> toggleLike(String postId, String userId) async {
    final token = await FlutterSessionJwt.retrieveToken();
    if (token == null) throw Exception('No token found');

    final url = Uri.parse("$baseUrl/like/$postId");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"userId": userId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to toggle like');
    }
  }

  Future<void> addComment(String postId, String userId, String text) async {
    final token = await FlutterSessionJwt.retrieveToken();
    if (token == null) throw Exception('No token found');

    final url = Uri.parse("$baseUrl/comment/$postId");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "userId": userId,
        "text": text,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add comment');
    }
  }

  Future<void> createPost(String text, Uint8List? image) async {
    final token = await FlutterSessionJwt.retrieveToken();
    if (token == null) throw Exception('No token found.');

    String? base64Image;
    if (image != null) {
      // Convert the image to Base64
      base64Image = base64Encode(image);
    }

    final url = Uri.parse("$baseUrl/create");
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "text": text,
        "img": base64Image,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create post: ${response.body}');
    }
  }

  /// Delete a post by ID
  Future<void> deletePost(String postId) async {
    final token = await FlutterSessionJwt.retrieveToken();
    if (token == null) throw Exception('No token found.');

    final url = Uri.parse("$baseUrl/$postId");
    final response = await http.delete(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete post: ${response.body}');
    }
  }

  /// Fetch posts for a specific user by username
  Future<List<Post>> getUserPosts(String username) async {
    final token = await FlutterSessionJwt.retrieveToken(); // Retrieve the token
    if (token == null) {
      throw Exception('No token found. User not logged in.');
    }

    final url = Uri.parse("$baseUrl/user/$username");
    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"}, // Include the token
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList =
          jsonDecode(response.body); // Parse JSON into a list
      return jsonList
          .map((json) => Post.fromJson(json))
          .toList(); // Convert each JSON to Post
    } else {
      final error =
          jsonDecode(response.body)['error'] ?? 'Failed to fetch posts';
      throw Exception(error);
    }
  }

  Future<int> getUserPostsLength(String username) async {
    try {
      final posts = await getUserPosts(username);
      return posts.length;
    } catch (error) {
      throw Exception('Failed to get user posts length: $error');
    }
  }
}
