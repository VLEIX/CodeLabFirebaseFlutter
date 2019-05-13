import 'item.dart';
import 'DAO.dart';

class ItemDAO implements DAO<Item> {

  List<Item> _items = List<Item>();

  ItemDAO(this._items);

  @override
  Item get(int index) {
    return _items[index];
  }

  @override
  List<Item> getAll() {
    return _items;
  }

  @override
  void add(Item t) {
    _items.add(t);
  }

  @override
  void update(Item t) {
    // TODO: implement update
  }

  @override
  void delete(Item t) {
    _items.remove(t);
  }
}