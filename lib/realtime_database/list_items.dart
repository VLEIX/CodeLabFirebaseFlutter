import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'item.dart';
import 'add_item.dart';
import 'item_util.dart';

class ListItems extends StatefulWidget {
  @override
  _ListItemsState createState() => _ListItemsState();
}

class _ListItemsState extends State<ListItems> {
  ItemUtil _itemUtil;

  @override
  void initState() {
    super.initState();

    _itemUtil = ItemUtil();
    _itemUtil.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('List items')),
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
        query: _itemUtil.getItemDBReference(),
        itemBuilder: (BuildContext context, DataSnapshot snapshot,
            Animation<double> animation, int index) {
          Item item = Item.fromSnapshot(snapshot);
          return Dismissible(
            key: Key(item.key),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                _navigateToEditItem(item);
              } else if (direction == DismissDirection.endToStart) {
                _showDeleteConfirmationDialog(item);
              }
              return false;
            },
            background: Container(
              padding: const EdgeInsets.only(left: 16.0),
              alignment: Alignment.centerLeft,
              color: Colors.amber,
              child: IconTheme(
                data: IconThemeData(color: Colors.white),
                child: Icon(Icons.edit),
              ),
            ),
            secondaryBackground: Container(
              padding: const EdgeInsets.only(right: 16.0),
              alignment: Alignment.centerRight,
              color: Colors.red,
              child: IconTheme(
                data: IconThemeData(color: Colors.white),
                child: Icon(Icons.delete),
              ),
            ),
            child: ListTile(
              leading: Icon(Icons.message),
              title: Text(item.title),
              subtitle: Text(item.body),
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

      await _addItem(item);
    }
  }

  _navigateToEditItem(Item item) async {
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => AddItem(itemReceived: item)));

    if (result != null) {
      Item item = result;

      await _updateItem(item);
    }
  }

  _addItem(Item item) async {
    setState(() {
      _itemUtil.addItem(item);
    });
  }

  _updateItem(Item item) async {
    setState(() {
      _itemUtil.updateItem(item);
    });
  }

  _deleteItem(Item item) async {
    setState(() {
      _itemUtil.deleteItem(item);
    });
  }

  _showDeleteConfirmationDialog(Item item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text('Delete item'),
          content: new Text('Are you sure to delete the item ${item.title}?'),
          actions: <Widget>[
            FlatButton(
              child: new Text("NO"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: new Text("YES"),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteItem(item);
              },
            ),
          ],
        );
      },
    );
  }
}
