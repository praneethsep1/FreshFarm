import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../authentication.dart';
import '../models.dart';

/// A stateless widget that displays a list of orders for the logged-in farmer.
///
/// Fetches orders from Firestore using [_getFarmerOrders] and displays them in
/// a list of [FarmerOrderCard] widgets.

class FarmerOrderManagement extends StatelessWidget {
  const FarmerOrderManagement({super.key});

  /// Builds the UI for the farmer order management screen.
  ///
  /// Displays a loading indicator, an empty state message, or a list of
  /// [FarmerOrderCard] widgets based on the state of the order stream.
  ///
  /// Parameters:
  ///   - context: The [BuildContext] for building the widget.
  ///
  /// Returns:
  ///   A [Widget] representing the order management screen UI.

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

  /// Retrieves a stream of orders relevant to the logged-in farmer.
  ///
  /// Filters orders from Firestore where at least one item belongs to the farmer,
  /// based on the farmer's ID from [AuthService].
  ///
  /// Parameters:
  ///   - context: The [BuildContext] for accessing [AuthService].
  ///
  /// Returns:
  ///   A [Stream<List<Map<String, dynamic>>>] containing order data maps.

  Stream<List<Map<String, dynamic>>> _getFarmerOrders(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final farmerId = authService.currentUser!.uid;

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

/// A stateless widget that displays details of a single order for a farmer.
///
/// Shows order items, status, total, and shipping details, with options to update
/// the order status and enter shipping details for 'Shipped' status.
///
/// Parameters:
///   - orderData: A map containing the order data from Firestore.

class FarmerOrderCard extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const FarmerOrderCard({super.key, required this.orderData});

  /// Returns a color based on the order status.
  ///
  /// Maps each status (e.g., 'Pending', 'Shipped') to a specific color for UI display.
  ///
  /// Parameters:
  ///   - status: The status of the order.
  ///
  /// Returns:
  ///   A [Color] representing the status.

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

  /// Shows a dialog to input shipping details for an order.
  ///
  /// Allows the farmer to enter the delivery person's name and phone number, then
  /// updates the order in Firestore with the details and sets the status to 'Shipped'.
  ///
  /// Parameters:
  ///   - context: The [BuildContext] for showing the dialog.
  ///   - onStatusUpdate: A callback to update the order status (currently unused).

  void _showShippingDetailsDialog(
      BuildContext context, Function(String) onStatusUpdate) {
    final _formKey = GlobalKey<FormState>();
    final _deliveryPersonNameController = TextEditingController();
    final _deliveryPersonPhoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Shipping Details'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _deliveryPersonNameController,
                  decoration: const InputDecoration(
                    labelText: 'Delivery Person Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the delivery person\'s name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _deliveryPersonPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Delivery Person Phone',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the phone number';
                    }
                    if (value.length != 10) {
                      return 'Please enter a valid 10-digit phone number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  FirebaseFirestore.instance
                      .collection('orders')
                      .doc(orderData['orderId'])
                      .update({
                    'shippingDetails.deliveryPerson': {
                      'name': _deliveryPersonNameController.text,
                      'phone': _deliveryPersonPhoneController.text,
                    },
                    'status': 'Shipped',
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Shipping details updated')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  /// Updates the status of the order in Firestore.
  ///
  /// If the new status is 'Shipped', shows a dialog to collect shipping details.
  /// Otherwise, directly updates the status in Firestore.
  ///
  /// Parameters:
  ///   - context: The [BuildContext] for showing dialogs.
  ///   - newStatus: The new status to set for the order.

  void _updateOrderStatus(BuildContext context, String newStatus) {
    if (newStatus == 'Shipped') {
      _showShippingDetailsDialog(context, (status) {
        FirebaseFirestore.instance
            .collection('orders')
            .doc(orderData['orderId'])
            .update({'status': status});
      });
    } else {
      FirebaseFirestore.instance
          .collection('orders')
          .doc(orderData['orderId'])
          .update({'status': newStatus});
    }
  }

  /// Builds the UI for a single order card.
  ///
  /// Displays the order ID, status dropdown, items, total, and expandable shipping
  /// details. Filters items to show only those belonging to the farmer.
  ///
  /// Parameters:
  ///   - context: The [BuildContext] for building the widget.
  ///
  /// Returns:
  ///   A [Widget] representing the order card UI.

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final farmerId = authService.currentUser!.uid;
    final items = (orderData['items'] as List)
        .map((item) => CartItem.fromMap(item))
        .where((item) => item.farmerId == farmerId)
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
                  'Order #${orderData['orderId'].toString().substring(0, 15)}',
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
}
