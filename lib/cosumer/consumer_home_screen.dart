import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../authentication.dart';
import '../app_constants.dart';
import '../models.dart';
import '../notification_service.dart';
import 'consumer_product_listing.dart';
import 'consumer_cart_screen.dart';
import 'consumer_order_history_screen.dart';
import 'consumer_profile_screen.dart'; // Add this import

class ConsumerHomeScreen extends StatefulWidget {
  final int initialIndex;
  const ConsumerHomeScreen({super.key, this.initialIndex = 0});

  @override
  _ConsumerHomeScreenState createState() => _ConsumerHomeScreenState();
}

class _ConsumerHomeScreenState extends State<ConsumerHomeScreen> {
  late int _selectedIndex;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _notificationService.initialize(context);
  }

  final List<Widget> _pages = [
    const ConsumerProductListing(),
    const ConsumerCartScreen(),
    const ConsumerOrderHistoryScreen(),
    const ConsumerProfileScreen(), // Replace the commented-out line
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}
