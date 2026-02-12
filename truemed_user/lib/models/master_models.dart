class Category {
  final int categoryId;
  final String name;
  final int? parentId;
  final String? imagePath;

  Category({
    required this.categoryId,
    required this.name,
    this.parentId,
    this.imagePath,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['categoryId'] ?? 0,
      name: json['name'] ?? '',
      parentId: json['parentId'],
      imagePath: json['imagePath'],
    );
  }
}

class Company {
  final int companyId;
  final String name;

  Company({
    required this.companyId,
    required this.name,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      companyId: json['companyId'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}
