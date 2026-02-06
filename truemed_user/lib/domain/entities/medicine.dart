class Medicine {
  final int id;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final String? brand;
  final String? category;
  final String? packing;

  Medicine({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    this.brand,
    this.category,
    this.packing,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'],
      brand: json['brand'],
      category: json['category'],
      packing: json['packing'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'brand': brand,
      'category': category,
      'packing': packing,
    };
  }
}
