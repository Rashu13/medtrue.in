import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_constants.dart';
import '../../domain/entities/medicine.dart';
import '../../presentation/cart/controllers/cart_controller.dart';
import '../../theme/app_theme.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Medicine product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            _buildInfoSection(context),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildImageSection() {
    return Container(
      height: 250,
      width: double.infinity,
      color: Colors.grey.shade100,
      child: product.imageUrl != null
          ? Image.network(
              '${AppConstants.baseImageUrl}${product.imageUrl}',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.broken_image, size: 100, color: Colors.grey),
              ),
            )
          : const Center(
              child: Icon(Icons.medication, size: 100, color: AppTheme.primaryTeal),
            ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          if (product.packing != null)
            Text(
              product.packing!,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                '₹${product.price}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTeal,
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          const Text(
            'Description',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            product.description ?? 'No description available.',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Get.find<CartController>().addMedicine(product);
          Get.snackbar(
            'Added to Cart',
            '${product.name} added to cart!',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 1),
          );
        },
        child: const Text('Add to Cart'),
      ),
    );
  }
}
