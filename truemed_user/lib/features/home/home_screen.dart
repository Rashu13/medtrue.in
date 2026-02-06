import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:badges/badges.dart' as b;
import '../../core/app_constants.dart';
import '../../presentation/home/controllers/home_controller.dart';
import '../../presentation/cart/controllers/cart_controller.dart';

import '../../theme/app_theme.dart';
import '../../domain/entities/medicine.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TrueMed'),
        actions: [
          GetX<CartController>(
            builder: (cart) {
              return b.Badge(
                position: b.BadgePosition.topEnd(top: 0, end: 3),
                showBadge: cart.itemCount > 0,
                badgeContent: Text(
                  '${cart.itemCount}',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () => Get.toNamed('/cart'),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            _buildCategorySection(),
            _buildFeaturedSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search medicines...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) => controller.searchMedicines(value),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Categories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: Obx(() {
            if (controller.isLoading.value && controller.categories.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: controller.categories.length,
              itemBuilder: (context, index) {
                final cat = controller.categories[index];
                return InkWell(
                  onTap: () {
                    // Filter logic or detail
                  },
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppTheme.primaryTeal.withOpacity(0.1),
                          child: cat.imagePath != null
                              ? ClipOval(
                                  child: Image.network(
                                    '${AppConstants.baseImageUrl}${cat.imagePath}',
                                    fit: BoxFit.cover,
                                    width: 60,
                                    height: 60,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.medical_services, color: AppTheme.primaryTeal),
                                  ),
                                )
                              : const Icon(Icons.medical_services, color: AppTheme.primaryTeal),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cat.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFeaturedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Featured Medicines',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Obx(() {
          if (controller.isLoading.value && controller.medicineList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: controller.medicineList.length > 6 ? 6 : controller.medicineList.length,
            itemBuilder: (context, index) {
              final medicine = controller.medicineList[index];
              return _buildProductCard(medicine);
            },
          );
        }),
      ],
    );
  }

  Widget _buildProductCard(Medicine medicine) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Get.toNamed('/product', arguments: medicine),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                ),
                child: medicine.imageUrl != null
                    ? Image.network(
                        '${AppConstants.baseImageUrl}${medicine.imageUrl}',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.medication, size: 50, color: AppTheme.primaryTeal),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${medicine.price}',
                    style: const TextStyle(
                      color: AppTheme.primaryTeal,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Get.find<CartController>().addMedicine(medicine);
                      Get.snackbar(
                        'Added to Cart',
                        '${medicine.name} added!',
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 1),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(double.infinity, 32),
                    ),
                    child: const Text('Add', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
