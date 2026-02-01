class Product {
  final int? productId; // Nullable for new products
  final String name;
  final String? packingDesc;
  final String? barcode;
  final int? companyId;
  final int? saltId;
  final int? categoryId;
  final int? unitPrimaryId;
  final int? unitSecondaryId;
  final double conversionFactor;
  final double mrp;
  final double purchaseRate;
  final double costRate;
  
  // Images
  final List<ProductImage>? images;

  Product({
    this.productId,
    required this.name,
    this.packingDesc,
    this.barcode,
    this.companyId,
    this.saltId,
    this.categoryId,
    this.unitPrimaryId,
    this.unitSecondaryId,
    this.conversionFactor = 1.0,
    this.mrp = 0.0,
    this.purchaseRate = 0.0,
    this.costRate = 0.0,
    this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'],
      name: json['name'],
      packingDesc: json['packingDesc'],
      barcode: json['barcode'],
      companyId: json['companyId'],
      saltId: json['saltId'],
      categoryId: json['categoryId'],
      unitPrimaryId: json['unitPrimaryId'],
      unitSecondaryId: json['unitSecondaryId'],
      conversionFactor: (json['conversionFactor'] as num?)?.toDouble() ?? 1.0,
      mrp: (json['mrp'] as num?)?.toDouble() ?? 0.0,
      purchaseRate: (json['purchaseRate'] as num?)?.toDouble() ?? 0.0,
      costRate: (json['costRate'] as num?)?.toDouble() ?? 0.0,
      // Handle Image parsing later manually or via extra field
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'packingDesc': packingDesc,
      'barcode': barcode,
      'companyId': companyId,
      'saltId': saltId,
      'categoryId': categoryId,
      'unitPrimaryId': unitPrimaryId,
      'unitSecondaryId': unitSecondaryId,
      'conversionFactor': conversionFactor,
      'mrp': mrp,
      'purchaseRate': purchaseRate,
      'costRate': costRate,
    };
  }
}

class ProductImage {
  final int? imgId;
  final int? productId;
  final String imagePath;
  final bool isPrimary;

  ProductImage({
    this.imgId,
    this.productId,
    required this.imagePath,
    this.isPrimary = false,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      imgId: json['imgId'],
      productId: json['productId'],
      imagePath: json['imagePath'],
      isPrimary: json['isPrimary'] ?? false,
    );
  }
}
