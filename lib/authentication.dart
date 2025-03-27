import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'app_constants.dart';
import 'farmer/farmer_home_screen.dart';
import 'models.dart';

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final UserType userType;
  final String? phoneNumber;
  final String? address;
  final String? farmName;
  final String? farmLocation;

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

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<void> saveFcmToken(String userId) async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

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

  Future<void> signOut() async => await _auth.signOut();

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

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Product>> getProducts(String farmerId) {
    return _firestore
        .collection('products')
        .where('farmerId', isEqualTo: farmerId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addProduct(Product product) async {
    await _firestore.collection('products').add(product.toMap());
  }

  Future<void> updateProduct(Product product) async {
    await _firestore
        .collection('products')
        .doc(product.id)
        .update(product.toMap());
  }

  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }
}

// Add to your existing AuthService class
extension ProfileManagement on AuthService {
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
