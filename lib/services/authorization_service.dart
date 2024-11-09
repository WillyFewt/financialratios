import 'package:financialratios/exceptions/FirebaseException.dart';
import 'package:financialratios/models/user.dart';
import 'package:financialratios/repositories/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class AuthorizationService {
  static AuthorizationService _instance;
  List<String> errorMessage = [];

  AuthorizationService._init();

  static AuthorizationService get instance {
    if (_instance == null) {
      _instance = AuthorizationService._init();
    }
    return _instance;
  }

  Future<User> getUser() async {
    FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
    if (firebaseUser != null) {
      return await convertUser(firebaseUser);
    }
    return null;
  }

  Future<User> login(String email, String password) async {
    final AuthCredential credential =
        EmailAuthProvider.getCredential(email: email, password: password);
    AuthResult result =
        await FirebaseAuth.instance.signInWithCredential(credential);
    if (result.user != null) {
      return await convertUser(result.user);
    }
    return null;
  }

  Future<User> convertUser(FirebaseUser firebaseUser) async {
    User user = await UserRepository.instance.createFromFirebase(firebaseUser);
    return user;
  }

  Future logout() async {
    await FirebaseAuth.instance.signOut();
  }

  //firebase_auth reauthenicated bug workaround
  Future<FirebaseUser> reauthenticate(String email, String password) async {
    AuthResult result = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    return result.user;
  }

  Future<void> resetPassword(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }
}
