import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:x_frontend/services/user_service.dart';
import 'package:x_frontend/widgets/my_button.dart';
import 'package:x_frontend/widgets/my_text_field.dart';
import 'package:x_frontend/widgets/snack_bar.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profile;

  const EditProfileScreen({Key? key, required this.profile}) : super(key: key);

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
  File? _profileImage;

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
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedData = {
      "fullName": _fullNameController.text.trim(),
      "username": _usernameController.text.trim(),
      "email": _emailController.text.trim(),
      "bio": _bioController.text.trim(),
      "link": _linkController.text.trim(),
      if (_oldPasswordController.text.isNotEmpty &&
          _newPasswordController.text.isNotEmpty)
        "password": {
          "old": _oldPasswordController.text,
          "new": _newPasswordController.text,
        },
    };

    try {
      // Call the updateUser function
      await _userService.updateUser(updatedData);
      SnackBarUtil.showCustomSnackBar(context, 'Profile updated successfully!');
      Navigator.pop(context); // Return to the previous screen
    } catch (error) {
      SnackBarUtil.showCustomSnackBar(context, 'Error: $error', isError: true);
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
                    child: CircleAvatar(
                      radius: 100,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : NetworkImage(widget.profile['profileImg'] ?? '')
                              as ImageProvider,
                      child: _profileImage == null
                          ? const Icon(Icons.edit, color: Colors.white)
                          : null,
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
                  child: MyButton(
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
