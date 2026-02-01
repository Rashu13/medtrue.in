class Company {
  final int companyId;
  final String name;
  final String? code;
  final String? address;
  final String? contactNumber;
  final bool isActive;

  Company({
    required this.companyId,
    required this.name,
    this.code,
    this.address,
    this.contactNumber,
    required this.isActive,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      companyId: json['companyId'],
      name: json['name'],
      code: json['code'],
      address: json['address'],
      contactNumber: json['contactNumber'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyId': companyId,
      'name': name,
      'code': code,
      'address': address,
      'contactNumber': contactNumber,
      'isActive': isActive,
    };
  }
}

class Category {
  final int categoryId;
  final String name;
  final int? parentId;

  Category({required this.categoryId, required this.name, this.parentId});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['categoryId'],
      name: json['name'],
      parentId: json['parentId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'name': name,
      'parentId': parentId,
    };
  }
}

// Minimal models for others to start with
class Salt {
  final int saltId;
  final String name;

  Salt({required this.saltId, required this.name});

  factory Salt.fromJson(Map<String, dynamic> json) => Salt(saltId: json['saltId'], name: json['name']);
  Map<String, dynamic> toJson() => {'saltId': saltId, 'name': name};
}

class Unit {
  final int unitId;
  final String name;

  Unit({required this.unitId, required this.name});

  factory Unit.fromJson(Map<String, dynamic> json) => Unit(unitId: json['unitId'], name: json['name']);
  Map<String, dynamic> toJson() => {'unitId': unitId, 'name': name};
}

class ItemType {
  final int typeId;
  final String name;

  ItemType({required this.typeId, required this.name});

  factory ItemType.fromJson(Map<String, dynamic> json) => ItemType(typeId: json['typeId'], name: json['name']);
  Map<String, dynamic> toJson() => {'typeId': typeId, 'name': name};
}
