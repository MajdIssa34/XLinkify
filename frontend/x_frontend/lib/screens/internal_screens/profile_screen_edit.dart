import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:x_frontend/services/user_service.dart';
import 'package:x_frontend/widgets/my_button.dart';
import 'package:x_frontend/widgets/my_text_field.dart';
import 'package:x_frontend/widgets/snack_bar.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  final Function(Map<String, dynamic>) onProfileUpdated;

  const EditProfileScreen({
    Key? key,
    required this.profile,
    required this.onProfileUpdated,
  }) : super(key: key);
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  Uint8List? _profileImage;

  bool _isUploadingImage = false; // Track image upload
  bool _isUpdatingProfile = false; // Track profile update

  @override
  void initState() {
    super.initState();
    // Pre-fill fields with existing profile data
    _fullNameController.text = widget.profile['fullName'] ?? '';
    _usernameController.text = widget.profile['username'] ?? '';
    _emailController.text = widget.profile['email'] ?? '';
    _bioController.text = widget.profile['bio'] ?? '';
    _linkController.text = widget.profile['link'] ?? '';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _isUploadingImage = true; // Start image upload loading
      });

      try {
        final bytes = await pickedFile.readAsBytes(); // Read the image bytes
        setState(() {
          _profileImage = bytes; // Store the image as Uint8List
        });

        // Show success snack bar with a log out prompt
        SnackBarUtil.showCustomSnackBar(
          context,
          'Image uploaded successfully! Please log out and log back in to see the changes.',
        );
      } catch (error) {
        SnackBarUtil.showCustomSnackBar(
          context,
          'Error uploading image: ${error.toString()}',
          isError: true,
        );
      } finally {
        setState(() {
          _isUploadingImage = false; // Stop image upload loading
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUpdatingProfile = true; // Start profile update loading
    });

    final updatedData = {
      "fullName": _fullNameController.text.trim(),
      "username": _usernameController.text.trim(),
      "email": _emailController.text.trim(),
      "bio": _bioController.text.trim(),
      "link": _linkController.text.trim(),
      'profileImg': _profileImage != null
          ? base64Encode(_profileImage!) // Convert to base64
          : null,
      "currentPassword": _oldPasswordController.text.trim(),
      "newPassword": _newPasswordController.text.trim(),
    };

    try {
      final updatedProfile = await _userService.updateUser(updatedData);

      // Notify parent about the profile update
      widget.onProfileUpdated(updatedProfile);

      SnackBarUtil.showCustomSnackBar(
        context,
        'Profile updated successfully!',
      );
      Navigator.pop(context);
    } catch (error) {
      SnackBarUtil.showCustomSnackBar(
        context,
        'Error: $error',
        isError: true,
      );
    } finally {
      setState(() {
        _isUpdatingProfile = false; // Stop profile update loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
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
      body: Padding(
        padding: const EdgeInsets.all(70),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 100,
                          backgroundImage: _profileImage != null
                              ? MemoryImage(_profileImage!)
                              : NetworkImage(widget.profile['profileImg'] ?? '')
                                  as ImageProvider,
                        ),
                        if (_isUploadingImage)
                          const CircularProgressIndicator(), // Show loading on image upload
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                MyTextField(
                  controller: _fullNameController,
                  hintText: Text('Full Name'),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: _usernameController,
                  hintText: Text('Username'),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: _emailController,
                  hintText: Text('Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: _bioController,
                  hintText: Text('Bio'),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: _linkController,
                  hintText: Text('Link'),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 20),
                Text(
                  'Change Password',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: _oldPasswordController,
                  hintText: Text('Old Password'),
                  keyboardType: TextInputType.text,
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: _newPasswordController,
                  hintText: Text('New Password'),
                  keyboardType: TextInputType.text,
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: _isUpdatingProfile
                      ? const Center(
                          child:
                              CircularProgressIndicator(), // Show loading on update
                        )
                      : MyButton(
                          onTap: _updateProfile,
                          str: 'Update Profile',
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
