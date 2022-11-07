import 'package:banana_disease_detector/models/farmer.model.dart';
import 'package:banana_disease_detector/screens/disease_select.dart';
import 'package:banana_disease_detector/screens/image_detect.dart';
import 'package:banana_disease_detector/screens/login.dart';
import 'package:banana_disease_detector/screens/map_view.dart';
import 'package:banana_disease_detector/screens/notification.dart';
import 'package:banana_disease_detector/screens/registerPage.dart';
import 'package:banana_disease_detector/screens/registerPageInstructor.dart';
import 'package:banana_disease_detector/screens/splash.dart';
import 'package:banana_disease_detector/screens/welcomInstructor.dart';
import 'package:banana_disease_detector/screens/welcome.screen.dart';
import 'package:flutter/material.dart';

class Navigate {
  static Map<String, Widget Function(BuildContext)> routes = {
    // '/': (context) => WelcomePage(),
    '/splash': (context) => SplashScreen(),
    '/signIn': (context) => Login(),
    '/signInInstructor': (context) => Login(),
    '/signUp': (context) => Signup(),
    '/signUpInstructor': (context) => SignupInstructor(),
    '/welcome': (context) => WelcomeScreen(
          farmer: Farmer(
              name: "name",
              type: "type",
              address: "address",
              banana_type: "banana_type",
              phone: "phone",
              long: 78,
              lat: 87),
        ),
    // '/imageDetect': (context) => ImageDetect(),
    // '/diseaseSelect': (context) => DiseaseSelect(),
    '/mapView': (context) => MapView(
          farmer: null,
        ),
    '/disease': (context) => DiseaseSelect(
          farmer: Farmer(
              name: "name",
              type: "type",
              address: "address",
              banana_type: "banana_type",
              phone: "phone",
              long: 78,
              lat: 87),
        ),
    '/welcomeInstructor': (context) => WelcomeInstructor(
          instructor: null,
        ),
    '/noti': (context) => NotificationScreen(
          instructor: null,
        )
  };
}
