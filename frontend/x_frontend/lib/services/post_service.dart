import 'dart:convert';
import 'package:http/http.dart' as http;

class PostService {
  static const String baseUrl = "http://localhost:8000/api/posts";

  Future<List<dynamic>> getAllPosts() async {
    final url = Uri.parse("$baseUrl/all");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch all posts');
    }
  }

  Future<List<dynamic>> getFollowingPosts() async {
    final url = Uri.parse("$baseUrl/following");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch posts from following users');
    }
  }

  Future<void> createPost(Map<String, dynamic> postData) async {
    final url = Uri.parse("$baseUrl/create");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(postData),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create post');
    }
  }

  Future<void> likePost(String postId) async {
    final url = Uri.parse("$baseUrl/like/$postId");
    final response = await http.post(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to like/unlike post');
    }
  }
}
