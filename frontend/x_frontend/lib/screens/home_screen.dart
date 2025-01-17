import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:x_frontend/screens/internal_screens/feed_screen.dart';
import 'package:x_frontend/screens/internal_screens/notification_screen.dart';
import 'package:x_frontend/screens/internal_screens/profile_screen.dart';
import 'package:x_frontend/services/user_service.dart';
import 'package:x_frontend/widgets/snack_bar.dart';

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

    return Scaffold(
      body: Row(
        children: [
          // Sidebar with 20% of the screen width
          Flexible(
            flex: screenWidth > 1300 ? 3 : 2, // 20%
            child: Container(
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
                          height: 300,
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
          ),

          // Main content (Middle Screen)
          Flexible(
            flex: _selectedIndex == 0
                ? (screenWidth > 1300 ? 5 : 6) // 60% when Feed is active
                : (screenWidth > 1300
                    ? 7
                    : 8), // 80% for Profile or Notifications
            child: Container(
              color:
                  const Color.fromARGB(255, 214, 220, 233), // Background color
              child: Padding(
                padding: const EdgeInsets.fromLTRB(100, 20, 100, 20),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(20), // Adjust the corner radius
                  child: Container(
                    color: Colors.white, // Inner container color
                    child: PageTransitionSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (child, primaryAnimation, secondaryAnimation) {
                        return SharedAxisTransition(
                          animation: primaryAnimation,
                          secondaryAnimation: secondaryAnimation,
                          transitionType: SharedAxisTransitionType.horizontal,
                          child: child,
                        );
                      },
                      child: _screens[_selectedIndex],
                      key: ValueKey<int>(_selectedIndex),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Right-hand side (Suggested Friends)
          if (_selectedIndex == 0) // Only show for Feed screen
            Flexible(
              flex: screenWidth > 1300 ? 3 : 2, // 20%
              child: Container(
                color: const Color(0xFF1A1A2E),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(
                              widget.profile['profileImg'] ??
                                  "https://via.placeholder.com/150",
                            ),
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
                                widget.profile['fullName'] ?? '',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Divider(color: Colors.grey.shade800),
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
                        ],
                      ),
                    ),
                    Expanded(
                      child: FutureBuilder<List<dynamic>>(
                        future: _suggestedFriends,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
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
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Center(
                              child: Text(
                                'No suggested friends available',
                                style: GoogleFonts.poppins(
                                    fontSize: 16, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }

                          final suggestedFriends = snapshot.data!;

                          return ListView.builder(
                            itemCount: suggestedFriends.length,
                            itemBuilder: (context, index) {
                              final friend = suggestedFriends[index];
                              final hasImage = friend['profileImg'] != null &&
                                  friend['profileImg'].isNotEmpty;
                              final username = friend['username'] ?? 'Unknown';
                              final followers = friend['followers'] ?? [];

                              return Card(
                                color: const Color(0xFF2A2A3E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 25,
                                        backgroundImage: hasImage
                                            ? NetworkImage(
                                                friend['profileImg']!)
                                            : const AssetImage(
                                                    'assets/images/placeholder.png')
                                                as ImageProvider,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              username,
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              followers.isNotEmpty
                                                  ? "Followed by ${followers[0]}"
                                                  : "No followers yet",
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: Colors.grey.shade400,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          try {
                                            await _userService
                                                .followUser(friend['_id']);
                                            setState(() {
                                              suggestedFriends.removeAt(index);
                                            });
                                            SnackBarUtil.showCustomSnackBar(
                                                context, 'Followed $username!');
                                          } catch (error) {
                                            SnackBarUtil.showCustomSnackBar(
                                                context,
                                                'Failed to follow $username: $error',
                                                isError: true);
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                        child: const Text("Follow"),
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          '© 2025 Linkify by Majd',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
