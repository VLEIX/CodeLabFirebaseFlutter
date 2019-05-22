import 'package:flutter/material.dart';
import 'auth.dart';
import 'auth_provider.dart';
import 'package:codelabs_firebase_flutter/realtime_database/list_items.dart';

class HomePage extends StatelessWidget {
  final VoidCallback onSignedOut;
  final String userId;

  const HomePage(this.onSignedOut, this.userId);

  @override
  Widget build(BuildContext context) {
    return ListItems(sadasd, userId);
//    return Scaffold(
//      appBar: AppBar(
//        title: Text('Welcome'),
//        actions: <Widget>[
//          FlatButton(
//            child: Text(
//              'Logout',
//              style: TextStyle(
//                fontSize: 17.0,
//                color: Colors.white,
//              ),
//            ),
//            onPressed: () => _signOut(context),
//          ),
//        ],
//      ),
//      body: Container(
//        child: Center(
//          child: Text(
//            'Welcome',
//            style: TextStyle(fontSize: 32.0),
//          ),
//        ),
//      ),
//    );
  }

  // Private Methods
  void sadasd() {

  }

  Future<void> _signOut(BuildContext context) async {
    try {
      final BaseAuth auth = AuthProvider.of(context).auth;
      await auth.signOut();

      onSignedOut(); // // callback to launch the new screen
    } catch (e) {
      print(e);
    }
  }
}
