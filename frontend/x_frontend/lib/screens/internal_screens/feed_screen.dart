import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:x_frontend/models/post.model.dart';
import 'package:x_frontend/services/post_service.dart';
import 'package:x_frontend/widgets/my_text_field.dart'; // Assuming you have a custom text field widget

class FeedScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  const FeedScreen({Key? key, required this.profile}) : super(key: key);

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final PostService _postService = PostService();
  final TextEditingController _textController = TextEditingController();
  late Future<List<Post>> _posts;
  Uint8List? _selectedImage;

  @override
  void initState() {
    super.initState();
    _posts = _postService.getAllPosts(); // Fetch posts on screen load
  }

  Future<void> _createPost() async {
    final text = _textController.text.trim();

    if (text.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add some text or an image')),
      );
      return;
    }

    try {
      await _postService.createPost(text, _selectedImage);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully!')),
      );

      // Refresh the posts
      setState(() {
        _posts = _postService.getAllPosts(); // Fetch updated posts
        _selectedImage = null; // Clear the selected image
        _textController.clear(); // Clear the text input
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImage = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(      
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.black,             
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: widget.profile['profileImg'].isNotEmpty
                      ? NetworkImage(widget.profile['profileImg'])
                      : const AssetImage('assets/images/placeholder.png')
                          as ImageProvider,
                  radius: 25,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MyTextField(
                    controller: _textController,
                    hintText: Text("What's on your mind...",
                        style: GoogleFonts.poppins(color: Colors.black)),
                    keyboardType: TextInputType.multiline,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_a_photo, color: Colors.white,),
                  onPressed: _pickImage,
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white,),
                  onPressed: _createPost,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,              
              ),
              child: FutureBuilder<List<Post>>(
                future: _posts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: SelectableText(
                        'Error: ${snapshot.error}',
                        style: GoogleFonts.poppins(color: Colors.red),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No posts available',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                    );
                  }
              
                  final posts = snapshot.data!;
                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return Card(
                        color: Colors.black,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
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
                                    backgroundImage: post
                                            .user.profileImg.isNotEmpty
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
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        post.user.fullName,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
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
                                style: GoogleFonts.poppins(fontSize: 16, color: Colors.white,),
                                
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: 
                                          (post.likes
                                                  .contains(widget.profile['_id']))
                                              ? Icon(Icons.favorite, color: Colors.red,)
                                              : Icon(Icons.favorite_border, color: Colors.white,),
                                          color: post.likes
                                                  .contains(widget.profile['_id'])
                                              ? Colors.red
                                              : Colors.black,
                                        
                                        onPressed: () async {
                                          try {
                                            // Optimistically update the UI
                                            setState(() {
                                              if (post.likes.contains(
                                                  widget.profile['_id'])) {
                                                post.likes.remove(
                                                    widget.profile['_id']);
                                              } else {
                                                post.likes
                                                    .add(widget.profile['_id']);
                                              }
                                            });
              
                                            // Call the backend to toggle the like
                                            await _postService.toggleLike(
                                                post.id, widget.profile['_id']);
                                          } catch (error) {
                                            // Revert state in case of an error
                                            setState(() {
                                              if (post.likes.contains(
                                                  widget.profile['_id'])) {
                                                post.likes
                                                    .add(widget.profile['_id']);
                                              } else {
                                                post.likes.remove(
                                                    widget.profile['_id']);
                                              }
                                            });
              
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Error: ${error.toString()}', style: GoogleFonts.poppins(color: Colors.black))),
                                            );
                                          }
                                        },
                                      ),
                                      Text('${post.likes.length} Likes', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold,)),
                                    ],
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.comment, color: Colors.white,),
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
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(comment.text, style: GoogleFonts.poppins(color: Colors.white)),
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
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentDialog(Post post) {
    final TextEditingController _commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Comment', style: TextStyle(color: Colors.black)),
        content: MyTextField(
          controller: _commentController,
          hintText: Text("Write a comment...",
              style: GoogleFonts.poppins(color: Colors.black)),
          keyboardType: TextInputType.multiline,
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
