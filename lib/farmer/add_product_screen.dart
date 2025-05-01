import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../authentication.dart';
import '../models.dart';

/// A stateful widget that allows farmers to add or edit a product.
///
/// Provides a form to input product details, upload images, and select units and
/// categories. Saves the product to Firestore and uploads images to Firebase Storage.
///
/// Parameters:
///   - product: An optional [Product] object for editing an existing product.

class AddProductScreen extends StatefulWidget {
  final Product? product; // Optional: for editing existing products

  const AddProductScreen({super.key, this.product});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

/// The state class for [AddProductScreen].
///
/// Manages the state of the product form, including text controllers, image uploads,
/// and dropdown selections. Handles saving the product to Firestore and updating
/// the UI based on user interactions.

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _descriptionController;
  String? _selectedUnit;
  String? _selectedCategory;
  List<File> _images = []; // Local files to upload
  List<String> _imageUrls = []; // URLs from existing product or after upload
  bool _isLoading = false;

  final List<String> _units = ['kg', 'gram', 'liter', 'unit'];
  final List<String> _categories = [
    'Vegetables',
    'Fruits',
    'Grains',
    'Dairy',
    'Others',
  ];

  /// Initializes the state of the widget.
  ///
  /// Sets up text controllers and pre-fills them with existing product data if
  /// editing a product. Initializes unit and category dropdowns.

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController =
        TextEditingController(text: widget.product?.price.toString() ?? '');
    _quantityController =
        TextEditingController(text: widget.product?.quantity.toString() ?? '');
    _descriptionController =
        TextEditingController(text: widget.product?.description ?? '');
    _selectedUnit = widget.product?.unit ?? _units.first;
    _selectedCategory = widget.product?.category ?? _categories.first;
    _imageUrls = widget.product?.imageUrls ?? [];
  }

  /// Opens the image picker to select multiple images.
  ///
  /// Updates the [_images] list with selected image files and triggers a UI refresh.

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _images =
            pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
      });
    }
  }

  /// Uploads selected images to Firebase Storage.
  ///
  /// Preserves existing image URLs and adds new URLs for uploaded images, using the
  /// product ID to organize storage paths.
  ///
  /// Parameters:
  ///   - productId: The ID of the product for naming storage paths.
  ///
  /// Returns:
  ///   A [Future<List<String>>] containing all image URLs (existing and newly uploaded).

  Future<List<String>> _uploadImages(String productId) async {
    final storage = FirebaseStorage.instance;
    List<String> uploadedUrls = List.from(_imageUrls); // Preserve existing URLs

    for (var image in _images) {
      final ref = storage.ref().child(
          'products/$productId/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(image);
      final url = await ref.getDownloadURL();
      uploadedUrls.add(url);
    }

    return uploadedUrls;
  }

  /// Removes an image from either existing URLs or selected files.
  ///
  /// Updates [_imageUrls] or [_images] based on the index and triggers a UI refresh.
  ///
  /// Parameters:
  ///   - index: The index of the image to remove.

  void _removeImage(int index) {
    setState(() {
      if (index < _imageUrls.length) {
        _imageUrls.removeAt(index);
      } else {
        _images.removeAt(index - _imageUrls.length);
      }
    });
  }

  /// Saves the product to Firestore.
  ///
  /// Validates the form, uploads images to Firebase Storage, creates or updates a
  /// [Product] object, and saves it to Firestore. Displays a snackbar for success
  /// or error feedback.

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final firestore = FirebaseFirestore.instance;

    try {
      final productId =
          widget.product?.id ?? firestore.collection('products').doc().id;
      final imageUrls = await _uploadImages(productId);

      final product = Product(
        id: productId,
        name: _nameController.text,
        price: double.parse(_priceController.text),
        quantity: int.parse(_quantityController.text),
        unit: _selectedUnit!,
        description: _descriptionController.text,
        imageUrls: imageUrls,
        category: _selectedCategory!,
        dateAdded: DateTime.now(),
        farmerId: authService.currentUser!.uid,
      );

      await firestore
          .collection('products')
          .doc(productId)
          .set(product.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product saved successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save product: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Builds the UI for the add/edit product screen.
  ///
  /// Displays a form with fields for product details, image upload, unit, and category
  /// selection. Shows a loading indicator during save operations and a button to
  /// save the product.
  ///
  /// Parameters:
  ///   - context: The [BuildContext] for building the widget.
  ///
  /// Returns:
  ///   A [Widget] representing the add/edit product screen UI.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
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
                    // Image Upload Section
                    const Text(
                      'Product Images',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _imageUrls.length + _images.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _imageUrls.length + _images.length) {
                            return GestureDetector(
                              onTap: _pickImages,
                              child: Container(
                                width: 100,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.add_a_photo, size: 40),
                              ),
                            );
                          }
                          final isExisting = index < _imageUrls.length;
                          final image = isExisting
                              ? NetworkImage(_imageUrls[index])
                              : FileImage(_images[index - _imageUrls.length]);
                          return Stack(
                            children: [
                              Container(
                                width: 100,
                                margin: const EdgeInsets.only(right: 8),
                                child: Image(
                                    image: image as ImageProvider,
                                    fit: BoxFit.cover),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.remove_circle,
                                      color: Colors.red),
                                  onPressed: () => _removeImage(index),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.label),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter product name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Price
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price (₹)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.money),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter price';
                        }
                        if (double.tryParse(value) == null ||
                            double.parse(value) <= 0) {
                          return 'Please enter a valid price';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Quantity
                    TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter quantity';
                        }
                        if (int.tryParse(value) == null ||
                            int.parse(value) <= 0) {
                          return 'Please enter a valid quantity';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Unit Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.scale),
                      ),
                      items: _units
                          .map((unit) =>
                              DropdownMenuItem(value: unit, child: Text(unit)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedUnit = value!),
                      validator: (value) =>
                          value == null ? 'Please select a unit' : null,
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _categories
                          .map((cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedCategory = value!),
                      validator: (value) =>
                          value == null ? 'Please select a category' : null,
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    ElevatedButton(
                      onPressed: _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Save Product',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
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
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
