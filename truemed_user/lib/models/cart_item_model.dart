class CartItem {
  final int productId;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.imageUrl,
  });

  CartItem copyWith({
    int? productId,
    String? name,
    double? price,
    int? quantity,
    String? imageUrl,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
