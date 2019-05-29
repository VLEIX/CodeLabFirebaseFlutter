import 'package:flutter/material.dart';
import 'item.dart';

enum FormType {
  addItem,
  updateItem,
}

class AddItem extends StatefulWidget {
  final Item itemReceived;

  AddItem({this.itemReceived = null});

  @override
  _AddItemState createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  FormType _formType = FormType.addItem;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _title;
  String _body;

  TextEditingController _txtTitleController;
  TextEditingController _txtBodyController;

  @override
  void initState() {
    super.initState();

    _txtTitleController = TextEditingController();
    _txtBodyController = TextEditingController();

    _validateFormType();
    _setInitValues();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_validateTitle()),
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.done), onPressed: _doneAction),
        ],
      ),
      body: _showBody(),
    );
  }

  // Private Widgets
  Widget _showBody() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: _txtTitleController,
              decoration: InputDecoration(labelText: 'Title'),
              validator: (value) =>
                  value.trim().isEmpty ? 'Title can\'t be empty' : null,
              onSaved: (String value) => _title = value,
            ),
            TextFormField(
              controller: _txtBodyController,
              decoration: InputDecoration(labelText: 'Body'),
              validator: (value) =>
                  value.trim().isEmpty ? 'Body can\'t be empty' : null,
              onSaved: (String value) => _body = value,
            ),
          ],
        ),
      ),
    );
  }

  // Private Methods
  void _validateFormType() {
    _formType =
        widget.itemReceived == null ? FormType.addItem : FormType.updateItem;
  }

  String _validateTitle() {
    return _formType == FormType.addItem ? 'Add item' : 'Update item';
  }

  void _setInitValues() {
    if (_formType == FormType.updateItem) {
      _txtTitleController.text = widget.itemReceived.title;
      _txtBodyController.text = widget.itemReceived.body;
    }
  }

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
      Item item;
      if (_formType == FormType.addItem) {
        item = Item(_title, _body);
      } else {
        item = widget.itemReceived;
        item.title = _title;
        item.body = _body;
      }
      Navigator.pop(context, item);
    }
  }
}
