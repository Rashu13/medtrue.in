import 'package:get/get.dart';
import '../../../models/cart_item_model.dart';
import '../../../models/product_model.dart';
import '../../../domain/entities/medicine.dart';

class CartController extends GetxController {
  var items = <int, CartItem>{}.obs;

  double get totalAmount {
    var total = 0.0;
    items.forEach((key, value) {
      total += value.price * value.quantity;
    });
    return total;
  }

  int get itemCount => items.length;

  int get totalQuantity {
    var total = 0;
    items.forEach((key, value) {
      total += value.quantity;
    });
    return total;
  }

  void addItem(Product product) {
    if (items.containsKey(product.productId)) {
      items.update(
        product.productId,
        (existingItem) => existingItem.copyWith(
          quantity: existingItem.quantity + 1,
        ),
      );
    } else {
      items.putIfAbsent(
        product.productId,
        () => CartItem(
          productId: product.productId,
          name: product.name,
          price: product.salePrice,
          imageUrl: product.primaryImagePath,
        ),
      );
    }
  }

  void addMedicine(Medicine medicine) {
    if (items.containsKey(medicine.id)) {
      items.update(
        medicine.id,
        (existingItem) => existingItem.copyWith(
          quantity: existingItem.quantity + 1,
        ),
      );
    } else {
      items.putIfAbsent(
        medicine.id,
        () => CartItem(
          productId: medicine.id,
          name: medicine.name,
          price: medicine.price,
          imageUrl: medicine.imageUrl,
        ),
      );
    }
  }

  void removeItem(int productId) {
    items.remove(productId);
  }

  void removeSingleItem(int productId) {
    if (!items.containsKey(productId)) return;
    if (items[productId]!.quantity > 1) {
      items.update(
        productId,
        (existingItem) => existingItem.copyWith(
          quantity: existingItem.quantity - 1,
        ),
      );
    } else {
      items.remove(productId);
    }
  }

  void clear() {
    items.clear();
  }
}
