import 'package:broadcast_app/utils/constants.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  final _auth = supabase.auth;
  Rx<User?> currentUser = Rx<User?>(null);
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _auth.currentUser;
    _auth.onAuthStateChange.listen((data) {
      currentUser.value = data.session?.user;
      if (data.event == AuthChangeEvent.signedIn) {
        // Fetch role and navigate
        _handleAuthNavigation();
      } else if (data.event == AuthChangeEvent.signedOut) {
        Get.offAllNamed('/login');
      }
    });
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      Get.snackbar('Error', e.message);
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> _handleAuthNavigation() async {
    // Here we will check the role later.
    // For now, just go to home.
    // We need to implement role checking logic.
    Get.offAllNamed('/home');
  }
}
