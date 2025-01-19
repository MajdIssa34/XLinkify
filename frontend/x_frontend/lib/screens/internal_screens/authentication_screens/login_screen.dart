import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:x_frontend/screens/internal_screens/home_screen.dart';
import 'package:x_frontend/screens/internal_screens/authentication_screens/signup_screen.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/my_text_field.dart';
import '../../../widgets/my_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _authService.login(
        _usernameController.text,
        _passwordController.text,
      );
     //print(response['username']);
      // Replace the current screen with HomeScreen and clear the stack
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              HomeScreen(profile: response),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
        (route) => false, // Remove all previous routes
      );
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }
}


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6DD5FA), // Light Blue
              Color(0xFF2980B9), // Dark Blue
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Section
                Image.asset(
                  'assets/images/LinkifyLogo.png',
                  height: screenHeight * 0.3, // Dynamically adjust logo size
                ),
                const SizedBox(height: 20),
                // Login Form
                Container(
                  width: screenWidth > 400 ? 400 : screenWidth * 0.8,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'Welcome Back!',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth > 400 ? 24 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Please login to your account',
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      if (_errorMessage != null)
                        AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(milliseconds: 500),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: SelectableText(
                                      _errorMessage!,
                                      style: GoogleFonts.poppins(
                                        color: Colors.red.shade700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            MyTextField(
                              controller: _usernameController,
                              hintText: const Text('Enter your username'),
                              keyboardType: TextInputType.text,
                            ),
                            const SizedBox(height: 16),
                            MyTextField(
                              controller: _passwordController,
                              hintText: const Text('Enter your password'),
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: true,
                            ),
                            const SizedBox(height: 20),
                            _isLoading
                                ? const CircularProgressIndicator()
                                : MyButton(
                                    onTap: _login,
                                    str: 'Login',
                                  ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const SignupScreen(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        child: Text(
                          'Don\'t have an account? Sign Up',
                          style: GoogleFonts.poppins(
                            color: Colors.blue,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}