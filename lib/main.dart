import 'package:farmfresh/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'authentication.dart';
import 'cosumer/consumer_home_screen.dart';
import 'farmer/farmer_home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Wrapper(),
    );
  }
}

class Wrapper extends StatelessWidget {
  final AuthService _auth = AuthService();

  Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Fix: Use authStateChanges() instead of reload().asStream()
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in, check their type and redirect accordingly
          return FutureBuilder<String?>(
            future: _auth.getUserType(snapshot.data!.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.data == 'farmer') {
                return const FarmerHomeScreen();
              } else {
                return const ConsumerHomeScreen();
              }
            },
          );
        }

        // User is not logged in
        return const WelcomeScreen();
      },
    );
  }
}
