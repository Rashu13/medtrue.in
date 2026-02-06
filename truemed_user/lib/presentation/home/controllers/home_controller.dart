import 'package:get/get.dart';
import '../../../domain/entities/medicine.dart';
import '../../../domain/repositories/medicine_repository.dart';
import '../../../models/master_models.dart';

class HomeController extends GetxController {
  final MedicineRepository medicineRepository;

  HomeController({required this.medicineRepository});

  final RxList<Medicine> medicineList = <Medicine>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getMedicines();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      List<Category> cats = await medicineRepository.getCategories();
      categories.assignAll(cats);
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> getMedicines() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      List<Medicine> medicines = await medicineRepository.getMedicines();
      medicineList.assignAll(medicines);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchMedicines(String query) async {
    if (query.isEmpty) {
      getMedicines();
      return;
    }
    
    isLoading.value = true;
    try {
      List<Medicine> medicines = await medicineRepository.searchMedicines(query);
      medicineList.assignAll(medicines);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
