import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:x_frontend/state/user_state.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserState(), // Provide the UserState globally
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Social Media App',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
        },
      ),
    );
  }
}
