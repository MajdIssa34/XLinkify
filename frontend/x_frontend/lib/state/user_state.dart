import 'package:flutter/material.dart';
import 'package:x_frontend/services/user_service.dart';


class UserState extends ChangeNotifier {
  Map<String, dynamic> _profile = {};
  List<dynamic> _following = [];

  static final UserState _instance = UserState._internal();
  factory UserState() => _instance;

  UserState._internal();

  void setProfile(Map<String, dynamic> profile) {
    _profile = profile;
    _following = List.from(profile['following'] ?? []);
    notifyListeners();
  }

  Map<String, dynamic> get profile => _profile;
  List<dynamic> get following => _following;

  Future<void> toggleFollow(String userId) async {
    final isFollowing = _following.contains(userId);
    try {
      // Call API to toggle follow/unfollow
      await UserService().followUser(userId);

      // Update local state
      if (isFollowing) {
        _following.remove(userId);
      } else {
        _following.add(userId);
      }

      // Notify listeners to refresh the UI
      notifyListeners();
    } catch (error) {
      throw Exception('Error toggling follow status: $error');
    }
  }
}