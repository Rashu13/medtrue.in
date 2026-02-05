class Product {
  final int productId;
  final String name;
  final String? packingDesc;
  final String? barcode;
  final int? companyId;
  final int? categoryId;
  final String? unitPrimaryName;
  final double mrp;
  final double salePrice;
  final int currentStock;
  final bool hasPhoto;
  final List<ProductImage> images;

  Product({
    required this.productId,
    required this.name,
    this.packingDesc,
    this.barcode,
    this.companyId,
    this.categoryId,
    this.unitPrimaryName,
    required this.mrp,
    required this.salePrice,
    required this.currentStock,
    this.hasPhoto = false,
    this.images = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'] ?? 0,
      name: json['name'] ?? '',
      packingDesc: json['packingDesc'],
      barcode: json['barcode'],
      companyId: json['companyId'],
      categoryId: json['categoryId'],
      unitPrimaryName: json['unitPrimaryName'],
      mrp: (json['mrp'] ?? 0.0).toDouble(),
      salePrice: (json['salePrice'] ?? 0.0).toDouble(),
      currentStock: json['currentStock'] ?? 0,
      hasPhoto: json['hasPhoto'] ?? false,
      images: json['images'] != null
          ? (json['images'] as List).map((i) => ProductImage.fromJson(i)).toList()
          : [],
    );
  }
}

class ProductImage {
  final int imgId;
  final int productId;
  final String imagePath;
  final bool isPrimary;

  ProductImage({
    required this.imgId,
    required this.productId,
    required this.imagePath,
    this.isPrimary = false,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      imgId: json['imgId'] ?? 0,
      productId: json['productId'] ?? 0,
      imagePath: json['imagePath'] ?? '',
      isPrimary: json['isPrimary'] ?? false,
    );
  }
}
