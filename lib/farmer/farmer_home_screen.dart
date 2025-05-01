import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../authentication.dart';
import '../app_constants.dart';
import '../models.dart';
import '../notification_service.dart';
import 'farmer_product_management.dart';
import 'farmer_order_management.dart';
import 'farmer_profile_screen.dart';
import 'farmer_sales_analytics.dart';

/// A stateful widget that serves as the main interface for farmers.
///
/// Displays a bottom navigation bar to switch between product management, order
/// management, sales analytics, and profile screens.
///
/// Parameters:
///   - initialIndex: The initial index of the bottom navigation bar (default is 0).

class FarmerHomeScreen extends StatefulWidget {
  final int initialIndex;
  const FarmerHomeScreen({super.key, this.initialIndex = 0});

  @override
  _FarmerHomeScreenState createState() => _FarmerHomeScreenState();
}

/// The state class for [FarmerHomeScreen].
///
/// Manages the state of the bottom navigation bar and initializes notifications.
/// Switches between different farmer-related screens based on user selection.

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  late int _selectedIndex;
  final NotificationService _notificationService = NotificationService();

  final List<Widget> _pages = [
    const FarmerProductManagement(),
    const FarmerOrderManagement(),
    const FarmerSalesAnalytics(),
    const FarmerProfileScreen(),
  ];

  /// Updates the selected index when a bottom navigation item is tapped.
  ///
  /// Triggers a UI refresh to display the corresponding screen.
  ///
  /// Parameters:
  ///   - index: The index of the tapped navigation item.

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Initializes the state of the widget.
  ///
  /// Sets the initial index for the bottom navigation bar and initializes the
  /// [NotificationService].

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _notificationService.initialize(context);
  }

  /// Builds the UI for the farmer home screen.
  ///
  /// Displays the currently selected screen from [_pages] and a bottom navigation
  /// bar for switching between product management, orders, analytics, and profile.
  ///
  /// Parameters:
  ///   - context: The [BuildContext] for building the widget.
  ///
  /// Returns:
  ///   A [Widget] representing the farmer home screen UI.

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
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
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
