import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final int price;

  CartItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
  });
}

class Goods {
  String id;
  String title;
  String img;
  int quantity;
  int price;

  Goods({
    required this.id,
    required this.title,
    required this.img,
    required this.quantity,
    required this.price,
  });
}

// goodsList<Goods>

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};
  List<Goods> _goodsList = [];

  Map<String, CartItem> get items {
    return {..._items};
  }

  List<Goods> get goodsList {
    return [..._goodsList];
  }

  double get totalAmount {
    return _items.values.fold(0, (sum, item) => sum + item.price * item.quantity);
  }

  int get totalQuantity {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  void addItem(String id, String title, int price) {
    if (_items.containsKey(id)) {
      _items.update(
        id,
        (existingItem) => CartItem(
          id: existingItem.id,
          title: existingItem.title,
          quantity: existingItem.quantity + 1,
          price: existingItem.price,
        ),
      );
    } else {
      _items.putIfAbsent(
        id,
        () => CartItem(
          id: id,
          title: title,
          quantity: 1,
          price: price,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String id) {
    if (_items[id]!.quantity > 1) {
      _items.update(
        id,
        (existingItem) => CartItem(
          id: existingItem.id,
          title: existingItem.title,
          quantity: existingItem.quantity - 1,
          price: existingItem.price,
        ),
      );
    } else {
      _items.remove(id);
    }
    notifyListeners();
  }

  void addGoods(Goods goods) {
    // 상품이 이미 존재하면 업데이트, 그렇지 않으면 추가
    final index = _goodsList.indexWhere((g) => g.id == goods.id);
    if (index >= 0) {
      _goodsList[index] = goods;
    } else {
      _goodsList.add(goods);
    }
    notifyListeners();
  }

  void removeGoods(String id) {
    _goodsList.removeWhere((goods) => goods.id == id);
    _items.remove(id); // Remove the item from the cart as well
    notifyListeners();
  }

  void deductStockAfterPayment() {
    _items.forEach((productId, cartItem) {
      final goodsIndex = _goodsList.indexWhere((goods) => goods.id == productId);
      if (goodsIndex >= 0) {
        _goodsList[goodsIndex].quantity -= cartItem.quantity;
        if (_goodsList[goodsIndex].quantity < 0) {
          _goodsList[goodsIndex].quantity = 0;
        }
      }
    });
    _items.clear(); // 결제 후 장바구니 비우기
    notifyListeners();
  }
}
