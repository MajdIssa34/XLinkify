import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:x_frontend/models/post.model.dart';
import 'package:x_frontend/services/post_service.dart';
import 'package:x_frontend/widgets/my_button.dart';
import 'package:x_frontend/widgets/snack_bar.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final Map<String, dynamic> profile;
  final Function onRefresh;

  const PostCard({
    Key? key,
    required this.post,
    required this.profile,
    required this.onRefresh,
  }) : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final PostService _postService = PostService();
  final TextEditingController _commentController = TextEditingController();

  String _formatPostDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays >= 1) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _toggleLike() async {
    try {
      final isLiked = widget.post.likes.contains(widget.profile['_id']);
      setState(() {
        if (isLiked) {
          widget.post.likes.remove(widget.profile['_id']);
        } else {
          widget.post.likes.add(widget.profile['_id']);
        }
      });

      await _postService.toggleLike(widget.post.id, widget.profile['_id']);
    } catch (error) {
      SnackBarUtil.showCustomSnackBar(
        context,
        'Error: ${error.toString()}',
        isError: true,
      );
    }
  }

  Future<void> _addComment(
      {required Post post, required void Function() refreshDialog}) async {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;

    try {
      final newComment = Comment(
        text: commentText,
        user: User.fromJson(widget.profile),
      );

      setState(() {
        post.comments.add(newComment);
        _commentController.clear();
      });
      refreshDialog();

      await _postService.addComment(
        post.id,
        widget.profile['_id'],
        commentText,
      );
    } catch (error) {
      SnackBarUtil.showCustomSnackBar(
        context,
        'Error: ${error.toString()}',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    if (post.img == null || post.img!.isEmpty) {
      throw Exception("Each post must have an image.");
    }

    return Column(
      children: [
        Card(
          color: Colors.white,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            Row(
                              children: [
                                Text(
                                  post.user.username,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '• ${_formatPostDate(post.createdAt)}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    widget.profile['_id'] == post.user.id
                        ? PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) async {
                              if (value == 'delete') {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Post'),
                                    content: Text(
                                      'Are you sure you want to delete this post?',
                                      style: GoogleFonts.poppins(
                                        color: Colors.black,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text('Cancel',
                                            style: GoogleFonts.poppins()),
                                      ),
                                      SizedBox(
                                        width: 100,
                                        child: MyButton(
                                          onTap: () =>
                                              Navigator.pop(context, true),
                                          str: "Delete",
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed == true) {
                                  try {
                                    await _postService.deletePost(post.id);
                                    widget.onRefresh();
                                    SnackBarUtil.showCustomSnackBar(
                                      context,
                                      'Post deleted successfully!',
                                    );
                                  } catch (error) {
                                    SnackBarUtil.showCustomSnackBar(
                                      context,
                                      'Failed to delete post: ${error.toString()}',
                                      isError: true,
                                    );
                                  }
                                }
                              }
                            },
                            itemBuilder: (BuildContext context) => [
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  'Delete',
                                  style: GoogleFonts.poppins(),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 300,
                      height: 300,
                      child: Image.network(
                        post.img!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                if (post.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      post.text,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        post.likes.contains(widget.profile['_id'])
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: post.likes.contains(widget.profile['_id'])
                            ? Colors.red
                            : Colors.black,
                      ),
                      onPressed: _toggleLike,
                    ),
                    Text(
                      post.likes.length == 1
                          ? '${post.likes.length} Like'
                          : '${post.likes.length} Likes',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        _showTextCommentDialog(post);
                      },
                      child: Text(
                        'Show all ${post.comments.length} comments',
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          hintStyle: GoogleFonts.poppins(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        style: GoogleFonts.poppins(color: Colors.black),
                        keyboardType: TextInputType.multiline,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.blue),
                      onPressed: () {
                        _addComment(
                            post: post,
                            refreshDialog: () {
                              setState(() {}); // Refresh dialog
                            });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const Divider(
          color: Colors.grey,
          height: 20,
          thickness: 1,
          indent: 20,
          endIndent: 20,
        ),
      ],
    );
  }

  void _showTextCommentDialog(Post post) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
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
                        Text(
                          post.user.username,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '• ${_formatPostDate(post.createdAt)}',
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      post.text,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    const Divider(),
                    _buildCommentsSection(post),
                    const Divider(),
                    _buildBottomSection(post, () {
                      setDialogState(() {}); // Refresh dialog state
                    }),
                  ],
                ),
              );
            },
          ),
          actions: [
            SizedBox(
              width: 100,
              child: MyButton(
                onTap: () => Navigator.pop(context),
                str: 'Close',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCommentsSection(Post post) {
    return post.comments.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: post.comments.length,
            itemBuilder: (context, index) {
              final comment = post.comments[index];
              return Row(
                children: [
                  CircleAvatar(
                    backgroundImage: const AssetImage(
                      'assets/images/placeholder.png',
                    ),
                    radius: 15,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comment.user.username,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          comment.text,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          )
        : Center(
            child: Text(
              'No comments yet.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          );
  }

  Widget _buildBottomSection(Post post, void Function() refreshDialog) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(
                post.likes.contains(widget.profile['_id'])
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: post.likes.contains(widget.profile['_id'])
                    ? Colors.red
                    : Colors.black,
              ),
              onPressed: () {
                _toggleLike();
              },
            ),
            Text(
              post.likes.length == 1
                  ? '${post.likes.length} Like'
                  : '${post.likes.length} Likes',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                style: GoogleFonts.poppins(color: Colors.black),
                keyboardType: TextInputType.multiline,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.blue),
              onPressed: () {
                _addComment(
                  post: post,
                  refreshDialog: refreshDialog,
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
