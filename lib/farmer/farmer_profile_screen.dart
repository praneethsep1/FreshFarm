import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../authentication.dart';
import '../help_screen.dart';
import '../welcome_screen.dart';

/// A stateful widget that allows farmers to view and edit their profile information.
///
/// Displays a form with fields for full name, email, phone number, address, farm
/// name, and farm location. Supports saving profile updates and logging out.

class FarmerProfileScreen extends StatefulWidget {
  const FarmerProfileScreen({super.key});

  @override
  _FarmerProfileScreenState createState() => _FarmerProfileScreenState();
}

/// The state class for [FarmerProfileScreen].
///
/// Manages the state of the profile form, including text controllers, loading state,
/// and user data. Handles fetching, updating, and saving the farmer's profile.

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

  /// Initializes the state of the widget.
  ///
  /// Sets up text controllers and fetches the farmer's profile data.

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _fetchUserProfile();
  }

  /// Initializes text controllers for the profile form fields.
  ///
  /// Sets up controllers for full name, email, phone number, address, farm name,
  /// and farm location.

  void _initializeControllers() {
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _addressController = TextEditingController();
    _farmNameController = TextEditingController();
    _farmLocationController = TextEditingController();
  }

  /// Fetches the farmer's profile data from [AuthService].
  ///
  /// Updates the [_userModel] and populates text controllers with the fetched data.
  /// Displays an error snackbar if the fetch fails.

  void _fetchUserProfile() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      final user = await authService.fetchUserProfile();
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

  /// Saves the updated profile data to [AuthService].
  ///
  /// Validates the form, creates an updated [UserModel], and saves it. Displays a
  /// snackbar for success or error feedback.

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      final updatedUser = UserModel(
        uid: _userModel!.uid,
        email: _userModel!.email,
        fullName: _fullNameController.text,
        userType: _userModel!.userType,
        phoneNumber: _phoneNumberController.text,
        address: _addressController.text,
        farmName: _farmNameController.text,
        farmLocation: _farmLocationController.text,
      );

      await authService.updateUserProfile(updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  /// Logs the farmer out and navigates to the [WelcomeScreen].
  ///
  /// Calls [AuthService.signOut] and clears the navigation stack.

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

  /// Builds the UI for the farmer profile screen.
  ///
  /// Displays a loading indicator or a form with profile fields, a save button,
  /// and options for help and logout. Includes a profile avatar placeholder.
  ///
  /// Parameters:
  ///   - context: The [BuildContext] for building the widget.
  ///
  /// Returns:
  ///   A [Widget] representing the profile screen UI.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpScreen()),
              );
            },
          ),
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
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.home),
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
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  /// Disposes of text controllers to free up resources.
  ///
  /// Called when the widget is removed from the widget tree.

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
