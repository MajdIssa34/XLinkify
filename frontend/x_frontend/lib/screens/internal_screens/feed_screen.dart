import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:x_frontend/models/post.model.dart';
import 'package:x_frontend/services/post_service.dart';
import 'package:x_frontend/widgets/my_text_field.dart'; // Assuming you have a custom text field widget
import 'package:x_frontend/widgets/post_card.dart'; // Assuming you have a custom post card widget
import 'package:x_frontend/widgets/snack_bar.dart';


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
      SnackBarUtil.showCustomSnackBar(
        context,
        'Please add some text or an image',
        isError: true,
      );
      return;
    }

    try {
      await _postService.createPost(text, _selectedImage);
      SnackBarUtil.showCustomSnackBar(
        context,
        'Post created successfully!',
        isError: false,
      );

      // Refresh the posts
      setState(() {
        _posts = _postService.getAllPosts(); // Fetch updated posts
        _selectedImage = null; // Clear the selected image
        _textController.clear(); // Clear the text input
      });
    } catch (error) {
      SnackBarUtil.showCustomSnackBar(
        context,
        'Error: ${error.toString()}',
        isError: true,
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
              color: Colors.white,
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
                        style: GoogleFonts.poppins(color: Colors.white)),
                    keyboardType: TextInputType.multiline,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add_a_photo,
                    color: Colors.black,
                  ),
                  onPressed: _pickImage,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: Colors.black,
                  ),
                  onPressed: _createPost,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white
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
                      return PostCard(
                        post: post,
                        profile: widget.profile,
                        onRefresh: () => setState(() {
                          _posts = _postService.getAllPosts();
                        }),
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

}
