class Product {
  final int productId;
  final String name;
  final String? packingDesc;
  final String? barcode;
  final int? companyId;
  final int? saltId;
  final int? categoryId;
  final String? hsnCode;
  final int? itemTypeId;
  final int? unitPrimaryId;
  final int? unitSecondaryId;
  final int? packingSizeId;
  final double conversionFactor;
  final String? unitPrimaryName;
  final String status;
  final bool isHidden;
  final bool isDecimalAllowed;
  final bool hasPhoto;
  final bool isNarcotic;
  final int? scheduleHId;
  final String? rackNumber;
  final int minQty;
  final int maxQty;
  final int reorderQty;
  final bool allowNegativeStock;
  final int currentStock;
  final double mrp;
  final double purchaseRate;
  final double costRate;
  final double salePrice;
  final double sgstPercent;
  final double cgstPercent;
  final double igstPercent;
  final double itemDiscount1;
  final double specialDiscount;
  final double maxDiscountPercent;
  final double saleMargin;
  final String? primaryImagePath;
  // final List<ProductImage> images; // API doesn't seem to return this list in main object, only primaryImagePath

  Product({
    required this.productId,
    required this.name,
    this.packingDesc,
    this.barcode,
    this.companyId,
    this.saltId,
    this.categoryId,
    this.hsnCode,
    this.itemTypeId,
    this.unitPrimaryId,
    this.unitSecondaryId,
    this.packingSizeId,
    this.conversionFactor = 1.0,
    this.unitPrimaryName,
    this.status = 'CONTINUE',
    this.isHidden = false,
    this.isDecimalAllowed = false,
    this.hasPhoto = false,
    this.isNarcotic = false,
    this.scheduleHId,
    this.rackNumber,
    this.minQty = 0,
    this.maxQty = 0,
    this.reorderQty = 0,
    this.allowNegativeStock = false,
    required this.currentStock,
    required this.mrp,
    this.purchaseRate = 0.0,
    this.costRate = 0.0,
    required this.salePrice,
    this.sgstPercent = 0.0,
    this.cgstPercent = 0.0,
    this.igstPercent = 0.0,
    this.itemDiscount1 = 0.0,
    this.specialDiscount = 0.0,
    this.maxDiscountPercent = 0.0,
    this.saleMargin = 0.0,
    this.primaryImagePath,
    // this.images = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'] ?? 0,
      name: json['name'] ?? '',
      packingDesc: json['packingDesc'],
      barcode: json['barcode'],
      companyId: json['companyId'],
      saltId: json['saltId'],
      categoryId: json['categoryId'],
      hsnCode: json['hsnCode'],
      itemTypeId: json['itemTypeId'],
      unitPrimaryId: json['unitPrimaryId'],
      unitSecondaryId: json['unitSecondaryId'],
      packingSizeId: json['packingSizeId'],
      conversionFactor: (json['conversionFactor'] ?? 1.0).toDouble(),
      unitPrimaryName: json['unitPrimaryName'],
      status: json['status'] ?? 'CONTINUE',
      isHidden: json['isHidden'] ?? false,
      isDecimalAllowed: json['isDecimalAllowed'] ?? false,
      hasPhoto: json['hasPhoto'] ?? false,
      isNarcotic: json['isNarcotic'] ?? false,
      scheduleHId: json['scheduleHId'],
      rackNumber: json['rackNumber'],
      minQty: json['minQty'] ?? 0,
      maxQty: json['maxQty'] ?? 0,
      reorderQty: json['reorderQty'] ?? 0,
      allowNegativeStock: json['allowNegativeStock'] ?? false,
      currentStock: json['currentStock'] ?? 0,
      mrp: (json['mrp'] ?? 0.0).toDouble(),
      purchaseRate: (json['purchaseRate'] ?? 0.0).toDouble(),
      costRate: (json['costRate'] ?? 0.0).toDouble(),
      salePrice: (json['salePrice'] ?? 0.0).toDouble(),
      sgstPercent: (json['sgstPercent'] ?? 0.0).toDouble(),
      cgstPercent: (json['cgstPercent'] ?? 0.0).toDouble(),
      igstPercent: (json['igstPercent'] ?? 0.0).toDouble(),
      itemDiscount1: (json['itemDiscount1'] ?? 0.0).toDouble(),
      specialDiscount: (json['specialDiscount'] ?? 0.0).toDouble(),
      maxDiscountPercent: (json['maxDiscountPercent'] ?? 0.0).toDouble(),
      saleMargin: (json['saleMargin'] ?? 0.0).toDouble(),
      primaryImagePath: json['primaryImagePath'],
    );
  }
}
