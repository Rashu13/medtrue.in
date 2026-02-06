import 'package:supabase_flutter/supabase_flutter.dart';

class AppConstants {
  static const String supabaseUrl = 'http://supabasekong-ycwww0s8444kccogw0csks0w.62.72.13.162.sslip.io';
  static const String supabaseAnonKey = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsImlhdCI6MTc3MDI5MTk2MCwiZXhwIjo0OTI1OTY1NTYwLCJyb2xlIjoiYW5vbiJ9.Hl779vu4VeePRhge-QmxHIQdV5fjY6pE-65x9EnB5i4';
}

final supabase = Supabase.instance.client;
