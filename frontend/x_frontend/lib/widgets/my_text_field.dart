import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final Text hintText;
  final TextInputType keyboardType;
  final bool obscureText; // Add this parameter

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.keyboardType,
    this.obscureText = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: TextField(
        obscureText: obscureText, // Use this property to hide input
        style: GoogleFonts.poppins(
          color: Colors.black,
        ),
        controller: controller,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black38, width: 1.3),
          ),
          fillColor: Colors.grey.shade200,
          filled: true,
          hintText: hintText.data,
          hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
        ),
      ),
    );
  }
}
