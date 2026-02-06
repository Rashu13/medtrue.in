import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../../../../theme/app_theme.dart';

class CartScreen extends GetView<CartController> {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
      ),
      body: Obx(() {
        if (controller.items.isEmpty) {
          return const Center(
            child: Text('Your cart is empty!'),
          );
        }
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: controller.items.length,
                itemBuilder: (context, index) {
                  final item = controller.items.values.toList()[index];
                  return ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.medication),
                    ),
                    title: Text(item.name),
                    subtitle: Text('₹${item.price} x ${item.quantity}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        controller.removeItem(item.productId);
                      },
                    ),
                  );
                },
              ),
            ),
            _buildSummary(context),
          ],
        );
      }),
    );
  }

  Widget _buildSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount', style: TextStyle(fontSize: 18)),
              Obx(() => Text(
                '₹${controller.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTeal,
                ),
              )),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Checkout logic
            },
            child: const Text('Checkout'),
          ),
        ],
      ),
    );
  }
}
