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
      // NotificationsScreen(
      //     profile: widget.profile), // Index 2: Notifications Screen
    ];
    // Fetch suggested friends
    _suggestedFriends = _userService.getSuggestedUsers();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Check for smaller screens
    if (screenWidth < 1350) {
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
              flex: screenWidth > 1300 ? 2 : 2, // 20%
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
                                  "assets/images/placeholder.png",
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
                    // Suggested Friends List
                    Flexible(
                      flex: screenWidth > 1300 ? 4 : 2, // 20%
                      child: Container(
                        color: const Color(0xFF1A1A2E),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(color: Colors.grey.shade800),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                "Suggested for you",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            FutureBuilder<List<dynamic>>(
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
                                      style: GoogleFonts.poppins(
                                          color: Colors.redAccent),
                                    ),
                                  );
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return Center(
                                    child: Text(
                                      "No suggestions available",
                                      style: GoogleFonts.poppins(
                                          color: Colors.grey),
                                    ),
                                  );
                                }

                                final friends = snapshot.data!;
                                return Expanded(
                                  child: ListView.builder(
                                    itemCount: friends.length,
                                    itemBuilder: (context, index) {
                                      final friend = friends[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0, horizontal: 16.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1A1A2E),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                blurRadius: 5,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                friend['profileImg'] ??
                                                    "assets/images/placeholder.png",
                                              ),
                                              radius: 24,
                                            ),
                                            title: Text(
                                              friend['username'] ?? '',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            subtitle: Text(
                                              friend['fullName'] ?? '',
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                color: Colors.grey[400],
                                              ),
                                            ),
                                            trailing: ElevatedButton(
                                              onPressed: () async {
                                                try {
                                                  await _userService.followUser(
                                                      friend['_id']);
                                                  SnackBarUtil
                                                      .showCustomSnackBar(
                                                    context,
                                                    'Followed ${friend['username']}!',
                                                  );
                                                  setState(() {
                                                    _suggestedFriends =
                                                        _userService
                                                            .getSuggestedUsers();
                                                  });
                                                } catch (e) {
                                                  SnackBarUtil
                                                      .showCustomSnackBar(
                                                    context,
                                                    'Error: ${e.toString()}',
                                                    isError: true,
                                                  );
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.blueAccent,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8.0,
                                                        horizontal: 16.0),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: Text(
                                                'Follow',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
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
      duration: const Duration(milliseconds: 150), // Reduced duration for snappier transitions
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isSelected ? null : Colors.black.withOpacity(0.1), // Slightly lighter background
        borderRadius: BorderRadius.circular(10), // Smaller corner radius for subtle design
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.3), // Lighter shadow for reduced load
                  blurRadius: 6, // Reduced blur for performance
                  spreadRadius: 0.5, // Subtle spread
                  offset: const Offset(0, 2), // Smaller offset
                ),
              ]
            : [],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12), // Reduced padding
      child: Row(
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey[400],
            size: 24, // Slightly smaller size for faster rendering
          ),
          const SizedBox(width: 6), // Reduced spacing between icon and text
          Text(
            label,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.white : Colors.grey[400],
              fontSize: 14, // Slightly smaller text for consistency
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ],
      ),
    ),
  );
}

}
