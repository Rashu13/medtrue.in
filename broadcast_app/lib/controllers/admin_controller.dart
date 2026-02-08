import 'package:broadcast_app/utils/constants.dart';
import 'package:get/get.dart';

class AdminController extends GetxController {
  RxList<Map<String, dynamic>> users = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  void fetchUsers() async {
    isLoading.value = true;
    try {
      final response = await supabase
          .from('tbl_profiles')
          .select('id, email')
          .eq('role', 'user'); // Fetch only normal users

      final data = response as List<dynamic>;
      users.value = data.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error fetching users: $e');
      Get.snackbar('Error', 'Failed to fetch users: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
