import 'package:flutter/material.dart';
import 'package:x_frontend/models/post.model.dart';
import 'package:x_frontend/services/post_service.dart';

class FeedScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  const FeedScreen({Key? key, required this.profile}) : super(key: key);

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
    print(widget.profile);
    print("11111");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Post>>(
        future: _posts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: SelectableText(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No posts available',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final posts = snapshot.data!;
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: post.user.profileImg.isNotEmpty
                                ? NetworkImage(post.user.profileImg)
                                : const AssetImage(
                                        'assets/images/placeholder.png')
                                    as ImageProvider,
                            radius: 25,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.user.username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                post.user.fullName,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (post.img != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            post.img!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 12),
                      Text(
                        post.text,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  post.likes.contains(widget.profile['_id'])
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                      post.likes.contains(widget.profile['_id'])
                                          ? Colors.red
                                          : Colors.grey,
                                ),
                                onPressed: () async {
                                  try {
                                    // Optimistically update the UI
                                    setState(() {
                                      if (post.likes
                                          .contains(widget.profile['_id'])) {
                                        post.likes
                                            .remove(widget.profile['_id']);
                                      } else {
                                        post.likes.add(widget.profile['_id']);
                                      }
                                    });

                                    // Call the backend to toggle the like
                                    await _postService.toggleLike(
                                        post.id, widget.profile['_id']);
                                  } catch (error) {
                                    // Revert state in case of an error
                                    setState(() {
                                      if (post.likes
                                          .contains(widget.profile['_id'])) {
                                        post.likes.add(widget.profile['_id']);
                                      } else {
                                        post.likes
                                            .remove(widget.profile['_id']);
                                      }
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Error: ${error.toString()}')),
                                    );
                                  }
                                },
                              ),
                              Text('${post.likes.length} Likes'),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.comment),
                            onPressed: () {
                              _showCommentDialog(post);
                            },
                          ),
                        ],
                      ),
                      if (post.comments.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            ...post.comments.map((comment) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: const AssetImage(
                                          'assets/images/placeholder.png'),
                                      radius: 15,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            comment.user
                                                .username, // Replace with user.username if available
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(comment.text),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showCommentDialog(Post post) {
    final TextEditingController _commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Comment'),
        content: TextField(
          controller: _commentController,
          decoration: const InputDecoration(hintText: 'Write a comment...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final commentText = _commentController.text.trim();
              if (commentText.isEmpty) return;

              try {
                setState(() {
                  post.comments.add(
                    Comment(
                      text: commentText,
                      user: User.fromJson(widget.profile),
                    ),
                  );
                });
                await _postService.addComment(
                    post.id, widget.profile['_id'], commentText);
                Navigator.pop(context);
              } catch (error) {
                setState(() {
                  post.comments.removeWhere((c) => c.text == commentText);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${error.toString()}')),
                );
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }
}
