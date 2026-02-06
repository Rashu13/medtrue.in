import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'theme/app_theme.dart';
import 'presentation/home/views/home_view.dart';
import 'features/home/home_screen.dart';
import 'features/shop/product_details_screen.dart';
import 'bindings/home_binding.dart';
import 'presentation/cart/views/cart_screen.dart';
import 'domain/entities/medicine.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TrueMedUserApp());
}

class TrueMedUserApp extends StatelessWidget {
  const TrueMedUserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'TrueMed',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => const HomeScreen(),
          binding: HomeBinding(),
        ),
        GetPage(
          name: '/home_view',
          page: () => const HomeView(),
        ),
        GetPage(
          name: '/cart',
          page: () => const CartScreen(),
        ),
        GetPage(
          name: '/product',
          page: () {
            final medicine = Get.arguments as Medicine;
            return ProductDetailsScreen(product: medicine);
          },
        ),
      ],
    );
  }
}
