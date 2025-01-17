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

  Future<void> _toggleLike() async {
    try {
      setState(() {
        if (widget.post.likes.contains(widget.profile['_id'])) {
          widget.post.likes.remove(widget.profile['_id']);
        } else {
          widget.post.likes.add(widget.profile['_id']);
        }
      });
      await _postService.toggleLike(widget.post.id, widget.profile['_id']);
    } catch (error) {
      setState(() {
        if (widget.post.likes.contains(widget.profile['_id'])) {
          widget.post.likes.add(widget.profile['_id']);
        } else {
          widget.post.likes.remove(widget.profile['_id']);
        }
      });
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
      setState(() {
        widget.post.comments.add(
          Comment(
            text: commentText,
            user: User.fromJson(widget.profile),
          ),
        );
      });

      await _postService.addComment(
        widget.post.id,
        widget.profile['_id'],
        commentText,
      );

      _commentController.clear();
      if (onSuccess != null) onSuccess(); // Refresh the dialog content
    } catch (error) {
      setState(() {
        widget.post.comments.removeWhere((c) => c.text == commentText);
      });

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
    return Card(
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
                          : const AssetImage('assets/images/placeholder.png')
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
            const SizedBox(height: 12),
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
                    _showCommentDialog(post);
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
            Row(
              children: [
                Text(
                  '${post.user.username} ',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${post.text}',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const Divider(),
            if (post.comments.isNotEmpty)
              Column(
                children: [
                  ...post.comments.take(3).map((comment) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              const AssetImage('assets/images/placeholder.png'),
                          radius: 15,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                '${comment.user.username}',
                                style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${comment.text}',
                                style: GoogleFonts.poppins(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  if (post.comments.length > 3)
                    TextButton(
                      onPressed: () {
                        _showCommentDialog(post);
                      },
                      child: Text(
                        'View all ${post.comments.length} comments',
                        style: GoogleFonts.poppins(color: Colors.blue),
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
    );
  }

  void _showCommentDialog(Post post) {
    if (post.img != null) {
      _showImageCommentDialog(post);
    } else {
      _showTextCommentDialog(post);
    }
  }

  void _showImageCommentDialog(Post post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    post.img!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
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
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const Divider(),
                    _buildCommentsSection(post),
                    const Divider(),
                    _buildBottomSection(post),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: 100,
            child: MyButton(onTap: () => Navigator.pop(context), str: 'Close'),
          ),
        ],
      ),
    );
  }

  void _showTextCommentDialog(Post post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        content: SizedBox(
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
                        : const AssetImage('assets/images/placeholder.png')
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
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const Divider(),
              _buildCommentsSection(post),
              const Divider(),
              _buildBottomSection(post),
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: 100,
            child: MyButton(onTap: () => Navigator.pop(context), str: 'Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection(Post post) {
    return post.comments.isNotEmpty
        ? SizedBox(
            height: 200, // Limit comment list height
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

  Widget _buildBottomSection(Post post) {
    // Helper to format time ago
    String formatTimeAgo(DateTime dateTime) {
      final Duration diff = DateTime.now().difference(dateTime);

      if (diff.inDays >= 1) {
        return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
      } else if (diff.inHours >= 1) {
        return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
      } else if (diff.inMinutes >= 1) {
        return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () {
                // Handle like functionality
              },
            ),
            Text(
              '${post.likes.length} Likes',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.comment, color: Colors.grey),
              onPressed: () {
                // Handle comment functionality
              },
            ),
          ],
        ),
        if (post.likes.isNotEmpty)
          FutureBuilder<String?>(
            future: getLikedByFollower(post.likes, widget.profile['followers']),
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
                  'Liked by $likedByFollower and ${post.likes.length - 1} others',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                );
              } else {
                return Text(
                  'Liked by ${post.likes.length} ${post.likes.length == 1 ? 'person' : 'people'}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                );
              }
            },
          ),
        Text(
          'Posted ${formatTimeAgo(post.createdAt)}', // Format the post's creation time
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
                _addComment();
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
