import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/master_models.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Product> _products = [];
  List<Category> _categories = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.get('/Masters/categories');
      if (response.statusCode == 200) {
        _categories = (response.data as List)
            .map((item) => Category.fromJson(item))
            .toList();
      }
    } catch (e) {
      apiDebugPrint('Error fetching categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.get('/Products');
      if (response.statusCode == 200) {
        _products = (response.data as List)
            .map((item) => Product.fromJson(item))
            .toList();
      }
    } catch (e) {
      apiDebugPrint('Error fetching products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Search products
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    return _products.where((p) => 
      p.name.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}
