import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About XLinkify',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A2E),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/LinkifyLogo.png', // Replace with your logo path
                          height: 100,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Welcome to XLinkify',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'What is XLinkify?',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'XLinkify is your personalized social media experience designed to connect you with your friends and the world. '
                'With features like the Watchlist and World Feed, you can control what you see and share your thoughts creatively.',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
              ),
              const SizedBox(height: 16),
              Text(
                'Watchlist Feed',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The Watchlist Feed is a personalized feed displaying posts only from people you have added to your Watchlist. '
                'This allows you to keep track of updates from your closest friends or favorite users.',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
              ),
              const SizedBox(height: 16),
              Text(
                'World Feed',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The World Feed showcases posts from all users on the platform, letting you explore and discover content '
                'from people outside your Watchlist. It’s perfect for finding inspiration and new connections!',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
              ),
              const SizedBox(height: 16),
              Text(
                'Who Am I?',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'I am Majd, the creator of XLinkify. I designed this platform to provide a balance between personalization and exploration. '
                'Feel free to explore and share your creativity with the community!',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
              ),
              const SizedBox(height: 16),
              Text(
                'Frequently Asked Questions',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.help_outline, color: Colors.blueAccent),
                title: Text(
                  'How do I add someone to my Watchlist?',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Search for a user and tap "Add to Watchlist" from the search results.',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.help_outline, color: Colors.blueAccent),
                title: Text(
                  'Can I remove someone from my Watchlist?',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Yes! Press on the search button, look for their profile, and tap "Remove from Watchlist."',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.help_outline, color: Colors.blueAccent),
                title: Text(
                  'Can I switch between feeds?',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Yes! Use the tabs on the Feed screen to switch between the Watchlist Feed and the World Feed.',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Thank you for being part of XLinkify!',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
