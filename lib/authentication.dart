import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'app_constants.dart';
import 'farmer/farmer_home_screen.dart';
import 'models.dart';

/// Represents a user in the application with profile information.
///
/// Stores user details such as ID, email, name, user type, and optional fields
/// like phone number, address, farm name, and farm location.

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final UserType userType;
  final String? phoneNumber;
  final String? address;
  final String? farmName;
  final String? farmLocation;

  /// Creates a [UserModel] instance with required and optional user details.
  ///
  /// Parameters:
  ///   - uid: The unique identifier of the user.
  ///   - email: The user's email address.
  ///   - fullName: The user's full name.
  ///   - userType: The type of user (farmer or consumer).
  ///   - phoneNumber: The user's phone number (optional).
  ///   - address: The user's address (optional).
  ///   - farmName: The name of the user's farm (optional, typically for farmers).
  ///   - farmLocation: The location of the user's farm (optional, typically for farmers).

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.userType,
    this.phoneNumber,
    this.address,
    this.farmName,
    this.farmLocation,
  });

  /// Converts the [UserModel] to a map for Firestore storage.
  ///
  /// Returns:
  ///   A [Map<String, dynamic>] containing the user's data.

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'userType': userType.name,
      'phoneNumber': phoneNumber,
      'address': address,
      'farmName': farmName,
      'farmLocation': farmLocation,
    };
  }

  /// Creates a [UserModel] from a Firestore document map.
  ///
  /// Parameters:
  ///   - map: A [Map<String, dynamic>] containing the user's data.
  ///
  /// Returns:
  ///   A [UserModel] instance populated with the map's data.

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      fullName: map['fullName'],
      userType: UserTypeExtension.fromString(map['userType']),
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
      farmName: map['farmName'] ?? '',
      farmLocation: map['farmLocation'] ?? '',
    );
  }
}

/// Manages user authentication and profile operations using Firebase.
///
/// Provides methods for signing up, signing in, signing out, and managing user
/// profiles, including FCM token storage for notifications.

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Gets the currently authenticated Firebase user.
  ///
  /// Returns:
  ///   The current [User] object, or null if no user is signed in.

  User? get currentUser => _auth.currentUser;

  /// Saves the Firebase Cloud Messaging (FCM) token for a user.
  ///
  /// Stores the token in Firestore under the user's document for push notifications.
  ///
  /// Parameters:
  ///   - userId: The ID of the user to associate the token with.

  Future<void> saveFcmToken(String userId) async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  /// Registers a new user with Firebase Authentication and Firestore.
  ///
  /// Creates a user account, stores profile data in Firestore, and saves the FCM token.
  ///
  /// Parameters:
  ///   - email: The user's email address.
  ///   - password: The user's password.
  ///   - fullName: The user's full name.
  ///   - userType: The type of user (farmer or consumer).
  ///   - phoneNumber: The user's phone number (optional).
  ///   - address: The user's address (optional).
  ///   - farmName: The name of the user's farm (optional).
  ///   - farmLocation: The location of the user's farm (optional).
  ///
  /// Returns:
  ///   A [Future<UserModel?>] containing the created user model, or null if the operation fails.

  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserType userType,
    String? phoneNumber,
    String? address,
    String? farmName,
    String? farmLocation,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel userModel = UserModel(
        uid: result.user!.uid,
        email: email,
        fullName: fullName,
        userType: userType,
        phoneNumber: phoneNumber,
        address: address,
        farmName: farmName,
        farmLocation: farmLocation,
      );

      // Save user data to Firestore
      await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .set(userModel.toMap());

      await saveFcmToken(result.user!.uid);
      return userModel;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  /// Signs in a user with Firebase Authentication and retrieves their profile.
  ///
  /// Authenticates the user and fetches their profile data from Firestore.
  ///
  /// Parameters:
  ///   - email: The user's email address.
  ///   - password: The user's password.
  ///
  /// Returns:
  ///   A [Future<UserModel?>] containing the signed-in user model, or null if the operation fails.
  ///
  /// Throws:
  ///   - [AuthException] if authentication fails or an error occurs.

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentSnapshot doc =
          await _firestore.collection('users').doc(result.user!.uid).get();
      await saveFcmToken(result.user!.uid);
      return UserModel(
        uid: result.user!.uid,
        email: doc['email'],
        fullName: doc['fullName'],
        userType: UserTypeExtension.fromString(doc['userType']),
        phoneNumber: doc['phoneNumber'],
        address: doc['address'],
        farmName: doc['farmName'],
        farmLocation: doc['farmLocation'],
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? '');
    } catch (e) {
      throw AuthException('An unexpected error occurred');
    }
  }

  /// Signs out the current user from Firebase Authentication.
  ///
  /// Returns:
  ///   A [Future<void>] that completes when the sign-out is successful.

  Future<void> signOut() async => await _auth.signOut();

  /// Retrieves the user type for a given user ID from Firestore.
  ///
  /// Parameters:
  ///   - uid: The ID of the user whose type is to be retrieved.
  ///
  /// Returns:
  ///   A [Future<UserType?>] containing the user's type, or null if the operation fails.

  Future<UserType?> getUserType(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      return UserTypeExtension.fromString(doc['userType']);
    } catch (e) {
      return null;
    }
  }
}

/// A custom exception for authentication-related errors.
///
/// Used to handle and propagate errors during authentication operations.

class AuthException implements Exception {
  final String message;

  /// Creates an [AuthException] with a specific error message.
  ///
  /// Parameters:
  ///   - message: The error message describing the authentication issue.

  AuthException(this.message);
}

/// Manages product data operations in Firestore.
///
/// Provides methods to fetch, add, update, and delete products for a specific farmer.

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Retrieves a stream of products for a specific farmer from Firestore.
  ///
  /// Parameters:
  ///   - farmerId: The ID of the farmer whose products are to be fetched.
  ///
  /// Returns:
  ///   A [Stream<List<Product>>] containing the farmer's products.

  Stream<List<Product>> getProducts(String farmerId) {
    return _firestore
        .collection('products')
        .where('farmerId', isEqualTo: farmerId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Adds a new product to Firestore.
  ///
  /// Parameters:
  ///   - product: The [Product] to be added.
  ///
  /// Returns:
  ///   A [Future<void>] that completes when the product is added.

  Future<void> addProduct(Product product) async {
    await _firestore.collection('products').add(product.toMap());
  }

  /// Updates an existing product in Firestore.
  ///
  /// Parameters:
  ///   - product: The [Product] with updated data.
  ///
  /// Returns:
  ///   A [Future<void>] that completes when the product is updated.

  Future<void> updateProduct(Product product) async {
    await _firestore
        .collection('products')
        .doc(product.id)
        .update(product.toMap());
  }

  /// Deletes a product from Firestore.
  ///
  /// Parameters:
  ///   - productId: The ID of the product to be deleted.
  ///
  /// Returns:
  ///   A [Future<void>] that completes when the product is deleted.

  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }
}

/// Extends [AuthService] with methods for managing user profiles.
///
/// Provides functionality to update and fetch user profile data in Firestore.

extension ProfileManagement on AuthService {

  /// Updates a user's profile data in Firestore.
  ///
  /// Parameters:
  ///   - profile: The [UserModel] containing updated profile data.
  ///
  /// Returns:
  ///   A [Future<void>] that completes when the profile is updated.
  ///
  /// Throws:
  ///   - Exception if the update operation fails.

  Future<void> updateUserProfile(UserModel profile) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(profile.uid)
          .update(profile.toMap());
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  /// Fetches the current user's profile data from Firestore.
  ///
  /// Returns:
  ///   A [Future<UserModel?>] containing the user's profile, or null if the operation fails or no user is signed in.

  Future<UserModel?> fetchUserProfile() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return null;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      return UserModel.fromMap(doc.data() ?? {});
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }
}
