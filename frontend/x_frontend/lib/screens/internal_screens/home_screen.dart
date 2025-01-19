import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:x_frontend/screens/internal_screens/feed_screen.dart';
import 'package:x_frontend/screens/internal_screens/information_screen.dart';
import 'package:x_frontend/screens/internal_screens/notification_screen.dart';
import 'package:x_frontend/screens/internal_screens/profile_screen.dart';
import 'package:x_frontend/screens/internal_screens/search_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  const HomeScreen({Key? key, required this.profile}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Widget> _screens;
  int _selectedIndex = 0; // Track the selected index

  @override
  void initState() {
    super.initState();

    _screens = [
      FeedScreen(
        profile: widget.profile, // Use profile directly from widget
      ),
      ProfileScreen(
        profile: widget.profile, // Use profile directly from widget
      ),
      NotificationsScreen(
        profile: widget.profile, // Notifications Screen
      ),
      SearchScreen(profile: widget.profile),
      InformationScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Check for smaller screens
    if (screenWidth < 1250) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Sorry, this application is best experienced on larger devices.\nTry using a bigger screen!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          // Sidebar with 20% of the screen width
          Flexible(
            flex: screenWidth > 1300 ? 2 : 2, // 20%
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
                      _buildNavItem(Icons.search, 'Search', 3),
                      _buildNavItem(Icons.info_rounded, 'Information', 4),
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
          // Right-hand side (Daily Highlights)
          if (_selectedIndex == 0) // Only show for Feed screen
            Flexible(
              flex: screenWidth > 1300 ? 2 : 2, // 20%
              child: Container(
                color: const Color(0xFF1A1A2E),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center content vertically
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Center content horizontally
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment
                            .center, // Center the avatar and text
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(
                              widget.profile['profileImg'] ??
                                  "assets/images/placeholder.png",
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                      child: Text(
                        "Daily Highlights",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            "\"The only limit to our realization of tomorrow is our doubts of today.\" \n\n- Franklin D. Roosevelt",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
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

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index; // Update the selected index
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.3),
                    blurRadius: 6,
                    spreadRadius: 0.5,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[400],
              size: 24,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.white : Colors.grey[400],
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
