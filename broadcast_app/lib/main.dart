import 'package:broadcast_app/controllers/auth_controller.dart';
import 'package:broadcast_app/screens/dashboards.dart';
import 'package:broadcast_app/screens/login_screen.dart';
import 'package:broadcast_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await GetStorage.init();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  Get.put(AuthController()); // Initialize globally

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Broadcast App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/login',
      // initialBinding removed
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/admin', page: () => const AdminDashboard()), // binding removed
        GetPage(name: '/user', page: () => const UserDashboard()),
        // Placeholder for home, auth controller determines redirection
        GetPage(name: '/home', page: () => const Scaffold(body: Center(child: CircularProgressIndicator()))),
      ],
    );
  }
}
