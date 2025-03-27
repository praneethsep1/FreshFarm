import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../authentication.dart';
import '../models.dart';

class FarmerOrderManagement extends StatelessWidget {
  const FarmerOrderManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getFarmerOrders(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No orders yet',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final orderData = snapshot.data![index];
              return FarmerOrderCard(orderData: orderData);
            },
          );
        },
      ),
    );
  }

  Stream<List<Map<String, dynamic>>> _getFarmerOrders(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final farmerId = authService.currentUser!.uid;

    // Fetch all orders and filter in-app (Firestore doesn't support complex array queries easily)
    return FirebaseFirestore.instance
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
            (snapshot) => snapshot.docs.map((doc) => doc.data()).where((order) {
                  final items = (order['items'] as List)
                      .map((item) => CartItem.fromMap(item))
                      .toList();
                  return items.any((item) => item.farmerId == farmerId);
                }).toList());
  }
}

class FarmerOrderCard extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const FarmerOrderCard({super.key, required this.orderData});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Processing':
        return Colors.blue;
      case 'Shipped':
        return Colors.purple;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final farmerId = authService.currentUser!.uid;
    final items = (orderData['items'] as List)
        .map((item) => CartItem.fromMap(item))
        .where((item) => item.farmerId == farmerId) // Show only farmer's items
        .toList();
    final createdAt = (orderData['createdAt'] as Timestamp?)?.toDate();
    final farmerTotal = items.fold<double>(
        0, (sum, item) => sum + (item.price * item.quantity));

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${orderData['orderId']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButton<String>(
                  value: orderData['status'],
                  items: [
                    'Pending',
                    'Processing',
                    'Shipped',
                    'Completed',
                    'Cancelled'
                  ]
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(
                              status,
                              style: TextStyle(
                                color: _getStatusColor(status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (newStatus) {
                    if (newStatus != null) {
                      _updateOrderStatus(context, newStatus);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              createdAt != null
                  ? 'Ordered on: ${createdAt.day}/${createdAt.month}/${createdAt.year}'
                  : 'Order Date Unavailable',
              style: const TextStyle(color: Colors.grey),
            ),
            const Divider(height: 16),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.productName} x ${item.quantity}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                          '₹${(item.price * item.quantity).toStringAsFixed(2)}'),
                    ],
                  ),
                )),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Total',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '₹${farmerTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ExpansionTile(
              title: const Text('Shipping Details'),
              children: [
                ListTile(
                  title: Text(orderData['shippingDetails']['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(orderData['shippingDetails']['phone']),
                      Text(orderData['shippingDetails']['address']),
                      Text(
                          '${orderData['shippingDetails']['city']} - ${orderData['shippingDetails']['pinCode']}'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateOrderStatus(BuildContext context, String newStatus) {
    FirebaseFirestore.instance
        .collection('orders')
        .doc(orderData['orderId'])
        .update({'status': newStatus});
  }
}
