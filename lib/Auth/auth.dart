import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthFunction {
  Future<String> login(String email, String password);
  Future<String> signUp(String email, String password);
  Future<String> getUser();
  Future<String> getEmail();
  Future<void> signOut();
}

class Authentic implements AuthFunction {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> login(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    await user.reload();
    user = await FirebaseAuth.instance.currentUser();
    bool flag = user.isEmailVerified;
    if (flag == true) {
      return user.uid;
    } else {
      return "Email is not verified yet";
    }
  }

  Future<String> signUp(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    _firebaseAuth.signOut();
    return user.uid;
  }

  Future<String> getUser() async {
    FirebaseUser user;
    try {
      user = await _firebaseAuth.currentUser();
    } catch (e) {
      print(e);
    }
    if (user.isEmailVerified == false) {
      return "Not Verified User";
    } else {
      return user.uid;
    }
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<String> getEmail() async {
    FirebaseUser user;
    try {
      user = await _firebaseAuth.currentUser();
    } catch (e) {
      print(e);
    }
    return user.email;
  }
}
