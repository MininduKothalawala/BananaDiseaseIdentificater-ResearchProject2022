// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use

import 'dart:io';

import 'package:banana_disease_detector/common/colors.style.dart';
import 'package:banana_disease_detector/models/farmer.model.dart';
import 'package:banana_disease_detector/screens/detected.dart';
import 'package:banana_disease_detector/screens/image_detect.dart';
import 'package:banana_disease_detector/screens/image_detect2.dart';
import 'package:banana_disease_detector/screens/image_detect4.dart';
import 'package:banana_disease_detector/screens/text_detection.dart';
import 'package:banana_disease_detector/screens/welcome.screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'image_detect3.dart';

// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class DiseaseSelect extends StatefulWidget {
  final Farmer farmer;
  DiseaseSelect({Key? key, required this.farmer}) : super(key: key);
  @override
  _DiseaseSelectState createState() => _DiseaseSelectState();
}

class _DiseaseSelectState extends State<DiseaseSelect> {
  late FirebaseMessaging messaging;
  final GlobalKey<ScaffoldState> _scaffoldKeyDisease =
      GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value) {
      print(value);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("message recieved");
      print(event.notification!.body);
      var snackbar = new SnackBar(
        content: new Text(event.notification!.body.toString()),
        backgroundColor: Colors.redAccent,
      );
      _scaffoldKeyDisease.currentState?.showSnackBar(snackbar);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
    });
    messaging.getToken().then((token) {
      print(token);
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        key: _scaffoldKeyDisease,
        body: Stack(
          children: [
            Container(
              height: height * 0.3,
              decoration: BoxDecoration(
                  color: backgroundGreen,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15))),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WelcomeScreen(
                                      farmer: widget.farmer,
                                    )));
                      },
                      icon: Icon(Icons.arrow_back_ios)),
                  Text("disease_select".tr())
                ],
              ),
            ),
            Stack(
              children: <Widget>[
                Positioned(
                  top: height * 0.15,
                  left: 5,
                  right: 5,
                  bottom: 10,
                  child: ListView(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ImageDetect3(
                                    farmer: widget.farmer,
                                  )));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.greenAccent.shade100,
                              borderRadius:
                              BorderRadius.all(Radius.circular(40)),
                              border: Border.all(
                                  color: Colors.grey.shade100,
                                  width: 5.0,
                                  style: BorderStyle.solid),
                            ),
                            child: Center(
                              child: Text("image_detection_leaf".tr()),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ImageDetect2(
                                        farmer: widget.farmer,
                                      )));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.greenAccent.shade100,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40)),
                              border: Border.all(
                                  color: Colors.grey.shade100,
                                  width: 5.0,
                                  style: BorderStyle.solid),
                            ),
                            child: Center(
                              child: Text("image_detection_plant".tr()),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ImageDetect4(
                                    farmer: widget.farmer,
                                  )));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.greenAccent.shade100,
                              borderRadius:
                              BorderRadius.all(Radius.circular(40)),
                              border: Border.all(
                                  color: Colors.grey.shade100,
                                  width: 5.0,
                                  style: BorderStyle.solid),
                            ),
                            child: Center(
                              child: Text("test"),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TextDetection(
                                        farmer: widget.farmer,
                                      )));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.greenAccent.shade100,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40)),
                              border: Border.all(
                                  color: Colors.grey.shade100,
                                  width: 5.0,
                                  style: BorderStyle.solid),
                            ),
                            child: Center(
                              child: Text("text_detection".tr()),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DetectedScreen(
                                        farmer: widget.farmer,
                                      )));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.greenAccent.shade100,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40)),
                              border: Border.all(
                                  color: Colors.grey.shade100,
                                  width: 5.0,
                                  style: BorderStyle.solid),
                            ),
                            child: Center(
                              child: Text("disease_detection".tr()),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            )
          ],
        ));
  }
}
