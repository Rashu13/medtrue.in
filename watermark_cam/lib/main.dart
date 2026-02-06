import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screens/camera_screen.dart';
import 'controllers/watermark_controller.dart';

import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get.put(WatermarkController());
  runApp(const WatermarkCamApp());
}

class WatermarkCamApp extends StatelessWidget {
  const WatermarkCamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Watermark Cam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Outfit',
        useMaterial3: true,
      ),
      home: const CameraScreen(),
    );
  }
}
