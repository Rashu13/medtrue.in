import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../models/product_models.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/api/products');
      _products = (response.data as List).map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      print("Error fetching products: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> addProduct(Product product) async {
    try {
      final response = await _apiService.post('/api/products', data: product.toJson());
      // Assuming response contains the created object or ID
      // If backend returns CreatedAtAction with object, we can parse it.
      // But repo returns ID mainly. Let's assume backend returns the full object or ID.
      // Actually ProductsController.Create returns CreatedAtAction with the object.
      final newProduct = Product.fromJson(response.data);
      return newProduct.productId!;
    } catch (e) {
      print("Error adding product: $e");
      rethrow;
    }
  }

  Future<void> uploadImage(int productId, File imageFile, {bool isPrimary = false}) async {
    try {
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(imageFile.path, filename: fileName),
        "isPrimary": isPrimary,
      });

      await _apiService.post('/api/products/$productId/images', data: formData);
      await fetchProducts(); // Refresh to show new image logic if we were fetching images in list
    } catch (e) {
      print("Error uploading image: $e");
      rethrow;
    }
  }
}
