import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:x_frontend/models/post.model.dart';
import 'package:x_frontend/widgets/my_button.dart';
import '../../services/post_service.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  const ProfileScreen({Key? key, required this.profile}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<List<Post>> _userPosts;
  late Map<String, dynamic> _profile;
  final PostService _postService = PostService();

  @override
  void initState() {
    super.initState();
    _profile = Map<String, dynamic>.from(widget.profile);
    _userPosts = _postService
        .getUserPosts(widget.profile['username']); // Fetch user posts
  }

  @override
  Widget build(BuildContext context) {
    print(_postService.getUserPostsLength(_profile['username']).toString());

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
            // Profile Info Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Avatar
                  CircleAvatar(
                    backgroundImage: _profile['profileImg'] != null &&
                            _profile['profileImg'].isNotEmpty
                        ? NetworkImage(_profile['profileImg'])
                        : const AssetImage('assets/images/placeholder.png')
                            as ImageProvider,
                    radius: 100,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Username and Edit Profile Button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                _profile['username'] ?? 'Unknown User',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              // EDIT PROFILE
                              SizedBox(
                                  height: 45,
                                  width: 200,
                                  child: MyButton(
                                      onTap: () {}, str: "Edit Profile"))
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Stats Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FutureBuilder<int>(
                              future: _postService
                                  .getUserPostsLength(_profile['username']),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  // Show a loading indicator while the data is being fetched
                                  return _buildStatItem(
                                    context,
                                    title: 'Posts',
                                    value: '...',
                                  );
                                } else if (snapshot.hasError) {
                                  // Handle errors gracefully
                                  return _buildStatItem(
                                    context,
                                    title: 'Posts',
                                    value: 'Error',
                                  );
                                } else {
                                  // Display the post count once the data is available
                                  return _buildStatItem(
                                    context,
                                    title: 'Posts',
                                    value: snapshot.data.toString(),
                                  );
                                }
                              },
                            ),
                            _buildStatItem(
                              context,
                              title: 'Followers',
                              value: _profile['followers']?.length.toString() ??
                                  '0',
                            ),
                            _buildStatItem(
                              context,
                              title: 'Following',
                              value: _profile['following']?.length.toString() ??
                                  '0',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Full Name
            if (_profile['fullName'] != null && _profile['fullName'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  _profile['fullName'],
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            // Bio
            if (_profile['bio'] != null && _profile['bio'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  _profile['bio'],
                  textAlign: TextAlign.left,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // User Posts Section
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
                final crossAxisCount =
                    screenWidth > 600 ? 3 : 2; // 3 columns if wide screen

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1, // Ensures square-like appearance
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 3,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: post.img != null
                            ? Image.network(
                                post.img!,
                                fit: BoxFit.cover,
                              )
                            : Center(
                                child: Text(
                                  post.text.isNotEmpty
                                      ? post.text
                                      : "No Content",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                      ),
                    );
                  },
                );
              },
            )
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
  
}
