import 'package:broadcast_app/controllers/admin_controller.dart';
import 'package:get/get.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AdminController());
  }
}
