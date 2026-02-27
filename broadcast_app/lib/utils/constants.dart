import 'package:supabase_flutter/supabase_flutter.dart';

class AppConstants {
  static const String supabaseUrl = 'http://supabasekong-z8wcgcs4wwsgw84o4wcggs40.62.72.13.162.sslip.io';
  static const String supabaseAnonKey = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsImlhdCI6MTc3MTE2NTU2MCwiZXhwIjo0OTI2ODM5MTYwLCJyb2xlIjoiYW5vbiJ9.onYmCJ6xWr7GwS7spCYT0lueI0ggk13UCDfmrkbLIWI';
  
  // Table Prefix configuration
  static const String tablePrefix = 'shreematka'; // Using shreematka prefix now
}

final supabase = Supabase.instance.client;
