import 'package:flutter/foundation.dart';

class Item {
  String name;
  final int quantity;
  final String brand;
  final String type;
  final bool purchased;

  Item(
      {required this.name,
      required this.quantity,
      required this.brand,
      required this.type,
      required this.purchased});
}

class ShoppingListProvider extends ChangeNotifier {
  List<Item> _items = [];

  List<Item> get items => _items;

  void addItem(Item newItem) {
    _items.add(newItem);
    notifyListeners();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void updateItemName(int index, String newName) {
  items[index].name = newName;
  notifyListeners();
}

}
