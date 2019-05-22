import 'package:flutter/material.dart';
import 'item.dart';

class AddItem extends StatefulWidget {
  @override
  _AddItemState createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _title;
  String _body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add Item'),
          actions: <Widget>[
            IconButton(icon: const Icon(Icons.done), onPressed: _doneAction),
          ],
        ),
        body: Container(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Title'),
                  validator: (value) =>
                      value.trim().isEmpty ? 'Title can\'t be empty' : null,
                  onSaved: (String value) => _title = value,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Body'),
                  validator: (value) =>
                      value.trim().isEmpty ? 'Body can\'t be empty' : null,
                  onSaved: (String value) => _body = value,
                ),
              ],
            ),
          ),
        ));
  }

  // Private Widgets

  // Private Methods
  bool _validateAndSave() {
    final FormState formState = _formKey.currentState;
    if (formState.validate()) {
      formState.save();
      return true;
    }

    return false;
  }

  _doneAction() {
    if (_validateAndSave()) {
      Item item = Item(_title, _body, "");
      Navigator.pop(context, item);
    }
  }
}
