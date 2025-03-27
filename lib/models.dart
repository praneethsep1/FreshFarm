import 'package:cloud_firestore/cloud_firestore.dart';

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

class CartItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String unit;
  final String imageUrl;
  final String farmerId; // Added field

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.imageUrl,
    required this.farmerId,
  });

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

class CartService {
  final String userId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CartService(this.userId);

  // Add item to cart
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

  // Remove item from cart
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

  // Update cart item quantity
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

  // Get cart items stream
  Stream<List<CartItem>> getCartItems() {
    return _firestore
        .collection('carts')
        .doc(userId)
        .collection('items')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CartItem.fromMap(doc.data())).toList());
  }

  // Clear entire cart
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
