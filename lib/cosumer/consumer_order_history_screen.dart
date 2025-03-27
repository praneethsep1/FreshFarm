import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../authentication.dart';
import '../models.dart';

class ConsumerOrderHistoryScreen extends StatelessWidget {
  const ConsumerOrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: authService.currentUser!.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No orders yet',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final orderData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return OrderHistoryCard(orderData: orderData);
            },
          );
        },
      ),
    );
  }
}

class OrderHistoryCard extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const OrderHistoryCard({super.key, required this.orderData});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
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
    final items = (orderData['items'] as List)
        .map((item) => CartItem.fromMap(item))
        .toList();
    final createdAt = (orderData['createdAt'] as Timestamp?)?.toDate();

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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(orderData['status']),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    orderData['status'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                  'Total',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '₹${orderData['total'].toStringAsFixed(2)}',
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
            if (orderData['status'] == 'Pending')
              Center(
                child: TextButton(
                  onPressed: () => _showCancelOrderDialog(context),
                  child: const Text(
                    'Cancel Order',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCancelOrderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              // Update order status to cancelled
              FirebaseFirestore.instance
                  .collection('orders')
                  .doc(orderData['orderId'])
                  .update({'status': 'Cancelled'});
              Navigator.pop(context);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}
