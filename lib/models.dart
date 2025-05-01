import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a product in the application.
///
/// Contains details such as name, description, price, and other attributes
/// associated with a product listed by a farmer.

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String unit;
  final int quantity;
  final String farmerId;
  final List<String> imageUrls;
  final DateTime dateAdded;
  final String category;

  /// Creates a [Product] instance with required and optional attributes.
  ///
  /// Parameters:
  ///   - id: The unique identifier of the product (default is empty string).
  ///   - name: The name of the product.
  ///   - description: A description of the product.
  ///   - price: The price of the product.
  ///   - unit: The unit of measurement for the product (e.g., kg, liter).
  ///   - quantity: The available quantity of the product.
  ///   - farmerId: The ID of the farmer who listed the product.
  ///   - imageUrls: A list of URLs for the product's images.
  ///   - dateAdded: The date the product was added.
  ///   - category: The category of the product.

  Product({
    this.id = '',
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.quantity,
    required this.farmerId,
    required this.imageUrls,
    required this.dateAdded,
    required this.category,
  });

  /// Converts the [Product] to a map for Firestore storage.
  ///
  /// Returns:
  ///   A [Map<String, dynamic>] containing the product's data.

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'unit': unit,
      'quantity': quantity,
      'farmerId': farmerId,
      'imageUrls': imageUrls,
      'dateAdded': dateAdded.toIso8601String(),
      'category': category,
    };
  }

  /// Creates a [Product] from a Firestore document map.
  ///
  /// Parameters:
  ///   - map: A [Map<String, dynamic>] containing the product's data.
  ///   - id: The unique identifier of the product.
  ///
  /// Returns:
  ///   A [Product] instance populated with the map's data.

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'],
      description: map['description'],
      price: map['price'].toDouble(),
      unit: map['unit'],
      quantity: map['quantity'],
      farmerId: map['farmerId'],
      imageUrls: List<String>.from(map['imageUrls']),
      dateAdded: DateTime.parse(map['dateAdded']),
      category: map['category'],
    );
  }
}

/// Represents an item in a user's shopping cart.
///
/// Contains details about a product added to the cart, including quantity and
/// farmer information.

class CartItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String unit;
  final String imageUrl;
  final String farmerId; // Added field

  /// Creates a [CartItem] instance with required attributes.
  ///
  /// Parameters:
  ///   - productId: The ID of the product in the cart.
  ///   - productName: The name of the product.
  ///   - price: The price of the product.
  ///   - quantity: The quantity of the product in the cart.
  ///   - unit: The unit of measurement for the product.
  ///   - imageUrl: The URL of the product's image.
  ///   - farmerId: The ID of the farmer who listed the product.

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.imageUrl,
    required this.farmerId,
  });

  /// Converts the [CartItem] to a map for Firestore storage.
  ///
  /// Returns:
  ///   A [Map<String, dynamic>] containing the cart item's data.

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'imageUrl': imageUrl,
      'farmerId': farmerId,
    };
  }

  /// Creates a [CartItem] from a Firestore document map.
  ///
  /// Parameters:
  ///   - map: A [Map<String, dynamic>] containing the cart item's data.
  ///
  /// Returns:
  ///   A [CartItem] instance populated with the map's data.

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId'],
      productName: map['productName'],
      price: map['price'].toDouble(),
      quantity: map['quantity'],
      unit: map['unit'],
      imageUrl: map['imageUrl'],
      farmerId: map['farmerId'],
    );
  }
}

/// Manages cart operations for a specific user in Firestore.
///
/// Provides methods to add, remove, update, and clear cart items, as well as
/// retrieve a stream of cart items.

class CartService {
  final String userId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates a [CartService] instance for a specific user.
  ///
  /// Parameters:
  ///   - userId: The ID of the user whose cart is being managed.

  CartService(this.userId);

  /// Adds an item to the user's cart in Firestore.
  ///
  /// Parameters:
  ///   - cartItem: The [CartItem] to be added to the cart.
  ///
  /// Returns:
  ///   A [Future<void>] that completes when the item is added.

  Future<void> addToCart(CartItem cartItem) async {
    try {
      await _firestore
          .collection('carts')
          .doc(userId)
          .collection('items')
          .doc(cartItem.productId)
          .set(cartItem.toMap());
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }

  /// Removes an item from the user's cart in Firestore.
  ///
  /// Parameters:
  ///   - productId: The ID of the product to be removed.
  ///
  /// Returns:
  ///   A [Future<void>] that completes when the item is removed.
  Future<void> removeFromCart(String productId) async {
    try {
      await _firestore
          .collection('carts')
          .doc(userId)
          .collection('items')
          .doc(productId)
          .delete();
    } catch (e) {
      print('Error removing from cart: $e');
    }
  }

  /// Updates the quantity of a cart item in Firestore.
  ///
  /// Parameters:
  ///   - productId: The ID of the product whose quantity is to be updated.
  ///   - newQuantity: The new quantity for the cart item.
  ///
  /// Returns:
  ///   A [Future<void>] that completes when the quantity is updated.

  Future<void> updateCartItemQuantity(String productId, int newQuantity) async {
    try {
      await _firestore
          .collection('carts')
          .doc(userId)
          .collection('items')
          .doc(productId)
          .update({'quantity': newQuantity});
    } catch (e) {
      print('Error updating cart item quantity: $e');
    }
  }

  /// Retrieves a stream of the user's cart items from Firestore.
  ///
  /// Returns:
  ///   A [Stream<List<CartItem>>] containing the user's cart items.

  Stream<List<CartItem>> getCartItems() {
    return _firestore
        .collection('carts')
        .doc(userId)
        .collection('items')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CartItem.fromMap(doc.data())).toList());
  }

  /// Clears all items from the user's cart in Firestore.
  ///
  /// Returns:
  ///   A [Future<void>] that completes when the cart is cleared.

  Future<void> clearCart() async {
    try {
      final snapshot = await _firestore
          .collection('carts')
          .doc(userId)
          .collection('items')
          .get();

      for (DocumentSnapshot doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }
}
