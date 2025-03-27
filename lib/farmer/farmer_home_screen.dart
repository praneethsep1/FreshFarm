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

class FarmerHomeScreen extends StatefulWidget {
  final int initialIndex;
  const FarmerHomeScreen({super.key, this.initialIndex = 0});

  @override
  _FarmerHomeScreenState createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  late int _selectedIndex;
  final NotificationService _notificationService = NotificationService();

  final List<Widget> _pages = [
    const FarmerProductManagement(),
    const FarmerOrderManagement(),
    const FarmerSalesAnalytics(),
    const FarmerProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _notificationService.initialize(context);
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
