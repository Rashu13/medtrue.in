import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../../core/app_constants.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          GetX<CartController>(
            builder: (controller) {
              return Badge(
                label: Text('${controller.itemCount}'),
                isLabelVisible: controller.itemCount > 0,
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () => Get.toNamed('/cart'),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search medicines...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) => controller.searchMedicines(value),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${controller.errorMessage.value}'),
                ElevatedButton(
                  onPressed: () => controller.getMedicines(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.medicineList.isEmpty) {
          return const Center(child: Text('No medicines found.'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(AppConstants.padding),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: controller.medicineList.length,
          itemBuilder: (context, index) {
            final medicine = controller.medicineList[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.borderRadius)),
                      child: medicine.imageUrl != null 
                        ? Image.network(
                            '${AppConstants.baseImageUrl}${medicine.imageUrl}',
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        : Container(color: Colors.grey[200], child: const Icon(Icons.medication)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medicine.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          medicine.brand ?? 'Generic',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${medicine.price}',
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.find<CartController>().addMedicine(medicine);
                              Get.snackbar(
                                'Added to Cart',
                                '${medicine.name} added to your cart.',
                                snackPosition: SnackPosition.BOTTOM,
                                duration: const Duration(seconds: 1),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(double.infinity, 36),
                            ),
                            child: const Text('Add'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
