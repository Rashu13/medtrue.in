import 'package:get/get.dart';
import '../../domain/entities/medicine.dart';
import '../../domain/repositories/medicine_repository.dart';
import '../../models/master_models.dart';
import '../api/api_client.dart';

class MedicineRepositoryImpl implements MedicineRepository {
  final ApiClient apiClient;

  MedicineRepositoryImpl({required this.apiClient});

  @override
  Future<List<Medicine>> getMedicines({int page = 1, int limit = 20}) async {
    // Backend uses /api/products for products
    Response response = await apiClient.getData('products');
    if (response.statusCode == 200) {
      final body = response.body;
      List<dynamic> data = [];
      if (body is List) {
        data = body;
      } else if (body is Map) {
        data = body['items'] ?? body['Items'] ?? body['data'] ?? [];
      }
      
      return data.map((json) {
        // Map backend keys (handling both camelCase and PascalCase)
        return Medicine(
          id: json['productId'] ?? json['ProductId'] ?? 0,
          name: json['name'] ?? json['Name'] ?? '',
          price: (json['mrp'] ?? json['Mrp'] ?? 0).toDouble(),
          brand: json['brandName'] ?? json['BrandName'], 
          packing: json['packingDesc'] ?? json['PackingDesc'],
          imageUrl: json['primaryImagePath'] ?? json['PrimaryImagePath'],
          description: json['description'] ?? json['Description'],
        );
      }).toList();
    } else {
      throw Exception('Failed to load medicines: ${response.statusText}');
    }
  }

  @override
  Future<Medicine> getMedicineById(int id) async {
    Response response = await apiClient.getData('products/$id');
    if (response.statusCode == 200) {
      final json = response.body;
      return Medicine(
        id: json['productId'] ?? json['ProductId'] ?? 0,
        name: json['name'] ?? json['Name'] ?? '',
        price: (json['mrp'] ?? json['Mrp'] ?? 0).toDouble(),
        packing: json['packingDesc'] ?? json['PackingDesc'],
        imageUrl: json['primaryImagePath'] ?? json['PrimaryImagePath'],
      );
    } else {
      throw Exception('Failed to load medicine details: ${response.statusText}');
    }
  }

  @override
  Future<List<Medicine>> searchMedicines(String query) async {
    // For now, using main products endpoint or filtering if backend search is missing
    Response response = await apiClient.getData('products');
    if (response.statusCode == 200) {
      final body = response.body;
      List<dynamic> data = [];
      if (body is List) {
        data = body;
      } else if (body is Map) {
        data = body['items'] ?? body['Items'] ?? body['data'] ?? [];
      }
      
      var list = data.map((json) {
        return Medicine(
          id: json['productId'] ?? json['ProductId'] ?? 0,
          name: json['name'] ?? json['Name'] ?? '',
          price: (json['mrp'] ?? json['Mrp'] ?? 0).toDouble(),
          packing: json['packingDesc'] ?? json['PackingDesc'],
          imageUrl: json['primaryImagePath'] ?? json['PrimaryImagePath'],
        );
      }).toList();
      
      if (query.isNotEmpty) {
        list = list.where((m) => m.name.toLowerCase().contains(query.toLowerCase())).toList();
      }
      return list;
    } else {
      throw Exception('Failed to search medicines: ${response.statusText}');
    }
  }

  @override
  Future<List<Category>> getCategories() async {
    Response response = await apiClient.getData('masters/categories');
    if (response.statusCode == 200) {
      final body = response.body;
      List<dynamic> data = [];
      
      // Backend returns { Items: [], TotalCount: ... }
      if (body is Map) {
        data = body['items'] ?? body['Items'] ?? body['data'] ?? [];
      } else if (body is List) {
        data = body;
      }
      
      return data.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories: ${response.statusText}');
    }
  }
}
