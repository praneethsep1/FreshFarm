// First, let's create a model for products
import 'package:flutter/material.dart';

import '../authentication.dart';
import '../welcome_screen.dart';

class Product {
  final String name;
  final double price;
  final String unit;
  final String image;
  final String farmerName;
  bool isAvailable;

  Product({
    required this.name,
    required this.price,
    required this.unit,
    required this.image,
    required this.farmerName,
    this.isAvailable = true,
  });
}

// Farmer Home Screen
class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({super.key});

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  final List<Product> myProducts = [
    Product(
        name: 'Fresh Tomatoes',
        price: 2.5,
        unit: 'kg',
        image: 'assets/tomatoes.jpg',
        farmerName: 'John\'s Farm'),
    Product(
        name: 'Organic Potatoes',
        price: 1.8,
        unit: 'kg',
        image: 'assets/potatoes.jpg',
        farmerName: 'John\'s Farm'),
    // Add more products
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Dashboard'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Text("Sign out"),
          onPressed: (){
        AuthService().signOut();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                (route) => false,
          );
        }
      }),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Sales',
                      '\$15,280',
                      Icons.monetization_on,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Active Orders',
                      '8',
                      Icons.shopping_basket,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Orders Section
              const Text(
                'Recent Orders',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildOrdersList(),

              const SizedBox(height: 24),

              // My Products Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Products',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to add product screen
                    },
                    child: const Text('+ Add New'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildProductsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.shopping_bag, color: Colors.white),
            ),
            title: Text('Order #${1001 + index}'),
            subtitle: const Text('2 items • \$450'),
            trailing: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Accept'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: myProducts.length,
      itemBuilder: (context, index) {
        final product = myProducts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: AssetImage(product.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${product.price}/${product.unit}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: product.isAvailable,
                  onChanged: (value) {
                    setState(() {
                      product.isAvailable = value;
                    });
                  },
                  activeColor: Colors.green,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
