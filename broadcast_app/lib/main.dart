import 'package:broadcast_app/screens/simple_chat_screen.dart';
import 'package:broadcast_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await GetStorage.init();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // Auto-install schema if needed
  try {
    await Supabase.instance.client.rpc('install_schema', params: {'prefix': AppConstants.tablePrefix});
  } catch (e) {
    debugPrint("Schema install warning (ignore if initial): $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Use GetStorage to retrieve saved session if needed, 
  // or pass down params from native embedding
  final box = GetStorage();
  
  @override
  Widget build(BuildContext context) {
    // For standalone testing, we check session or use dummy data
    final String? savedPhone = box.read('phone');
    final String? savedAppId = box.read('appId');
    
    // In a real embedded scenario, these would come from the host app
    final String phoneToUse = savedPhone ?? "TEST_PHONE_123";
    final String appIdToUse = savedAppId ?? "TEST_APP_ID_456";

    return MaterialApp(
      title: 'Broadcast App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: SimpleChatScreen(
        phoneNumber: phoneToUse,
        appId: appIdToUse,
      ),
    );
  }
}
