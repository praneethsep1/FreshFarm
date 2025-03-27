import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../authentication.dart';
import '../models.dart';
import '../welcome_screen.dart'; // Assuming UserModel and UserType are defined here

class FarmerProfileScreen extends StatefulWidget {
  const FarmerProfileScreen({super.key});

  @override
  _FarmerProfileScreenState createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _addressController;
  late TextEditingController _farmNameController;
  late TextEditingController _farmLocationController;

  UserModel? _userModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _fetchUserProfile();
  }

  void _initializeControllers() {
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _addressController = TextEditingController();
    _farmNameController = TextEditingController();
    _farmLocationController = TextEditingController();
  }

  void _fetchUserProfile() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      final user = await authService
          .fetchUserProfile(); // Assuming this returns UserModel
      setState(() {
        _userModel = user;
        _fullNameController.text = user?.fullName ?? '';
        _emailController.text = user?.email ?? '';
        _phoneNumberController.text = user?.phoneNumber ?? '';
        _addressController.text = user?.address ?? '';
        _farmNameController.text = user?.farmName ?? '';
        _farmLocationController.text = user?.farmLocation ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: $e')),
      );
    }
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      final updatedUser = UserModel(
        uid: _userModel!.uid,
        email: _userModel!.email,
        fullName: _fullNameController.text,
        userType: _userModel!.userType, // Preserve the original userType
        phoneNumber: _phoneNumberController.text,
        address: _addressController.text,
        farmName: _farmNameController.text,
        farmLocation: _farmLocationController.text,
      );

      await authService
          .updateUserProfile(updatedUser); // Assuming this accepts UserModel

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  void _logout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Picture Placeholder
                    Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.green.shade100,
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Full Name
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email (read-only)
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      readOnly: true,
                    ),

                    const SizedBox(height: 16),

                    // Phone Number
                    TextFormField(
                      controller: _phoneNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
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

                    // Farm Name
                    TextFormField(
                      controller: _farmNameController,
                      decoration: const InputDecoration(
                        labelText: 'Farm Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.agriculture),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your farm name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Farm Location
                    TextFormField(
                      controller: _farmLocationController,
                      decoration: const InputDecoration(
                        labelText: 'Farm Location',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your farm location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Save Profile Button
                    ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Save Profile',
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
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _farmNameController.dispose();
    _farmLocationController.dispose();
    super.dispose();
  }
}
