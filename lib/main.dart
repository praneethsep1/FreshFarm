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

/// Handles Firebase Cloud Messaging (FCM) background messages.
///
/// Initializes Firebase and processes background push notifications.
///
/// Parameters:
///   - message: The [RemoteMessage] received from FCM.
///
/// Returns:
///   A [Future<void>] that completes when the message is handled.

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

/// The entry point of the Flutter application.
///
/// Initializes Firebase, sets up FCM background message handling, and runs the app.
///
/// Returns:
///   A [Future<void>] that completes when initialization is done.

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

/// The root widget of the Flutter application.
///
/// Configures providers for [AuthService] and [ProductRepository], and sets up
/// the app's initial screen and navigation routes.

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Builds the app's widget tree.
  ///
  /// Wraps the app in a [MultiProvider] to provide [AuthService] and [ProductRepository],
  /// and sets up the [MaterialApp] with the [Wrapper] as the home screen and defined routes.
  ///
  /// Parameters:
  ///   - context: The [BuildContext] for building the widget.
  ///
  /// Returns:
  ///   A [Widget] representing the app's UI.

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

/// A stateless widget that determines the initial screen based on authentication state.
///
/// Listens to Firebase authentication state changes and navigates to the appropriate
/// home screen ([FarmerHomeScreen], [ConsumerHomeScreen], or [WelcomeScreen]) based
/// on the user's authentication status and type.

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  /// Builds the UI based on the user's authentication state and type.
  ///
  /// Uses a [StreamBuilder] to monitor Firebase authentication state and a
  /// [FutureBuilder] to fetch the user type, directing to the appropriate screen.
  ///
  /// Parameters:
  ///   - context: The [BuildContext] for building the widget.
  ///
  /// Returns:
  ///   A [Widget] representing the initial screen (home or welcome).

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
