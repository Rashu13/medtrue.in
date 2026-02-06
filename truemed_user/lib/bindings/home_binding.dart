import 'package:get/get.dart';
import '../data/api/api_client.dart';
import '../data/repositories/medicine_repository_impl.dart';
import '../domain/repositories/medicine_repository.dart';
import '../presentation/home/controllers/home_controller.dart';
import '../presentation/cart/controllers/cart_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut(() => ApiClient());

    // Repositories
    Get.lazyPut<MedicineRepository>(() => MedicineRepositoryImpl(apiClient: Get.find()));

    // Controllers
    Get.lazyPut(() => HomeController(medicineRepository: Get.find()));
    Get.lazyPut(() => CartController());
  }
}
