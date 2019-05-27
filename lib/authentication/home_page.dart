import 'package:flutter/material.dart';
import 'auth.dart';
import 'auth_provider.dart';
import 'package:codelabs_firebase_flutter/realtime_database/list_items.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onSignedOut;

  HomePage({this.onSignedOut});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userId;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    final BaseAuth auth = AuthProvider.of(context).auth;
    await auth.currentUser().then((String userId) {
      setState(() {
        _userId = userId;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _userId != null ? ListItems(_signOut, _userId) : _buildWaitingScreen();
  }

  // Private Methods
  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      final BaseAuth auth = AuthProvider.of(context).auth;
      await auth.signOut();

      widget.onSignedOut(); // // callback to launch the new screen
    } catch (e) {
      print(e);
    }
  }
}
