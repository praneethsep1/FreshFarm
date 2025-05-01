import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../authentication.dart';
import 'consumer_cart_screen.dart';

/// A stateful widget that displays detailed information about a product.
///
/// Shows product images, name, price, description, and quantity selector. Allows
/// users to add the product to their cart using [CartService].
///
/// Parameters:
///   - product: The [Product] object containing details to display.

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

/// The state class for [ProductDetailScreen].
///
/// Manages the state of the quantity selector and handles adding the product to
/// the cart using [CartService]. Updates the UI based on user interactions.

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  /// Increments the selected quantity if within available stock.
  ///
  /// Updates [_quantity] and triggers a UI refresh, ensuring the quantity does not
  /// exceed the product's available stock.

  void _incrementQuantity() {
    setState(() {
      if (_quantity < widget.product.quantity) {
        _quantity++;
      }
    });
  }

  /// Decrements the selected quantity if above the minimum.
  ///
  /// Updates [_quantity] and triggers a UI refresh, ensuring the quantity does not
  /// go below 1.

  void _decrementQuantity() {
    setState(() {
      if (_quantity > 1) {
        _quantity--;
      }
    });
  }

  /// Adds the selected product and quantity to the user's cart.
  ///
  /// Creates a [CartItem] and uses [CartService] to add it to the cart. Displays
  /// a snackbar to confirm success or report errors, with an option to view the cart.
  ///
  /// Parameters:
  ///   - context: The [BuildContext] for accessing providers and navigation.

  void _addToCart(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final cartService = CartService(authService.currentUser!.uid);

    final cartItem = CartItem(
      productId: widget.product.id,
      productName: widget.product.name,
      price: widget.product.price,
      quantity: _quantity,
      unit: widget.product.unit,
      imageUrl: widget.product.imageUrls.isNotEmpty
          ? widget.product.imageUrls.first
          : '',
      farmerId: widget.product.farmerId, // Add farmerId
    );

    try {
      await cartService.addToCart(cartItem);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${widget.product.name} to cart'),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'View Cart',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ConsumerCartScreen()),
              );
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add ${widget.product.name} to cart'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Builds the UI for the product detail screen.
  ///
  /// Displays a carousel of product images, name, price, description, available
  /// quantity, and a quantity selector. Includes a button to add the product to the cart.
  ///
  /// Parameters:
  ///   - context: The [BuildContext] for building the widget.
  ///
  /// Returns:
  ///   A [Widget] representing the product detail screen UI.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Carousel or First Image
            SizedBox(
              height: 300,
              child: widget.product.imageUrls.isNotEmpty
                  ? PageView.builder(
                      itemCount: widget.product.imageUrls.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          widget.product.imageUrls[index],
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : const Center(child: Icon(Icons.image, size: 200)),
            ),

            // Product Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${widget.product.price.toStringAsFixed(2)} per ${widget.product.unit}',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.product.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        'Available: ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.product.quantity} ${widget.product.unit}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Quantity Selector
                  Row(
                    children: [
                      const Text(
                        'Quantity: ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: _decrementQuantity,
                      ),
                      Text(
                        '$_quantity',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: _incrementQuantity,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _addToCart(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Add to Cart - ₹${(widget.product.price * _quantity).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
