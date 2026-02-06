import '../entities/medicine.dart';
import '../../models/master_models.dart';

abstract class MedicineRepository {
  Future<List<Medicine>> getMedicines({int page = 1, int limit = 20});
  Future<Medicine> getMedicineById(int id);
  Future<List<Medicine>> searchMedicines(String query);
  Future<List<Category>> getCategories();
}
