import 'dart:convert';
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
    // API Call: GET https://medtrue.cloud/api/Products
    print('Fetching medicines from: Products');
    Response response = await apiClient.getData('Products');
    print('Medicine Response: ${response.statusCode}');
    if (response.statusCode == 200) {
      dynamic body = response.body;
      print('Medicine Body Type: ${body.runtimeType}');
      
      if (body is String) {
        try {
          body = jsonDecode(body);
        } catch (e) {
          print('Failed to decode JSON string: $e');
        }
      }

      List<dynamic> data = [];
      if (body is List) {
        data = body;
      } else if (body is Map) {
        data = body['items'] ?? body['Items'] ?? body['data'] ?? [];
      }
      print('Medicine Data Length: ${data.length}');
      
      return data.map((json) {
        // Map backend keys
        // The API returns fields like: productId, name, mrp, packingDesc, primaryImagePath
        try {
           return Medicine(
            id: json['productId'] ?? 0,
            name: json['name'] ?? '',
            price: (json['mrp'] ?? 0).toDouble(),
            brand: null, // Brand name not in main product object, companyId is present
            packing: json['packingDesc'],
            imageUrl: json['primaryImagePath'],
            description: null, // Description not in main product object
            category: null, // categoryId is present
          );
        } catch (e) {
          print('Error parsing medicine: $e, JSON: $json');
          rethrow;
        }
      }).toList();
    } else {
      print('Failed to load medicines: ${response.statusText}');
      throw Exception('Failed to load medicines: ${response.statusText}');
    }
  }

  @override
  Future<Medicine> getMedicineById(int id) async {
    Response response = await apiClient.getData('Products/$id');
    if (response.statusCode == 200) {
      final json = response.body;
      return Medicine(
        id: json['productId'] ?? 0,
        name: json['name'] ?? '',
        price: (json['mrp'] ?? 0).toDouble(),
        packing: json['packingDesc'],
        imageUrl: json['primaryImagePath'],
      );
    } else {
      throw Exception('Failed to load medicine details: ${response.statusText}');
    }
  }

  @override
  Future<List<Medicine>> searchMedicines(String query) async {
    // Ideally use a search endpoint, but for now reuse Products and filter
    Response response = await apiClient.getData('Products');
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
          id: json['productId'] ?? 0,
          name: json['name'] ?? '',
          price: (json['mrp'] ?? 0).toDouble(),
          packing: json['packingDesc'],
          imageUrl: json['primaryImagePath'],
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
    // API Call: GET https://medtrue.cloud/api/Masters/categories?page=1&pageSize=10
    Response response = await apiClient.getData('Masters/categories?page=1&pageSize=10');
    if (response.statusCode == 200) {
      final body = response.body;
      List<dynamic> data = [];
      
      // Backend returns { items: [], totalCount: ... }
      if (body is Map) {
        data = body['items'] ?? body['Items'] ?? body['data'] ?? [];
      } else if (body is List) {
        data = body;
      }
      
      return data.map((json) => Category.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load categories: ${response.statusText}');
    }
}
}