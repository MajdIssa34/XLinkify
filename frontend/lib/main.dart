import 'package:flutter/material.dart';
import 'screens/authentication_screens/login_screen.dart';
import 'screens/authentication_screens/signup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'XLinkify',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/singup': (context) => const SignupScreen(),
      },
    );
  }
}
