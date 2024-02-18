import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth {
  Future<String> signIn(String email, String password);
  Future<String> signUp(String email, String password);
  Future<User?> getCurrentUser();
  Future<String?> getIdToken();
  Future<void> signOut();
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signIn(String email, String password) async {
    UserCredential user = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    return user.user!.uid;
  }

  Future<String> signUp(String email, String password) async {
    UserCredential user = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    return user.user!.uid;
  }

  Future<User?> getCurrentUser() async {
    return await _firebaseAuth.currentUser;
  }

  Future<String?> getIdToken() async {
    User? user = await getCurrentUser();

    return user?.getIdToken(true);
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }
}