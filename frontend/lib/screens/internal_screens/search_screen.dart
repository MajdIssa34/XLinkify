import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:x_frontend/screens/internal_screens/profile_screen.dart';
import 'package:x_frontend/services/user_service.dart';
import 'package:x_frontend/widgets/snack_bar.dart';

class SearchScreen extends StatefulWidget {
  final Map<String, dynamic> profile;

  const SearchScreen({Key? key, required this.profile}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  int? _hoveredIndex;

  Future<void> _searchUsers(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await UserService().searchUsers(query);
      if (mounted) {
        setState(() {
          _searchResults = results
              .where((user) => user['_id'] != widget.profile['_id'])
              .toList(); // Exclude self
        });
      }
    } catch (error) {
      if (mounted) {
        SnackBarUtil.showCustomSnackBar(
          context,
          'Error searching users: $error',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleWatchlist(String userId, String username) async {
    try {
      final result = await UserService().addToWatchlist(userId);
      if (result['action'] == 'added') {
        SnackBarUtil.showCustomSnackBar(
          context,
          '$username has been added to your watchlist.',
        );
        setState(() {
          widget.profile['watchlist'].add(userId);
        });
      } else if (result['action'] == 'removed') {
        SnackBarUtil.showCustomSnackBar(
          context,
          '$username has been removed from your watchlist.',
        );
        setState(() {
          widget.profile['watchlist'].remove(userId);
        });
      }
    } catch (error) {
      SnackBarUtil.showCustomSnackBar(
        context,
        'Failed to update watchlist: $error',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search Users',
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by username...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onSubmitted: (query) {
                if (query.isNotEmpty) {
                  _searchUsers(query);
                }
              },
            ),
          ),
          _isLoading
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()))
              : Expanded(
                  child: _searchResults.isEmpty
                      ? Center(
                          child: Text(
                            'No users found.',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final user = _searchResults[index];
                            final isInWatchlist = widget.profile['watchlist']
                                .contains(user['_id']);
                            final isHovered = _hoveredIndex == index;

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfileScreen(
                                      profile: user,
                                    ),
                                  ),
                                );
                              },
                              child: MouseRegion(
                                onEnter: (_) => setState(() => _hoveredIndex = index),
                                onExit: (_) => setState(() => _hoveredIndex = null),
                                child: Card(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 2,
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: user['profileImg'] !=
                                                  null &&
                                              user['profileImg'].isNotEmpty
                                          ? NetworkImage(user['profileImg'])
                                          : const AssetImage(
                                                  'assets/images/placeholder.png')
                                              as ImageProvider,
                                      radius: 25,
                                    ),
                                    title: Text(
                                      user['username'] ?? 'Unknown User',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        color: isHovered
                                            ? Colors.blue
                                            : Colors.black,
                                      ),
                                    ),
                                    subtitle: Text(
                                      user['fullName'] ?? 'No full name provided',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    trailing: user['_id'] == widget.profile['_id']
                                        ? null // Hide button for self
                                        : ElevatedButton(
                                            onPressed: () {
                                              _toggleWatchlist(
                                                user['_id'],
                                                user['username'],
                                              );
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
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
        ],
      ),
    );
  }
}
