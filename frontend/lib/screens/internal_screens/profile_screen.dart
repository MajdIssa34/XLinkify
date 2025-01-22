import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:x_frontend/models/post.model.dart';
import 'package:x_frontend/screens/internal_screens/profile_screen_edit.dart';
import 'package:x_frontend/services/auth_service.dart';
import 'package:x_frontend/services/user_service.dart';
import 'package:x_frontend/widgets/my_button.dart';
import 'package:x_frontend/widgets/snack_bar.dart';
import '../../services/post_service.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profile;

  const ProfileScreen({Key? key, required this.profile}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<List<Post>> _userPosts;
  final AuthService _authService = AuthService();
  final PostService _postService = PostService();
  final TextEditingController _commentController = TextEditingController();
  int? _postCount;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _userPosts = _postService.getUserPosts(widget.profile['username']);
    _fetchPostCount();
  }

  Future<void> _fetchPostCount() async {
    try {
      final count =
          await _postService.getUserPostsLength(widget.profile['username']);
      if (mounted) {
        setState(() {
          _postCount = count;
        });
      }
    } catch (error) {
      debugPrint('Error fetching post count: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundImage: profile['profileImg'] != null &&
                            profile['profileImg'].isNotEmpty
                        ? NetworkImage(profile['profileImg'])
                        : const AssetImage('assets/images/placeholder.png')
                            as ImageProvider,
                    radius: 100,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: FutureBuilder<Map<String, dynamic>>(
                            future: _authService.getUserDetails(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text(
                                  'Error: ${snapshot.error}',
                                  style: GoogleFonts.poppins(color: Colors.red),
                                );
                              } else if (!snapshot.hasData ||
                                  snapshot.data == null) {
                                return Text(
                                  'Unable to fetch user details.',
                                  style:
                                      GoogleFonts.poppins(color: Colors.grey),
                                );
                              }

                              final userDetails = snapshot.data!;
                              final isOwnProfile =
                                  userDetails['_id'] == profile['_id'];
                              final isInWatchlist = userDetails['watchlist']
                                  .contains(profile['_id']); // Check watchlist

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    profile['username'] ?? 'Unknown User',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  if (isOwnProfile)
                                    SizedBox(
                                      height: 45,
                                      width: 200,
                                      child: MyButton(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EditProfileScreen(
                                                profile: profile,
                                                onProfileUpdated:
                                                    (updatedProfile) {
                                                  setState(() {
                                                    widget.profile
                                                        .addAll(updatedProfile);
                                                  });
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                        str: "Edit Profile",
                                      ),
                                    ),
                                  if (!isOwnProfile)
                                    SizedBox(
                                      height: 45,
                                      width: 200,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          try {
                                            final result = await UserService()
                                                .addToWatchlist(profile['_id']);
                                            if (result['action'] == 'added') {
                                              SnackBarUtil.showCustomSnackBar(
                                                context,
                                                '${profile['username']} has been added to your watchlist.',
                                              );
                                            } else if (result['action'] ==
                                                'removed') {
                                              SnackBarUtil.showCustomSnackBar(
                                                context,
                                                '${profile['username']} has been removed from your watchlist.',
                                              );
                                            }
                                            setState(() {});
                                          } catch (error) {
                                            SnackBarUtil.showCustomSnackBar(
                                              context,
                                              'Failed to update watchlist: $error',
                                              isError: true,
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isInWatchlist
                                              ? Colors.redAccent
                                              : Colors.blueAccent,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Text(
                                          isInWatchlist
                                              ? 'Remove from Watchlist'
                                              : 'Add to Watchlist',
                                          style:
                                              GoogleFonts.poppins(fontSize: 12),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem(
                              context,
                              title: 'Posts',
                              value: _postCount?.toString() ?? '...',
                            ),
                            GestureDetector(
                              onTap: () async {
                                try {
                                  final connectionProfiles = await UserService()
                                      .getUserWatchlist(profile['username']);
                                  _showConnectionsList(context, 'Connections',
                                      connectionProfiles);
                                } catch (error) {
                                  SnackBarUtil.showCustomSnackBar(
                                    context,
                                    'Failed to fetch connections: ${error.toString()}',
                                    isError: true,
                                  );
                                }
                              },
                              child: _buildStatItem(
                                context,
                                title: 'Connections',
                                value:
                                    profile['watchlist']?.length.toString() ??
                                        '0',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (profile['fullName'] != null &&
                            profile['fullName'].isNotEmpty)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              profile['fullName'],
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        if (profile['bio'] != null && profile['bio'].isNotEmpty)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              profile['bio'],
                              textAlign: TextAlign.left,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        if (profile['link'] != null &&
                            profile['link'].isNotEmpty)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: GestureDetector(
                              onTap: () async {
                                final url = profile['link'];
                                if (await canLaunchUrl(Uri.parse(url))) {
                                  await launchUrl(Uri.parse(url),
                                      mode: LaunchMode.externalApplication);
                                } else {
                                  SnackBarUtil.showCustomSnackBar(
                                    context,
                                    'Could not open the link',
                                    isError: true,
                                  );
                                }
                              },
                              child: Text(
                                profile['link'],
                                textAlign: TextAlign.left,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Post>>(
              future: _userPosts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
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
                final screenWidth = MediaQuery.of(context).size.width;
                final crossAxisCount = screenWidth > 600 ? 3 : 2;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    final hoverNotifier =
                        ValueNotifier<bool>(false); // Local hover state

                    return ValueListenableBuilder<bool>(
                      valueListenable: hoverNotifier,
                      builder: (context, isHovered, child) {
                        return GestureDetector(
                          onTap: () => _showTextCommentDialog(post),
                          child: MouseRegion(
                            onEnter: (_) => hoverNotifier.value = true,
                            onExit: (_) => hoverNotifier.value = false,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    post.img!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                                if (isHovered)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.favorite,
                                                color: Colors.white),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${post.likes.length}',
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.comment,
                                                color: Colors.white),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${post.comments.length}',
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context,
      {required String title, required String value}) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  void _showConnectionsList(
    BuildContext context,
    String title,
    List<Map<String, dynamic>> connections,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: connections.isNotEmpty
                        ? ListView.builder(
                            itemCount: connections.length,
                            itemBuilder: (context, index) {
                              final user = connections[index];
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: user['profileImg'] !=
                                                null &&
                                            user['profileImg'].isNotEmpty
                                        ? NetworkImage(user['profileImg'])
                                        : const AssetImage(
                                                'assets/images/placeholder.png')
                                            as ImageProvider,
                                    radius: 24,
                                  ),
                                  title: Text(
                                    user['username'] ?? 'Unknown',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  subtitle: user['fullName'] != null
                                      ? Text(
                                          user['fullName'],
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        )
                                      : null,
                                  trailing: TextButton(
                                    onPressed: () async {
                                      try {
                                        final result = await UserService()
                                            .addToWatchlist(user['_id']);
                                        if (result['action'] == 'removed') {
                                          setModalState(() {
                                            connections.removeAt(index);
                                          });
                                          setState(() {
                                            widget.profile['watchlist'] = widget
                                                .profile['watchlist']
                                                .where(
                                                    (id) => id != user['_id'])
                                                .toList();
                                          });
                                        } else if (result['action'] ==
                                            'added') {
                                          setState(() {
                                            widget.profile['watchlist']
                                                .add(user['_id']);
                                          });
                                        }
                                        SnackBarUtil.showCustomSnackBar(
                                          context,
                                          '${user['username']} has been ${result['action']} to your watchlist.',
                                        );
                                      } catch (error) {
                                        SnackBarUtil.showCustomSnackBar(
                                          context,
                                          'Failed to update watchlist: $error',
                                          isError: true,
                                        );
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: Text(
                                      'Disconnect',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Text(
                              'No connections found.',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

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

  void _showTextCommentDialog(Post post) {
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<Map<String, dynamic>>(
          future: _authService.getUserDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return AlertDialog(
                content: Text(
                  'Error: ${snapshot.error}',
                  style: GoogleFonts.poppins(color: Colors.red),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data == null) {
              return AlertDialog(
                content: Text(
                  'Unable to load user details.',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              );
            }

            final loggedInUser = snapshot.data!;
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
                        _buildBottomSection(post, loggedInUser, () {
                          setDialogState(() {});
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
                    backgroundImage: comment.user.profileImg.isNotEmpty
                        ? NetworkImage(comment.user.profileImg)
                        : const AssetImage('assets/images/placeholder.png')
                            as ImageProvider,
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

  Widget _buildBottomSection(Post post, Map<String, dynamic> loggedInUser,
      void Function() refreshDialog) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(
                post.likes.contains(loggedInUser['_id'])
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: post.likes.contains(loggedInUser['_id'])
                    ? Colors.red
                    : Colors.black,
              ),
              onPressed: () {
                _toggleLike(post, loggedInUser, onSuccess: refreshDialog);
              },
            ),
            if (post.likes.isNotEmpty)
              Text(
                '${post.likes.length} ${post.likes.length == 1 ? 'like' : 'likes'}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[700],
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
                _addComment(post, loggedInUser, refreshDialog);
              },
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _toggleLike(Post post, Map<String, dynamic> loggedInUser,
      {Function? onSuccess}) async {
    try {
      final isLiked = post.likes.contains(loggedInUser['_id']);
      setState(() {
        if (isLiked) {
          post.likes.remove(loggedInUser['_id']);
        } else {
          post.likes.add(loggedInUser['_id']);
        }
      });

      await _postService.toggleLike(post.id, loggedInUser['_id']);

      if (onSuccess != null) onSuccess(); // Refresh dialog state
    } catch (error) {
      SnackBarUtil.showCustomSnackBar(
        context,
        'Error: ${error.toString()}',
        isError: true,
      );
    }
  }

  Future<void> _addComment(Post post, Map<String, dynamic> loggedInUser,
      void Function() refreshDialog) async {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;

    try {
      final newComment = Comment(
        text: commentText,
        user: User.fromJson(loggedInUser),
      );

      setState(() {
        post.comments.add(newComment);
        _commentController.clear();
      });
      refreshDialog();

      await _postService.addComment(post.id, loggedInUser['_id'], commentText);
    } catch (error) {
      SnackBarUtil.showCustomSnackBar(
        context,
        'Error: ${error.toString()}',
        isError: true,
      );
    }
  }
}
