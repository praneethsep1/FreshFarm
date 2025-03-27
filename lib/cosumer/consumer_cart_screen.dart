import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../authentication.dart';
import 'place_order_screen.dart';

class ConsumerCartScreen extends StatelessWidget {
  const ConsumerCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final cartService = CartService(authService.currentUser!.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _showClearCartConfirmation(context, cartService),
          ),
        ],
      ),
      body: StreamBuilder<List<CartItem>>(
        stream: cartService.getCartItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Your cart is empty',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final cartItems = snapshot.data!;
          final total = cartItems.fold(
              0.0, (sum, item) => sum + (item.price * item.quantity));

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartItems[index];
                    return CartItemTile(
                      cartItem: cartItem,
                      cartService: cartService,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Total: ₹${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: cartItems.isNotEmpty
                            ? () =>
                                _proceedToCheckout(context, cartItems, total)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Proceed to Checkout',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showClearCartConfirmation(
      BuildContext context, CartService cartService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              cartService.clearCart();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _proceedToCheckout(
      BuildContext context, List<CartItem> cartItems, double total) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaceOrderScreen(
          cartItems: cartItems,
          total: total,
        ),
      ),
    );
  }
}

class CartItemTile extends StatelessWidget {
  final CartItem cartItem;
  final CartService cartService;

  const CartItemTile({
    super.key,
    required this.cartItem,
    required this.cartService,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(cartItem.productId),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) => cartService.removeFromCart(cartItem.productId),
      child: ListTile(
        leading: cartItem.imageUrl.isNotEmpty
            ? Image.network(
                cartItem.imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
            : const Icon(Icons.image),
        title: Text(cartItem.productName),
        subtitle:
            Text('₹${cartItem.price.toStringAsFixed(2)} per ${cartItem.unit}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => _adjustQuantity(context, -1),
            ),
            Text(
              '${cartItem.quantity}',
              style: const TextStyle(fontSize: 16),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _adjustQuantity(context, 1),
            ),
          ],
        ),
      ),
    );
  }

  void _adjustQuantity(BuildContext context, int change) {
    final newQuantity = cartItem.quantity + change;
    if (newQuantity > 0) {
      cartService.updateCartItemQuantity(cartItem.productId, newQuantity);
    } else {
      cartService.removeFromCart(cartItem.productId);
    }
  }
}
