import 'package:flutter/material.dart';
import 'auth.dart';
import 'auth_provider.dart';
import 'login_page.dart';
import 'home_page.dart';

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
        if (userId == null) {
          authUserStatus = AuthUserStatus.notSignedIn;
          //TODO: show error
          print('userId: $userId');
        } else {
          auth.isEmailVerified().then((bool isEmailVerified) {
            if (!isEmailVerified) {
              authUserStatus = AuthUserStatus.notSignedIn;
              //TODO: show error isEmailVerified
              //check if this is necessary
              print('isEmailVerified: $isEmailVerified');
            } else {
              authUserStatus = AuthUserStatus.signedIn;
            }
          });
        }
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
        return HomePage(
          onSignedOut: _signedOut,
        );
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
