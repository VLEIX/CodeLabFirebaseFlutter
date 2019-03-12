import 'package:flutter/material.dart';
import 'auth.dart';
import 'auth_provider.dart';
import 'login_page.dart';

enum AuthUserStatus {
  notDetermined,
  notSignedIn,
  signedIn,
}

class RootPage extends StatefulWidget {
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  AuthUserStatus authUserStatus = AuthUserStatus.notDetermined;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final BaseAuth auth = AuthProvider.of(context).auth;
    auth.currentUser().then((String userId) {
      setState(() {
        authUserStatus = userId == null
            ? AuthUserStatus.notSignedIn
            : AuthUserStatus.signedIn;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (authUserStatus) {
      case AuthUserStatus.notDetermined:
        return _buildWaitingScreen();
      case AuthUserStatus.notSignedIn:
        return LoginPage(
          onSignedIn: _signedIn,
        );
      case AuthUserStatus.signedIn:
        print('signedIn');
        break;
    }
    return null;
  }

  // Private Widgets
  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  // Private Methods
  void _signedIn() {
    setState(() {
      authUserStatus = AuthUserStatus.signedIn;
    });
  }

  void _signedOut() {
    setState(() {
      authUserStatus = AuthUserStatus.notSignedIn;
    });
  }
}
