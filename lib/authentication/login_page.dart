import 'package:flutter/material.dart';
import 'auth.dart';
import 'auth_provider.dart';

enum FormType {
  login,
  register,
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
  FormType _formType = FormType.login;

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
    );
  }

  // Private Widgets
  List<Widget> _buildInputs() {
    return <Widget>[
      TextFormField(
        key: Key('email'),
        decoration: InputDecoration(labelText: 'Email'),
        validator: EmailFieldValidator.validate,
        onSaved: (String value) => _email = value,
      ),
      TextFormField(
        key: Key('password'),
        decoration: InputDecoration(labelText: 'Password'),
        validator: PasswordFieldValidator.validate,
        onSaved: (String value) => _password = value,
      ),
    ];
  }

  List<Widget> _buildSubmitButtons() {
    if (_formType == FormType.login) {
      return <Widget>[
        RaisedButton(
          key: Key('signIn'),
          child: Text(
            'Login',
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          onPressed: _validateAndSubmit,
        ),
        FlatButton(
          child: Text(
            'Create an account',
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          onPressed: moveToRegister,
        ),
      ];
    } else {
      return <Widget>[
        RaisedButton(
          child: Text(
            'Create an account',
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          onPressed: _validateAndSubmit,
        ),
        FlatButton(
          child: Text(
            'Have an account? Login',
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          onPressed: moveToLogin,
        ),
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
      try {
        final BaseAuth auth = AuthProvider.of(context).auth;
        if (_formType == FormType.login) {
          final String userId = await auth.signInWithEmailAndPassword(
            _email,
            _password,
          );
          print('Signed in: $userId');
        } else {
          final String userId = await auth.createUserWithEmailAndPassword(
            _email,
            _password,
          );
          print('Registered user: $userId');
        }
        widget.onSignedIn(); // callback to launch the new screen
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  void moveToRegister() {
    _formKey.currentState.reset();

    setState(() {
      _formType = FormType.register;
    });
  }

  void moveToLogin() {
    _formKey.currentState.reset();

    setState(() {
      _formType = FormType.login;
    });
  }
}
