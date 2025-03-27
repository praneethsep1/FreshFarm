import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

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

  void _showSnackBar(BuildContext context, String? title, String? body) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title\n$body'),
        duration: const Duration(seconds: 5),
      ),
    );
  }

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
