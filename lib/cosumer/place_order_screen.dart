import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models.dart';
import '../authentication.dart';

class PlaceOrderScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final double total;

  const PlaceOrderScreen(
      {super.key, required this.cartItems, required this.total});

  @override
  _PlaceOrderScreenState createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
  final _formKey = GlobalKey<FormState>();

  // Shipping Details Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();

  // Delivery Options
  String _selectedDeliveryOption = 'Standard Delivery';
  final List<String> _deliveryOptions = [
    'Standard Delivery',
    'Express Delivery',
  ];

  // Payment Methods
  String _selectedPaymentMethod = 'Cash on Delivery';
  final List<String> _paymentMethods = [
    'Cash on Delivery',
    'Online Payment',
  ];

  @override
  void initState() {
    super.initState();
    // TODO: Pre-fill user details if available
  }

  Future<void> _placeOrder(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    final cartService = CartService(authService.currentUser!.uid);

    try {
      // Create order document
      final orderRef = FirebaseFirestore.instance.collection('orders').doc();

      // Prepare order details
      final orderData = {
        'orderId': orderRef.id,
        'userId': authService.currentUser!.uid,
        'items': widget.cartItems.map((item) => item.toMap()).toList(),
        'total': widget.total,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
        'shippingDetails': {
          'name': _nameController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'city': _cityController.text,
          'pinCode': _pinCodeController.text,
        },
        'deliveryOption': _selectedDeliveryOption,
        'paymentMethod': _selectedPaymentMethod,
      };

      // Save order to Firestore
      await orderRef.set(orderData);

      // Reduce product quantities
      await _updateProductQuantities(widget.cartItems);

      // Clear the cart
      await cartService.clearCart();

      // Show success dialog
      await _showOrderConfirmationDialog(orderRef.id);
    } catch (e) {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: $e')),
      );
    }
  }

  Future<void> _updateProductQuantities(List<CartItem> cartItems) async {
    final firestore = FirebaseFirestore.instance;

    for (var item in cartItems) {
      final productDoc = firestore.collection('products').doc(item.productId);

      await firestore.runTransaction((transaction) async {
        // Get the current product document
        final snapshot = await transaction.get(productDoc);

        if (!snapshot.exists) {
          throw Exception('Product does not exist');
        }

        // Calculate new quantity
        final currentQuantity = snapshot.data()?['quantity'] ?? 0;
        final newQuantity = currentQuantity - item.quantity;

        if (newQuantity < 0) {
          throw Exception('Insufficient stock for ${item.productName}');
        }

        // Update the quantity
        transaction.update(productDoc, {'quantity': newQuantity});
      });
    }
  }

  Future<void> _showOrderConfirmationDialog(String orderId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Order Placed Successfully'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Your order has been placed successfully.'),
                Text('Order ID: $orderId'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('View Orders'),
              onPressed: () {
                // TODO: Navigate to order history
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Continue Shopping'),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Order'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Order Summary
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Summary',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        ...widget.cartItems.map((item) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      '${item.productName} x ${item.quantity}'),
                                  Text(
                                      '₹${(item.price * item.quantity).toStringAsFixed(2)}'),
                                ],
                              ),
                            )),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '₹${widget.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Shipping Details
                const SizedBox(height: 16),
                const Text(
                  'Shipping Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (value.length != 10) {
                      return 'Please enter a valid 10-digit phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                          labelText: 'City',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your city';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _pinCodeController,
                        decoration: const InputDecoration(
                          labelText: 'Pin Code',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter pin code';
                          }
                          if (value.length != 6) {
                            return 'Please enter a valid 6-digit pin code';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                // Delivery Options
                const SizedBox(height: 16),
                const Text(
                  'Delivery Options',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedDeliveryOption,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: _deliveryOptions
                      .map((option) => DropdownMenuItem(
                            value: option,
                            child: Text(option),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDeliveryOption = value!;
                    });
                  },
                ),

                // Payment Methods
                const SizedBox(height: 16),
                const Text(
                  'Payment Method',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedPaymentMethod,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: _paymentMethods
                      .map((method) => DropdownMenuItem(
                            value: method,
                            child: Text(method),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value!;
                    });
                  },
                ),

                // Place Order Button
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _placeOrder(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Place Order',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up controllers
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pinCodeController.dispose();
    super.dispose();
  }
}
