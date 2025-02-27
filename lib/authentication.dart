import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String userType; // 'farmer' or 'consumer'
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
      'userType': userType,
      'phoneNumber': phoneNumber,
      'address': address,
      'farmName': farmName,
      'farmLocation': farmLocation,
    };
  }
}

// Authentication Service
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign Up
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String userType,
    String? phoneNumber,
    String? address,
    String? farmName,
    String? farmLocation,
  }) async {
    try {
      // Create user with email and password
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user model
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

      return userModel;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign In
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user data from Firestore
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(result.user!.uid).get();

      return UserModel(
        uid: result.user!.uid,
        email: doc['email'],
        fullName: doc['fullName'],
        userType: doc['userType'],
        phoneNumber: doc['phoneNumber'],
        address: doc['address'],
        farmName: doc['farmName'],
        farmLocation: doc['farmLocation'],
      );
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }


  // Get user type
  Future<String?> getUserType(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      return doc['userType'];
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
