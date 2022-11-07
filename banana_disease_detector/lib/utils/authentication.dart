import 'dart:async';

import 'package:banana_disease_detector/models/farmer.model.dart';
import 'package:banana_disease_detector/models/instructor.model.dart';
import 'package:banana_disease_detector/repository/farmer.repo.dart';
import 'package:banana_disease_detector/repository/instructor.repo.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String KEY_TOKEN = "KEY_TOKEN";

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FarmerRepository farmerRepository = FarmerRepository();
  final InstructorRepository instructorRepository = InstructorRepository();
  SharedPreferences? sharedPreferences;
  get user => _auth.currentUser;

  Future<String?> signIn(
      {required String email, required String password}) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential.user?.uid;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<SharedPreferences?> getSharedPreferencesObject() async {
    if (sharedPreferences != null)
      return sharedPreferences;
    else
      return SharedPreferences.getInstance();
  } // getSharedPreferencesObject

  Future<bool?> saveTokenToLocalStorage(String token) async {
    sharedPreferences = await getSharedPreferencesObject();
    return sharedPreferences?.setString(KEY_TOKEN, token);
  } // saveTokenToLocalStorage()

  Future<String?> readTokenFromLocalStorage() async {
    sharedPreferences = await getSharedPreferencesObject();
    return sharedPreferences?.getString(KEY_TOKEN);
  } // readTokenFromLocalStorage

  Future<bool?> removeTokenFromLocalStorage() async {
    sharedPreferences = await getSharedPreferencesObject();
    return sharedPreferences?.remove(KEY_TOKEN);
  } //

  //SIGN OUT METHOD
  Future signOut() async {
    removeTokenFromLocalStorage();
    await _auth.signOut();
    print('signout');
  }

  Future signUp(
      String email,
      String password,
      String name,
      String type,
      String address,
      String phone,
      String banana_type,
      double long,
      double lat) async {
    try {
      await _auth
          .createUserWithEmailAndPassword(
            email: email,
            password: password,
          )
          .then((value) => farmerRepository.addNewFarmer(
              Farmer(
                  name: name,
                  type: type,
                  address: address,
                  phone: phone,
                  banana_type: banana_type,
                  long: long,
                  lat: lat),
              value.user!.uid));
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future signUpInstructor(
      String email,
      String password,
      String name,
      String address,
      String phone,
      String token,
      double long,
      double lat) async {
    try {
      await _auth
          .createUserWithEmailAndPassword(
            email: email,
            password: password,
          )
          .then((value) => instructorRepository.addNewInstructor(
              Instructor(
                  name: name,
                  token: token,
                  address: address,
                  phone: phone,
                  long: long,
                  lat: lat),
              value.user!.uid));
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String> getCurrentUser() async {
    User user = _auth.currentUser!;
    return user.email.toString();
  }
}

// Future<void> sendEmailVerification() async {
//   FirebaseUser user = await _firebaseAuth.currentUser();
//   user.sendEmailVerification();
// }
//
// Future<bool> isEmailVerified() async {
//   FirebaseUser user = await _firebaseAuth.currentUser();
//   return user.isEmailVerified;
// }
//
// @override
// Future<void> changeEmail(String email) async {
//   FirebaseUser user = await _firebaseAuth.currentUser();
//   user.updateEmail(email).then((_) {
//     print("Succesfull changed email");
//   }).catchError((error) {
//     print("email can't be changed" + error.toString());
//   });
//   return null;
// }
//
// @override
// Future<void> changePassword(String password) async {
//   FirebaseUser user = await _firebaseAuth.currentUser();
//   user.updatePassword(password).then((_) {
//     print("Succesfull changed password");
//   }).catchError((error) {
//     print("Password can't be changed" + error.toString());
//   });
//   return null;
// }
//
// @override
// Future<void> deleteUser() async {
//   FirebaseUser user = await _firebaseAuth.currentUser();
//   user.delete().then((_) {
//     print("Succesfull user deleted");
//   }).catchError((error) {
//     print("user can't be delete" + error.toString());
//   });
//   return null;
// }
//
// @override
// Future<void> sendPasswordResetMail(String email) async {
//   await _firebaseAuth.sendPasswordResetEmail(email: email);
//   return null;
// }
