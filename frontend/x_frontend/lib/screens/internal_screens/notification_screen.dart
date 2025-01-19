import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:x_frontend/services/notification_service.dart';
import 'package:x_frontend/widgets/snack_bar.dart';

class NotificationsScreen extends StatefulWidget {
  final Map<String, dynamic> profile;

  const NotificationsScreen({Key? key, required this.profile})
      : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  late Future<List<dynamic>> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = _notificationService.getNotifications();
  }

  Future<void> _clearNotifications() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Clear All Notifications',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete all notifications? This action cannot be undone.',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Confirm',
                style: GoogleFonts.poppins(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _notificationService.clearNotifications();
        SnackBarUtil.showCustomSnackBar(
            context, "Notifications cleared successfully!");
        setState(() {
          _notifications = Future.value([]); // Clear notifications from the UI
        });
      } catch (error) {
        SnackBarUtil.showCustomSnackBar(
          context,
          "Failed to clear notifications: $error",
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all, color: Colors.black),
            onPressed: () async {
              await _clearNotifications();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _notifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load notifications.',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No notifications available.',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final notifications = snapshot.data!;
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: notification['from']['profileImg'] != null &&
                          notification['from']['profileImg'].isNotEmpty
                      ? NetworkImage(notification['from']['profileImg'])
                      : const AssetImage('assets/images/placeholder.png')
                          as ImageProvider,
                ),
                title: Text(
                  notification['from']['username'] ?? 'Unknown User',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  notification['description'],
                  style: GoogleFonts.poppins(),
                ),
                trailing: Text(
                  _formatTimeAgo(DateTime.parse(notification['createdAt'])),
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
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
}
