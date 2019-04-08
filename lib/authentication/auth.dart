import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

enum AuthProviderType {
  facebook,
  google,
  twitter,
  github,
  phone,
}

abstract class BaseAuth {
  Future<String> signInWithEmailAndPassword(String email, String password);
  Future<String> createUserWithEmailAndPassword(String email, String password);
  Future<String> verifyPhoneNumber(String phoneNumber);
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
        authCredential = TwitterAuthProvider.getCredential(authToken: idToken, authTokenSecret: accessToken);
        break;
      case AuthProviderType.github:
        authCredential = GithubAuthProvider.getCredential(token: accessToken);
        break;
      case AuthProviderType.phone:
        authCredential = PhoneAuthProvider.getCredential(verificationId: idToken, smsCode: accessToken);
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
  Future<String> verifyPhoneNumber(String phoneNumber) async {
    String _verificationId;
    final PhoneCodeAutoRetrievalTimeout autoRetrievalTimeout = (String verificationId) {
      _verificationId = verificationId;
    };

    final PhoneCodeSent phoneCodeSent = (String verificationId, [int forceResendingToken]) {
      _verificationId = verificationId;
    };

    final PhoneVerificationCompleted phoneVerificationCompleted = (FirebaseUser firebaseUser) {
      print('verifyPhoneNumber - completed');
    };

    final PhoneVerificationFailed phoneVerificationFailed = (AuthException error) {
      print('verifyPhoneNumber - failed');
      print('${error.message}');
    };

    await _firebaseAuth.verifyPhoneNumber(phoneNumber: phoneNumber, timeout: const Duration(seconds: 5), verificationCompleted: phoneVerificationCompleted, verificationFailed: phoneVerificationFailed, codeSent: phoneCodeSent, codeAutoRetrievalTimeout: autoRetrievalTimeout);

    return _verificationId;
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