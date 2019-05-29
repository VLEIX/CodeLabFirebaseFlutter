import 'package:firebase_database/firebase_database.dart';
import 'item.dart';

class ItemUtil {
  DatabaseReference _itemDBReference;
  FirebaseDatabase _database = FirebaseDatabase();
  DatabaseError error;

  static final ItemUtil _instance = ItemUtil.internal();

  ItemUtil.internal();

  factory ItemUtil() {
    return _instance;
  }

  void initState() {
    _itemDBReference = _database.reference().child('items');
    _database.setPersistenceEnabled(true);
    _database.setPersistenceCacheSizeBytes(10000000); // 10MB
    _itemDBReference.keepSynced(true);
  }

  DatabaseError getError() {
    return error;
  }

  DatabaseReference getItemDBReference() {
    return _itemDBReference;
  }

  addItem(Item item) async {
    await _itemDBReference.push().set(item.toJson()).then((_) {
      print('Item added');
    });
  }

  updateItem(Item item) async {
    await _itemDBReference.child(item.key).update(item.toJson()).then((_) {
      print('Item updated');
    });
  }

  deleteItem(Item item) async {
    await _itemDBReference.child(item.key).remove().then((_) {
      print('Item deleted');
    });
  }
}