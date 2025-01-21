import 'package:animations/animations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:x_frontend/screens/internal_screens/feed_screen.dart';
import 'package:x_frontend/screens/internal_screens/information_screen.dart';
import 'package:x_frontend/screens/internal_screens/notification_screen.dart';
import 'package:x_frontend/screens/internal_screens/profile_screen.dart';
import 'package:x_frontend/screens/internal_screens/search_screen.dart';
import 'package:x_frontend/services/auth_service.dart';
import 'package:x_frontend/services/quote_service.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  const HomeScreen({Key? key, required this.profile}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  QuoteService quoteService = QuoteService();
  AuthService authService = AuthService();
  late List<Widget> _screens;
  int _selectedIndex = 0; // Track the selected index
  String _quote = "Loading daily quote...";
  String? _author;

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

    _fetchQuote();
  }

  Future<void> _fetchQuote() async {
    try {
      final quoteData = await quoteService.getDailyQuote(); // Fetch quote data
      setState(() {
        _quote = quoteData['quote'] ?? "No quote available.";
        _author = quoteData['author'];
      });
    } catch (error) {
      setState(() {
        _quote = "Failed to fetch quote.";
        _author = null;
      });
    }
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
                      onPressed: () async {
                        // Call the logout method
                        try {
                          await AuthService()
                              .logout(); // Ensure your AuthService has a logout method
                          Navigator.pushReplacementNamed(
                              context, '/'); // Redirect to login screen
                        } catch (error) {
                          // Show an error message if logout fails
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Logout failed: $error',
                                style: GoogleFonts.poppins(color: Colors.white),
                              ),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 4,
                        shadowColor: Colors.redAccent.withOpacity(0.5),
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
                      MainAxisAlignment.spaceBetween, // Space between items
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Center horizontally
                  children: [
                    // Top Section: Avatar and Info
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // Center horizontally
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

                    // Middle Section: Quote
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center, // Center vertically
                          crossAxisAlignment:
                              CrossAxisAlignment.center, // Center horizontally
                          children: [
                            Text(
                              "Daily Highlights",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            FutureBuilder<Map<String, String>>(
                              future: quoteService.getDailyQuote(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      "Failed to fetch daily quote., ${snapshot.error}",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.redAccent,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  );
                                } else if (snapshot.hasData) {
                                  final quote = snapshot.data?['quote'] ??
                                      "No quote available.";
                                  final author =
                                      snapshot.data?['author'] ?? "Unknown";
                                  return Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      "\"$quote\" \n\n- $author",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  );
                                } else {
                                  return Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      "No quote available.",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom Section: Footer
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          '© 2025 XLinkify by Majd',
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
            )
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
