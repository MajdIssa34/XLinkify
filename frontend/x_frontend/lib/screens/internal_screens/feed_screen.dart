import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:x_frontend/models/post.model.dart';
import 'package:x_frontend/services/post_service.dart';
import 'package:x_frontend/widgets/my_button.dart';
import 'package:x_frontend/widgets/my_text_field.dart';
import 'package:x_frontend/widgets/post_card.dart';
import 'package:x_frontend/widgets/snack_bar.dart';

class FeedScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  const FeedScreen({Key? key, required this.profile}) : super(key: key);

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen>
    with SingleTickerProviderStateMixin {
  final PostService _postService = PostService();
  final TextEditingController _textController = TextEditingController();
  late Future<List<Post>> _watchlistPosts;
  late Future<List<Post>> _allPosts;
  Uint8List? _selectedImage;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _watchlistPosts = _postService.getWatchlistPosts();
    _allPosts = _postService.getAllPosts();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _createPost() async {
    final text = _textController.text.trim();

    if (_selectedImage == null) {
      SnackBarUtil.showCustomSnackBar(
        context,
        'Please add an image to your post.',
        isError: true,
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await _postService.createPost(text, _selectedImage);

      SnackBarUtil.showCustomSnackBar(
        context,
        'Post created successfully!',
        isError: false,
      );

      setState(() {
        _watchlistPosts = _postService.getWatchlistPosts();
        _allPosts = _postService.getAllPosts();
        _selectedImage = null;
        _textController.clear();
      });
    } catch (error) {
      SnackBarUtil.showCustomSnackBar(
        context,
        'Error: ${error.toString()}',
        isError: true,
      );
    } finally {
      Navigator.pop(context);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImage = bytes;
        });
      } catch (error) {
        SnackBarUtil.showCustomSnackBar(
          context,
          'Error picking image: ${error.toString()}',
          isError: true,
        );
      } finally {
        Navigator.pop(context);
      }
    }
  }

  Widget _buildPostList(Future<List<Post>> posts) {
    return FutureBuilder<List<Post>>(
      future: posts,
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
              'No posts available.',
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
                _watchlistPosts = _postService.getWatchlistPosts();
                _allPosts = _postService.getAllPosts();
              }),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 2,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: (widget.profile['profileImg'] !=
                                    null &&
                                widget.profile['profileImg'].isNotEmpty &&
                                Uri.tryParse(widget.profile['profileImg'])
                                        ?.hasAbsolutePath ==
                                    true)
                            ? NetworkImage(widget.profile['profileImg'])
                            : const AssetImage('assets/images/placeholder.png')
                                as ImageProvider,
                        radius: 25,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MyTextField(
                          controller: _textController,
                          hintText: Text(
                            "What's on your mind? Add text and a photo...",
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                          keyboardType: TextInputType.multiline,
                        ),
                      ),
                    ],
                  ),
                  if (_selectedImage != null)
                    Column(
                      children: [
                        const SizedBox(height: 12),
                        Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(
                                  _selectedImage!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.black.withOpacity(0.7),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _selectedImage = null;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 150,
                        child: MyButton(onTap: _pickImage, str: "Add Photo"),
                      ),
                      SizedBox(
                        width: 150,
                        child: MyButton(onTap: _createPost, str: "Post"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.blueAccent,
            tabs: [
              Tab(               
                child: Text(
                  'Watchlist',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
              ),
              Tab(             
                child: Text(
                  'All Posts',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPostList(_watchlistPosts),
                _buildPostList(_allPosts),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
