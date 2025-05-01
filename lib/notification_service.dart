import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Manages Firebase Cloud Messaging (FCM) notifications for the application.
///
/// Handles initialization, permission requests, token management, and notification
/// processing for foreground, background, and app-opened scenarios.

class NotificationService {
  /// The [FirebaseMessaging] instance for handling FCM operations.
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// Initializes FCM notifications and sets up message handlers.
  ///
  /// Requests notification permissions, saves the FCM token, and configures handlers
  /// for foreground messages, app-opened notifications, and initial messages.
  ///
  /// Parameters:
  ///   - context: The [BuildContext] used for showing SnackBars and navigation.
  ///
  /// Returns:
  ///   A [Future<void>] that completes when initialization is done.

  Future<void> initialize(BuildContext context) async {
    // Request permission (iOS requires this)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }

    // Get and save the FCM token
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      await _saveTokenToFirestore(token);
    }

    // Handle token refresh
    _firebaseMessaging.onTokenRefresh.listen(_saveTokenToFirestore);

    // Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      if (message.notification != null) {
        _showSnackBar(
            context, message.notification!.title, message.notification!.body);
      }
    });

    // Handle message when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
      _navigateBasedOnMessage(context, message);
    });

    // Handle initial message (app opened from terminated state)
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _navigateBasedOnMessage(context, initialMessage);
    }
  }

  /// Saves the FCM token to Firestore for a user.
  ///
  /// Stores the token in the user's Firestore document for push notification targeting.
  ///
  /// Parameters:
  ///   - token: The FCM token to be saved.
  ///
  /// Returns:
  ///   A [Future<void>] that completes when the token is saved.
  ///
  /// Note:
  ///   The user ID is currently incorrectly set to [FirebaseMessaging.instance].
  ///   It should be replaced with the actual user ID from [AuthService].

  Future<void> _saveTokenToFirestore(String token) async {
    final userId = FirebaseMessaging
        .instance; // Replace with actual user ID from AuthService
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId.toString())
        .set({
      'fcmToken': token,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Displays a SnackBar with the notification's title and body.
  ///
  /// Parameters:
  ///   - context: The [BuildContext] for showing the SnackBar.
  ///   - title: The title of the notification (optional).
  ///   - body: The body of the notification (optional).

  void _showSnackBar(BuildContext context, String? title, String? body) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title\n$body'),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  /// Navigates to the appropriate screen based on the notification's data.
  ///
  /// Routes to farmer or consumer order screens based on the notification type.
  ///
  /// Parameters:
  ///   - context: The [BuildContext] for navigation.
  ///   - message: The [RemoteMessage] containing navigation data.

  void _navigateBasedOnMessage(BuildContext context, RemoteMessage message) {
    final data = message.data;
    if (data['type'] == 'order_placed') {
      Navigator.pushNamed(context, '/farmer_orders'); // Adjust route as needed
    } else if (data['type'] == 'order_status') {
      Navigator.pushNamed(
          context, '/consumer_orders'); // Adjust route as needed
    }
  }
}
