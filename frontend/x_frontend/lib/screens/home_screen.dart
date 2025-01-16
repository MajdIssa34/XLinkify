import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:x_frontend/screens/internal_screens/feed_screen.dart';
import 'package:x_frontend/screens/internal_screens/notification_screen.dart';
import 'package:x_frontend/screens/internal_screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({Key? key, required this.username}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Map<String, String>> suggestedFriends = [
    {"name": "John Doe", "image": ""},
    {"name": "Jane Smith", "image": ""},
    {"name": "Alex Johnson", "image": ""},
  ];

  final List<Widget> _screens = [
    const FeedScreen(),
    const ProfileScreen(),
    const NotificationsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
                        height: 250,
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
          // Main Content
          Expanded(
            child: _screens[_selectedIndex],
          ),
          // Right Panel for Suggested Friends
          Container(
            width: screenWidth > 800 ? 250 : 200,
            color: const Color(0xFFF7F7F7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Suggested Friends',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
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
                                  : const AssetImage('assets/images/placeholder.png')
                                      as ImageProvider,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                friend['name']!,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
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
        _onItemTapped(index);
      },
    );
  }
}
