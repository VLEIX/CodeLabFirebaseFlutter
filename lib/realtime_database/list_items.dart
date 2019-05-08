import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'item.dart';
import 'add_item.dart';

class ListItems extends StatefulWidget {
  @override
  _ListItemsState createState() => _ListItemsState();
}

class _ListItemsState extends State<ListItems> {
  List<Item> items = List();

  DatabaseReference _databaseReference;

  @override
  void initState() {
    super.initState();

    final FirebaseDatabase database = FirebaseDatabase.instance;
    _databaseReference = database.reference().child('items');
    _databaseReference.onChildAdded.listen(_onEntryAdded);
    _databaseReference.onChildChanged.listen(_onEntryChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List Items'),
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: _buildAnimatedList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
//          Navigator.push(
//            context,
//            MaterialPageRoute(builder: (context) => AddItem()),
//          );

          Item item = Item("holi", "boli");
          _databaseReference.push().set(item.toJson());
        },
        tooltip: 'Add Item',
        child: Icon(Icons.add),
      ),
    );
  }

  // Private Widgets
  FirebaseAnimatedList _buildAnimatedList() {
    return FirebaseAnimatedList(
        query: _databaseReference,
        itemBuilder: (BuildContext context, DataSnapshot snapshot,
            Animation<double> animation, int index) {
          return ListTile(
            leading: Icon(Icons.message),
            title: Text(items[index].title),
            subtitle: Text(items[index].body),
          );
        });
  }

  // Private Methods
  _onEntryAdded(Event event) {
    setState(() {
      items.add(Item.fromSnapshot(event.snapshot));
    });
  }

  _onEntryChanged(Event event) {
    var old = items.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      items[items.indexOf(old)] = Item.fromSnapshot(event.snapshot);
    });
  }
}
