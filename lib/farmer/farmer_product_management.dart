import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../authentication.dart';
import '../models.dart';
import 'add_product_screen.dart';

class FarmerProductManagement extends StatelessWidget {
  const FarmerProductManagement({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final productRepository = Provider.of<ProductRepository>(context);
    final currentUser = authService.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Your Products')),
      body: StreamBuilder<List<Product>>(
        stream: productRepository.getProducts(currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No products added yet'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddProductScreen(),
                        ),
                      );
                    },
                    child: const Text('Add First Product'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length + 1,
            itemBuilder: (context, index) {
              if (index == snapshot.data!.length) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddProductScreen(),
                        ),
                      );
                    },
                    child: const Text('Add New Product'),
                  ),
                );
              }

              final product = snapshot.data![index];
              return Dismissible(
                key: Key(product.id),
                background: Container(
                  color: Colors.red,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirm Delete'),
                      content: const Text(
                          'Are you sure you want to delete this product?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) {
                  productRepository.deleteProduct(product.id);
                },
                child: ListTile(
                  leading: product.imageUrls.isNotEmpty
                      ? Image.network(
                          product.imageUrls.first,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image),
                  title: Text(product.name),
                  subtitle: Text(
                      '₹${product.price.toStringAsFixed(2)} per ${product.unit}'),
                  trailing: Text('Qty: ${product.quantity}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddProductScreen(
                          product: product,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
