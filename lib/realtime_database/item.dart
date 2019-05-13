import 'package:firebase_database/firebase_database.dart';

class Item {
  String key;
  String title;
  String body;

  Item(this.title, this.body);

  Item.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        title = snapshot.value['title'],
        body = snapshot.value['body'];

  toJson() {
    return {
      "title": title,
      "body": body,
    };
  }
}
