
import 'package:broadcast_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:broadcast_app/admin/screens/admin_panel_screen.dart';
import 'package:broadcast_app/controllers/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await GetStorage.init();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // Auto-install schema and enable realtime for both tables
  try {
    final client = Supabase.instance.client;
    await client.rpc('install_schema', params: {'prefix': AppConstants.tablePrefix});
    
    // Attempt to enable realtime for prefixed tables via RPC or direct SQL if allowed
    // Note: These might fail depending on permissions, but are worth trying for setup
    final tables = ['${AppConstants.tablePrefix}tbl_messages', '${AppConstants.tablePrefix}tbl_profiles'];
    for (var table in tables) {
      try {
        await client.from(table).select().limit(1); // Check if table exists
        debugPrint("Enabling realtime for $table...");
        // This is a placeholder for enabling realtime - usually done via SQL/Dashboard
      } catch (_) {}
    }
  } catch (e) {
    debugPrint("Setup warning: $e");
  }

  // Globally initialize AuthController after Supabase is ready
  Get.put(AuthController());

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final box = GetStorage();
  
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Shree Chat Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AdminPanelScreen(),
    );
  }
}
