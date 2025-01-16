import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:x_frontend/screens/internal_screens/feed_screen.dart';
import 'package:x_frontend/screens/internal_screens/notification_screen.dart';
import 'package:x_frontend/screens/internal_screens/profile_screen.dart';
import 'package:x_frontend/services/user_service.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  const HomeScreen({Key? key, required this.profile}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserService _userService = UserService();
  late Future<List<dynamic>> _suggestedFriends;
  late List<Widget> _screens;

  int _selectedIndex = 0; // Track the selected index

  @override
  void initState() {
    super.initState();

    _screens = [
      FeedScreen(
        profile: widget.profile,
      ), // Index 0: Feed Screen
      ProfileScreen(profile: widget.profile), // Index 1: Profile Screen
      NotificationsScreen(
          profile: widget.profile), // Index 2: Notifications Screen
    ];
    // Fetch suggested friends
    _suggestedFriends = _userService.getSuggestedUsers();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    //print(widget.profile);
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: screenWidth > 800 ? 250 : 200,
            color: const Color(0xFF1A1A2E),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset(
                        'assets/images/LinkifyLogo.png',
                        height: 100,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildNavItem(Icons.home, 'Feed', 0),
                    _buildNavItem(Icons.person, 'Profile', 1),
                    _buildNavItem(Icons.notifications, 'Notifications', 2),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main Content (Feed)
          Expanded(
            child: PageTransitionSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                return SharedAxisTransition(
                  animation: primaryAnimation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType
                      .horizontal, // Choose the transition type
                  child: child,
                );
              },
              child: _screens[
                  _selectedIndex], // Dynamically show the current screen
              key: ValueKey<int>(_selectedIndex), // Ensure smooth transition
            ),
          ),
          // Right Panel for Suggested Friends
          Container(
            width: screenWidth > 800 ? 250 : 200,
            color: const Color(0xFF000000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logged-in user's profile
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(
                          "https://via.placeholder.com/150",
                        ), // Replace with actual profile image
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.profile['username'] ?? '',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Full Name", // Replace with actual full name
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          // Handle switch account
                        },
                        child: const Text(
                          "Switch",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.grey.shade800),
                // Suggested Friends Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Suggested for you",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Handle "See All" action
                        },
                        child: Text(
                          "See All",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<dynamic>>(
                    future: _suggestedFriends,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            'No suggested friends available',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        );
                      }

                      // Suggested friends list
                      final suggestedFriends = snapshot.data!;
                      return ListView.builder(
                        itemCount: suggestedFriends.length,
                        itemBuilder: (context, index) {
                          final friend = suggestedFriends[index];
                          final hasImage = friend['image'] != null &&
                              friend['image']!.isNotEmpty;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundImage: hasImage
                                      ? NetworkImage(friend['image']!)
                                      : const AssetImage(
                                          'assets/images/placeholder.png',
                                        ) as ImageProvider,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        friend['name'] ?? '',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        "Followed by ${friend['follower'] ?? ''}",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Handle follow action
                                  },
                                  child: const Text(
                                    "Follow",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.blueAccent : Colors.white,
        size: 30,
      ),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          color: isSelected ? Colors.blueAccent : Colors.white,
          fontSize: 16,
        ),
      ),
      selected: isSelected,
      onTap: () {
        setState(() {
          _selectedIndex = index; // Update the selected index
        });
      },
    );
  }
}
