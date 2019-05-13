import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'item.dart';
import 'add_item.dart';
import 'dart:async';

class ListItems extends StatefulWidget {
  @override
  _ListItemsState createState() => _ListItemsState();
}

class _ListItemsState extends State<ListItems> {
  List<Item> _items = List();

  DatabaseReference _itemsDBReference;
  StreamSubscription<Event> _onItemsAddedSubscription;
  StreamSubscription<Event> _onItemsChangedSubscription;
  StreamSubscription<Event> _onItemsRemovedSubscription;

  @override
  void initState() {
    super.initState();

    final FirebaseDatabase database = FirebaseDatabase.instance;
    database.setPersistenceEnabled(true);
    database.setPersistenceCacheSizeBytes(10000000); // 10MB

    _itemsDBReference = database.reference().child('items');
    _itemsDBReference.keepSynced(true);

    _onItemsAddedSubscription = _itemsDBReference.onChildAdded.listen(_onEntryAdded);
    _onItemsChangedSubscription = _itemsDBReference.onChildChanged.listen(_onEntryChanged);
    _onItemsRemovedSubscription = _itemsDBReference.onChildRemoved.listen(_onEntryRemoved);
  }

  @override
  void dispose() {
    _onItemsAddedSubscription.cancel();
    _onItemsChangedSubscription.cancel();
    _onItemsRemovedSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List Items'),
      ),
      resizeToAvoidBottomPadding: false,
      body: Column(
        children: <Widget>[
          Flexible(
            child: _buildAnimatedList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToAddItem();
        },
        tooltip: 'Add Item',
        child: Icon(Icons.add),
      ),
    );
  }

  // Private Widgets
  FirebaseAnimatedList _buildAnimatedList() {
    return FirebaseAnimatedList(
        query: _itemsDBReference,
        itemBuilder: (BuildContext context, DataSnapshot snapshot,
            Animation<double> animation, int index) {
          return Dismissible(
            key: Key(_items[index].key),
            onDismissed: (direction) async {
//              setState(() {
                _itemsDBReference.child(_items[index].key).remove().then((_) {
//                  print('temsDBReference.child(_items[in');
                  setState(() {
                    _items.removeAt(index);
                  });
                });
//              });
//
//              String _textToSnackBar;
//              if (direction == DismissDirection.endToStart) {
//                _textToSnackBar = 'dismissed';
//              } else if (direction == DismissDirection.startToEnd) {
//                _textToSnackBar = 'saved';
//              }
//
//              Scaffold.of(context).showSnackBar(
//                  SnackBar(content: Text('$item $_textToSnackBar')));
            },
            background: Container(
              color: Colors.red,
            ),
            child: ListTile(
              leading: Icon(Icons.message),
              title: Text(_items[index].title),
              subtitle: Text(_items[index].body),
            ),
          );
        });
  }

  // Private Methods
  _navigateToAddItem() async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => AddItem()));

    if (result != null) {
      Item item = result;
      _itemsDBReference.push().set(item.toJson());
    }
  }

  _onEntryAdded(Event event) {
    if (!mounted) return;
    setState(() {
      _items.add(Item.fromSnapshot(event.snapshot));
    });
  }

  _onEntryChanged(Event event) {
    var old = _items.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    if (!mounted) return;
    setState(() {
      _items[_items.indexOf(old)] = Item.fromSnapshot(event.snapshot);
    });
  }

  _onEntryRemoved(Event event) {
    print('_onEntryRemoved');

//    var old = _items.singleWhere((entry) {
//      return entry.key == event.snapshot.key;
//    });

//    setState(() {
//      _items.remove(event);
//    });
  }
}
