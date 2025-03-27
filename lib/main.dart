import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'app_constants.dart';
import 'authentication.dart';
import 'splashscreen.dart';
import 'welcome_screen.dart';
import 'cosumer/consumer_home_screen.dart';
import 'farmer/farmer_home_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<ProductRepository>(
          create: (_) => ProductRepository(),
        ),
      ],
      child: MaterialApp(
        home: const Wrapper(),
        routes: {
          '/farmer': (context) => const FarmerHomeScreen(),
          '/consumer': (context) => const ConsumerHomeScreen(),
          '/farmer_orders': (context) =>
              const FarmerHomeScreen(initialIndex: 1), // Orders tab
          '/consumer_orders': (context) =>
              const ConsumerHomeScreen(initialIndex: 2), //
        },
      ),
    );
  }
}

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<UserType?>(
            future: authService.getUserType(snapshot.data!.uid),
            builder: (context, typeSnapshot) {
              if (typeSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              return typeSnapshot.data == UserType.farmer
                  ? const FarmerHomeScreen()
                  : const ConsumerHomeScreen();
            },
          );
        }

        return const WelcomeScreen();
      },
    );
  }
}
