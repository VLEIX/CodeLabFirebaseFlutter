import 'package:flutter/material.dart';
import 'auth.dart';
import 'auth_provider.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
//import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum FormType {
  login,
  registerEmail,
  registerPhone,
}

class EmailFieldValidator {
  static String validate(String value) {
    return value.isEmpty ? 'Email can\'t be empty' : null;
  }
}

class PasswordFieldValidator {
  static String validate(String value) {
    return value.isEmpty ? 'Password can\'t be empty' : null;
  }
}

class PhoneFieldValidator {
  static String validate(String value) {
    return value.isEmpty ? 'Phone can\'t be empty' : null;
  }
}

class LoginPage extends StatefulWidget {
  final VoidCallback onSignedIn;

  const LoginPage({this.onSignedIn});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _email;
  String _password;
  String _phoneNumber;
  String _smsCode;
  String _verificationId;

  FormType _formType = FormType.login;

  FacebookLogin _facebookLogin;
  GoogleSignIn _googleSignIn;
//  TwitterLogin _twitterLogin;

  @override
  void initState() {
    super.initState();

    _facebookLogin = FacebookLogin();
    _googleSignIn = GoogleSignIn();
//    _twitterLogin = TwitterLogin(consumerKey: 'yEOD8RE9uJvtcMRfvFtkYNtuE', consumerSecret: 'zn7FetFiDNv0lmA5gNd3mo4cwswsqDcPonT60tPA86nJTrfMDX');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _buildInputs() + _buildSubmitButtons(),
            )),
      ),
      resizeToAvoidBottomPadding: false,
    );
  }

  // Private Widgets
  List<Widget> _buildInputs() {
    if (_formType == FormType.registerPhone) {
      return <Widget>[
        TextFormField(
          key: Key('phone'),
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(labelText: 'Phone'),
          validator: PhoneFieldValidator.validate,
          onSaved: (String value) => _phoneNumber = value,
        ),
      ];
    } else {
      return <Widget>[
        TextFormField(
          key: Key('email'),
          decoration: InputDecoration(labelText: 'Email'),
          validator: EmailFieldValidator.validate,
          onSaved: (String value) => _email = value,
        ),
        TextFormField(
          key: Key('password'),
          obscureText: true,
          decoration: InputDecoration(labelText: 'Password'),
          validator: PasswordFieldValidator.validate,
          onSaved: (String value) => _password = value,
        ),
      ];
    }
  }

  Widget _raisedButton({@required Key key, @required String title, @required VoidCallback onPressed, Color color, Color textColor}) {
    return RaisedButton(
      key: key,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.0,
        ),
      ),
      color: color,
      textColor: textColor,
      onPressed: onPressed,
    );
  }

  Widget _flatButton({@required Key key, @required String title, @required VoidCallback onPressed}) {
    return FlatButton(
      key: key,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.0,
        ),
      ),
      onPressed: onPressed,
    );
  }

  List<Widget> _buildSubmitButtons() {
    if (_formType == FormType.login) {
      return <Widget>[
        _raisedButton(key: Key('logIn'), title: 'Login', onPressed: () {
          _validateAndSubmit();
        }),
        _raisedButton(key: Key('logInFacebook'), title: 'Login with Facebook', color: Color(0XFF4566BE), textColor: Colors.white, onPressed: () {
          _loginWithFacebook();
        }),
        _raisedButton(key: Key('logInGoogle'), title: 'Login with Google', color: Color(0XFFBF4D3B), textColor: Colors.white, onPressed: () {
          _loginWithGoogle();
        }),
//        _raisedButton(key: Key('logInTwitter'), title: 'Login with Twitter', color: Color(0XFF6DA9EE), textColor: Colors.white, onPressed: () {
//          _loginWithTwitter();
//        }),
//        _raisedButton(key: Key('logInGithub'), title: 'Login with Github', color: Colors.white, textColor: Colors.black, onPressed: () {
//          _validateAndSubmit();
//        }),
        _flatButton(key: Key('signUp'), title: 'Create an account', onPressed: () {
          _moveToRegisterWithEmail();
        }),
        _flatButton(key: Key('signUpPhone'), title: 'Create an account with phone', onPressed: () {
          _moveToRegisterWithPhone();
        }),
      ];
    } else {
      return <Widget>[
        _raisedButton(key: Key('createAccount'), title: 'Create an account', onPressed: () {
          _validateAndSubmit();
        }),
        _flatButton(key: Key('alreadyRegistered'), title: 'Have an account? Login', onPressed: () {
          _moveToLogin();
        }),
      ];
    }
  }

  // Private Methods
  bool validateAndSave() {
    final FormState formState = _formKey.currentState;
    if (formState.validate()) {
      formState.save();
      return true;
    }

    return false;
  }

  Future<void> _validateAndSubmit() async {
    if (validateAndSave()) {
      final BaseAuth auth = AuthProvider.of(context).auth;
      try {
        if (_formType == FormType.login) {
          final String userId = await auth.signInWithEmailAndPassword(
            _email,
            _password,
          );
          print('Signed in: $userId');
          _onSignedIn();
        } else if (_formType == FormType.registerEmail) {
          final String userId = await auth.createUserWithEmailAndPassword(
            _email,
            _password,
          );
          print('Registered with email: $userId');
          _onSignedIn();
        } else {
          _verificationId;
          final PhoneCodeAutoRetrievalTimeout autoRetrievalTimeout = (String verificationId) {
            _verificationId = verificationId;
            print('verifyPhoneNumber - PhoneCodeAutoRetrievalTimeout with verificationId: $_verificationId');
          };

          final PhoneCodeSent phoneCodeSent = (String verificationId, [int forceResendingToken]) {
            _verificationId = verificationId;
            print('verifyPhoneNumber - PhoneCodeSent with verificationId: $_verificationId');
            _smsCodeDialog();
          };

          final PhoneVerificationCompleted phoneVerificationCompleted = (FirebaseUser firebaseUser) {
            print('verifyPhoneNumber - PhoneVerificationCompleted');
          };

          final PhoneVerificationFailed phoneVerificationFailed = (AuthException error) {
            print('verifyPhoneNumber - PhoneVerificationFailed');
            print('${error.message}');
          };

          await auth.verifyPhoneNumber(_phoneNumber, autoRetrievalTimeout, phoneCodeSent, phoneVerificationCompleted, phoneVerificationFailed);
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  Future<bool> _smsCodeDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter SMS code'),
          content: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _smsCode = value;
            },
          ),
          contentPadding: EdgeInsets.all(10.0),
          actions: <Widget>[
            new FlatButton(
              child: Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
                _loginWithPhoneNumber();
              },
            ),
          ],
        );
      }
    );
  }

  Future<void> _loginWithFacebook() async {
    _facebookLogin.logInWithReadPermissions(['email', 'public_profile']).then((result) async {
      final BaseAuth auth = AuthProvider.of(context).auth;

      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          print('Signed in with Facebook - loggedIn');
          final String userId = await auth.signInWithCredential(
            authProviderType: AuthProviderType.facebook,
            accessToken: result.accessToken.token,
          );
          _onSignedIn();
          print('Signed in with Facebook: $userId');
          break;
        case FacebookLoginStatus.cancelledByUser:
          print('Signed in with Facebook - cancelledByUser');
          break;
        case FacebookLoginStatus.error:
          print('Signed in with Facebook - error');
          break;
      }
    }).catchError((e) {
      print(e);
    });
  }

  Future<void> _loginWithGoogle() async {
    _googleSignIn.signIn().then((result) async {
      result.authentication.then((googleKey) async {
        final BaseAuth auth = AuthProvider.of(context).auth;

        final String userId = await auth.signInWithCredential(
          authProviderType: AuthProviderType.google,
          idToken: googleKey.idToken,
          accessToken: googleKey.accessToken,
        );
        _onSignedIn();
        print('Signed in with Google: $userId');
      }).catchError((e) {
        print(e);
      });
    }).catchError((e) {
      print(e);
    });
  }
  
//  Future<void> _loginWithTwitter() async {
//    _twitterLogin.authorize().then((result) async {
//      final BaseAuth auth = AuthProvider.of(context).auth;
//
//      switch(result.status) {
//        case TwitterLoginStatus.loggedIn:
//          print('Signed in with Twitter - loggedIn');
//          final String userId = await auth.signInWithCredential(
//            authProviderType: AuthProviderType.twitter,
//            idToken: result.session.token,
//            accessToken: result.session.secret,
//          );
//          _onSignedIn();
//          print('Signed in with Twitter: $userId');
//          break;
//        case TwitterLoginStatus.cancelledByUser:
//          print('Signed in with Twitter - cancelledByUser');
//          break;
//        case TwitterLoginStatus.error:
//          print('Signed in with Twitter - error');
//          break;
//      }
//    }).catchError((e) {
//      print(e);
//    });
//  }

  Future<void> _loginWithPhoneNumber() async {
    final BaseAuth auth = AuthProvider.of(context).auth;

    final String userId = await auth.signInWithCredential(
      authProviderType: AuthProviderType.phone,
      idToken: _verificationId,
      accessToken: _smsCode,
    );
    _onSignedIn();
    print('Registered with phone: $userId');
  }

  void _moveToRegisterWithEmail() {
    _formKey.currentState.reset();

    setState(() {
      _formType = FormType.registerEmail;
    });
  }

  void _moveToRegisterWithPhone() {
    _formKey.currentState.reset();

    setState(() {
      _formType = FormType.registerPhone;
    });
  }

  void _moveToLogin() {
    _formKey.currentState.reset();

    setState(() {
      _formType = FormType.login;
    });
  }

  void _onSignedIn() {
    widget.onSignedIn(); // callback to launch the new screen
  }
}
