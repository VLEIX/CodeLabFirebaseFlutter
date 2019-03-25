import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

enum AuthProviderType {
  facebook,
  google,
  twitter,
  github,
}

abstract class BaseAuth {
  Future<String> signInWithEmailAndPassword(String email, String password);
  Future<String> createUserWithEmailAndPassword(String email, String password);
  Future<String> signInWithCredential({AuthProviderType authProviderType, String idToken, String accessToken});
  Future<String> currentUser();
  Future<void> signOut();
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<String> signInWithEmailAndPassword(String email, String password) async {
    final FirebaseUser user = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    return user?.uid;
  }

  @override
  Future<String> signInWithCredential({AuthProviderType authProviderType, String idToken, String accessToken}) async {
    AuthCredential authCredential;

    switch(authProviderType) {
      case AuthProviderType.facebook:
        authCredential = FacebookAuthProvider.getCredential(accessToken: accessToken);
        break;
      case AuthProviderType.google:
        authCredential = GoogleAuthProvider.getCredential(idToken: idToken, accessToken: accessToken);
        break;
      case AuthProviderType.twitter:
//        authCredential = TwitterAuthProvider.getCredential(authToken: null, authTokenSecret: null)
        break;
      case AuthProviderType.github:
        authCredential = GithubAuthProvider.getCredential(token: accessToken);
        break;
    }

    final FirebaseUser user = await _firebaseAuth.signInWithCredential(authCredential);
    return user?.uid;
  }

  @override
  Future<String> createUserWithEmailAndPassword(String email, String password) async {
    final FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    return user?.uid;
  }

  @override
  Future<String> currentUser() async {
    final FirebaseUser user = await _firebaseAuth.currentUser();
    return user?.uid;
  }

  @override
  Future<void> signOut() async {
    return await _firebaseAuth.signOut();
  }
}