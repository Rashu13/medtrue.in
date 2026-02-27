import 'package:broadcast_app/utils/constants.dart'; // Ensure constants.dart exists and imports Supabase
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  final _auth = supabase.auth;
  Rx<User?> currentUser = Rx<User?>(null);
  RxBool isLoading = false.obs;
  RxString userRole = ''.obs;

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _auth.currentUser;
    _fetchUserRole(); // Fetch role on init if user is logged in
    
    // Auto-create demo users on startup if not present (simple fire-and-forget)
    createDemoUsers(); 

    _auth.onAuthStateChange.listen((data) {
      currentUser.value = data.session?.user;
      if (data.event == AuthChangeEvent.signedIn) {
        _handleAuthNavigation();
      } else if (data.event == AuthChangeEvent.signedOut) {
        userRole.value = ''; // Clear role
        Get.offAllNamed('/login');
      }
    });
  }

  Future<void> _fetchUserRole() async {
    final user = currentUser.value;
    if (user == null) return;
    try {
      final data = await supabase
          .from('${AppConstants.tablePrefix}tbl_profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle(); // Use maybeSingle to avoid crash if profile missing
      if (data != null) {
        userRole.value = data['role'] as String;
      }
    } catch (e) {
      print('Error fetching role: $e');
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      // Check for email not confirmed error
      if (e.message.toLowerCase().contains('email not confirmed')) {
         Get.snackbar('Error', 'Email not confirmed. Please check your inbox or disable email confirmation in Supabase Auth settings.');
      } else {
         Get.snackbar('Error', e.message);
      }
    } catch (e) {
      print('Login error: $e');
      Get.snackbar('Error', 'An unexpected error occurred');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.signUp(email: email, password: password);
      Get.snackbar('Success', 'Account created! Please login.');
    } on AuthException catch (e) {
       if (e.message.toLowerCase().contains('email not confirmed')) {
         Get.snackbar('Error', 'Email not confirmed. Please check your inbox or disable email confirmation in Supabase Auth settings.');
      } else {
         Get.snackbar('Error', e.message);
      }
    } catch (e) {
      print('Signup error: $e');
      Get.snackbar('Error', 'An unexpected error occurred');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createDemoUsers() async {
    final box = GetStorage();
    if (box.read('dummy_users_created') == true) {
      print('Dummy users already flagged as created in local storage. Skipping check.');
      return;
    }

    // List of dummy users to create
    final dummyUsers = [
      {'email': 'admin@demo.com', 'pass': 'password123', 'role': 'admin'},
      {'email': 'user1@demo.com', 'pass': 'password123', 'role': 'user'},
      {'email': 'user2@demo.com', 'pass': 'password123', 'role': 'user'},
      {'email': 'user3@demo.com', 'pass': 'password123', 'role': 'user'},
    ];

    print('Attempting to ensure dummy users exist...');

    bool allSuccess = true;

    for (var u in dummyUsers) {
      try {
        final email = u['email']!;
        final password = u['pass']!;
        
        await _auth.signUp(email: email, password: password);
        
        print('Created dummy user: $email');
        if (u['role'] == 'admin') {
           print('NOTE: Please manually set role to "admin" for $email in Supabase dashboard if not already done.');
        }

      } on AuthException catch (e) {
        if (e.message.toLowerCase().contains('user already registered') || e.code == 'user_already_exists') {
          print('User $u already exists');
        } else if (e.statusCode == 429) {
           print('Rate limit hit for $u. Will retry next launch if not saved.');
           allSuccess = false;
           // Break to avoid hammering API if we are rate limited
           break; 
        } else {
          print('Error creating $u: ${e.message}');
          if (e.message.toLowerCase().contains('security purposes')) {
             allSuccess = false;
             break;
          }
        }
      } catch (e) {
         print('Unexpected error creating $u: $e');
         allSuccess = false;
      }
      // Small delay to be nice to the API
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (allSuccess) {
      box.write('dummy_users_created', true);
      print('All dummy users creation attempts finished. Flag set.');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> _handleAuthNavigation() async {
    final user = currentUser.value;
    if (user == null) return;

    try {
      final data = await supabase
          .from('${AppConstants.tablePrefix}tbl_profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      if (data == null) {
        // Profile might be missing if trigger failed or didn't exist. 
        // Create a default 'user' profile.
        print('Profile missing for ${user.email}. Creating default profile...');
        await supabase.from('${AppConstants.tablePrefix}tbl_profiles').insert({
          'id': user.id,
          'email': user.email,
          'role': 'user', // Default role
          'tenant_id': 'shreeapp', // Added default tenant_id
        });
        
        userRole.value = 'user';
        Get.offAllNamed('/user');
        return;
      }

      final role = data['role'] as String;
      userRole.value = role; // Update observable

      if (role == 'admin') {
        Get.offAllNamed('/admin');
      } else {
        Get.offAllNamed('/user');
      }
    } catch (e) {
      print('Auth navigation error: $e');
      Get.snackbar('Error', 'Failed to fetch or create user profile: $e');
    }
  }
}
