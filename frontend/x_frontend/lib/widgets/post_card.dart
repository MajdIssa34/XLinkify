import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:x_frontend/models/post.model.dart';
import 'package:x_frontend/services/user_service.dart';
import 'package:x_frontend/widgets/my_button.dart';
import 'package:x_frontend/widgets/my_text_field.dart';
import 'package:x_frontend/services/post_service.dart';
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

  Future<void> _toggleLike({Function? onSuccess}) async {
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

      if (onSuccess != null) onSuccess(); // Refresh dialog state
    } catch (error) {
      SnackBarUtil.showCustomSnackBar(
        context,
        'Error: ${error.toString()}',
        isError: true,
      );
    }
  }

  Future<void> _addComment({Function? onSuccess}) async {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;

    try {
      final newComment = Comment(
        text: commentText,
        user: User.fromJson(widget.profile),
      );

      setState(() {
        widget.post.comments.add(newComment);
      });

      await _postService.addComment(
        widget.post.id,
        widget.profile['_id'],
        commentText,
      );

      _commentController.clear();
      if (onSuccess != null) onSuccess(); // Refresh dialog state
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
                        ? MyButton(
                            onTap: () async {
                              if (widget.profile['_id'] == post.user.id) {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Post'),
                                    content: Text(
                                        'Are you sure you want to delete this post?',
                                        style: GoogleFonts.poppins(
                                          color: Colors.black,
                                        )),
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
                                            str: "Delete"),
                                      )
                                    ],
                                  ),
                                );

                                if (confirmed == true) {
                                  try {
                                    await _postService.deletePost(post.id);
                                    setState(() {
                                      // Immediately remove the post from the UI
                                      widget.onRefresh();
                                    });
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
                              } else {
                                SnackBarUtil.showCustomSnackBar(
                                  context,
                                  'You can only delete your own posts',
                                  isError: true,
                                );
                              }
                            },
                            str: "Delete",
                          )
                        : const SizedBox(),
                  ],
                ),
                const SizedBox(height: 12),
                if (post.img != null)
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        post.img!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                // Username and post text above likes and comments if there's no image
                if (post.img == null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${post.user.username} ',
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${post.text}',
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.clip,
                          softWrap: true,
                        ),
                      ),
                    ],
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
                      '${post.likes.length} Likes',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.comment, color: Colors.black),
                      onPressed: () {
                        _showTextCommentDialog(post);
                      },
                    ),
                    Text(
                      '${post.comments.length} Comments',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                // Username and post text below likes and comments if there's an image
                if (post.img != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(
                        '${post.user.username} ',
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${post.text}',
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.clip,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: widget.profile['profileImg'].isNotEmpty
                          ? NetworkImage(widget.profile['profileImg'])
                          : const AssetImage('assets/images/placeholder.png')
                              as ImageProvider,
                      radius: 15,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MyTextField(
                        controller: _commentController,
                        hintText: Text(
                          'Add a comment...',
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                        keyboardType: TextInputType.multiline,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.blue),
                      onPressed: () {
                        _addComment(onSuccess: () {
                          setState(() {}); // Refresh the dialog content
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Divider between posts
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
                      setDialogState(() {}); // Refresh the dialog state
                    }),
                  ],
                ),
              );
            },
          ),
          actions: [
            SizedBox(
              width: 100,
              child:
                  MyButton(onTap: () => Navigator.pop(context), str: 'Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCommentsSection(Post post) {
  return post.comments.isNotEmpty
      ? LayoutBuilder(
          builder: (context, constraints) {
            // Calculate the dynamic height based on the number of comments
            double dynamicHeight = post.comments.length * 40.0; // Approx. height per comment
            double maxHeight = 200; // Set the maximum height for the section

            return SizedBox(
              height: dynamicHeight > maxHeight ? maxHeight : dynamicHeight, // Use dynamic height or maxHeight
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: post.comments.length,
                separatorBuilder: (_, __) => const Divider(height: 10),
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
              ),
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


  Widget _buildBottomSection(Post post, void Function() setDialogState) {
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
                _toggleLike(onSuccess: setDialogState);
              },
            ),
            if (post.likes.isNotEmpty)
              FutureBuilder<String?>(
                future:
                    getLikedByFollower(post.likes, widget.profile['followers']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text(
                      'Loading likes...',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Text(
                      'Error loading likes',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    );
                  }

                  final likedByFollower = snapshot.data;
                  if (likedByFollower != null) {
                    return Text(
                      'Liked by $likedByFollower ${post.likes.length - 1 == 0 ? '.' : 'and ${post.likes.length - 1} others}'}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    );
                  } else {
                    return Text(
                      'Liked by ${post.likes.length} ${post.likes.length == 1 ? 'person' : {
                          post.likes.length == 0 ? '.' : 'people'
                        }}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    );
                  }
                },
              ),
          ],
        ),
        Text(
          'Posted ${_formatPostDate(post.createdAt)}',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.profile['profileImg'].isNotEmpty
                  ? NetworkImage(widget.profile['profileImg'])
                  : const AssetImage('assets/images/placeholder.png')
                      as ImageProvider,
              radius: 15,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: MyTextField(
                controller: _commentController,
                hintText: Text(
                  'Add a comment...',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
                keyboardType: TextInputType.multiline,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.blue),
              onPressed: () {
                _addComment(onSuccess: setDialogState);
              },
            ),
          ],
        ),
      ],
    );
  }

  Future<String?> getLikedByFollower(
      List<dynamic> likes, List<dynamic> followers) async {
    // Ensure both likes and followers are properly typed as List<String>
    List<String> likeIds = likes.map((e) => e.toString()).toList();
    List<String> followerIds = followers.map((e) => e.toString()).toList();

    // Iterate through the likes to find a match in the followers
    for (String like in likeIds) {
      if (followerIds.contains(like)) {
        try {
          // Fetch the username of the liked user
          return await UserService().getUsernameById(like);
        } catch (error) {
          // Handle any errors in fetching the username
          debugPrint('Error fetching username for userId $like: $error');
          continue; // Move to the next user if an error occurs
        }
      }
    }
    return null; // Return null if no follower liked the post
  }
}
