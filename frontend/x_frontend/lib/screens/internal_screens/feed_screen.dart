import 'package:flutter/material.dart';
import 'package:x_frontend/models/post.model.dart';
import 'package:x_frontend/services/post_service.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final PostService _postService = PostService();
  late Future<List<Post>> _posts;

  @override
  void initState() {
    super.initState();
    _posts = _postService.getAllPosts(); // Fetch posts on screen load
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
      ),
      body: FutureBuilder<List<Post>>(
        future: _posts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while fetching data
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Show error message if the request fails
            return Center(
              child: SelectableText(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Handle the case when no posts are available
            return const Center(
              child: Text(
                'No posts available',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          // Data is available, build the ListView
          final posts = snapshot.data!;
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Post Author and Content
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: post.user.profileImg.isNotEmpty
                            ? NetworkImage(post.user.profileImg)
                            : const AssetImage('assets/images/placeholder.png')
                                as ImageProvider,
                      ),
                      title: Text(post.user.username),
                      subtitle: Text(post.text),
                    ),
                    // Likes and Comments
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Likes: ${post.likes.length}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    if (post.comments.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: post.comments.map((comment) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  Text(
                                    '${comment.user.username}: ',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Expanded(child: Text(comment.text)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
