import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/master_models.dart';

class MasterProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Company> _companies = [];
  List<Category> _categories = [];
  bool _isLoading = false;

  List<Company> get companies => _companies;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> fetchMasters() async {
    _isLoading = true;
    notifyListeners();

    try {
      final companyRes = await _apiService.get('/api/masters/companies');
      _companies = (companyRes.data as List).map((e) => Company.fromJson(e)).toList();

      final categoryRes = await _apiService.get('/api/masters/categories');
      _categories = (categoryRes.data as List).map((e) => Category.fromJson(e)).toList();
    } catch (e) {
      print("Error fetching masters: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCompany(Company company) async {
    try {
      await _apiService.post('/api/masters/companies', data: company.toJson());
      await fetchMasters(); // Refresh list
    } catch (e) {
      print("Error adding company: $e");
      rethrow;
    }
  }
}
