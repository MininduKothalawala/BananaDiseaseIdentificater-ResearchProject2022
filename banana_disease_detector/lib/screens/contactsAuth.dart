// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use

import 'dart:io';

import "package:banana_disease_detector/common/colors.style.dart";
import 'package:banana_disease_detector/models/farmer.model.dart';
import 'package:banana_disease_detector/screens/detected.dart';
import 'package:banana_disease_detector/screens/image_detect.dart';
import 'package:banana_disease_detector/screens/text_detection.dart';
import 'package:banana_disease_detector/screens/welcome.screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ContactsAuth extends StatefulWidget {
  final Farmer farmer;
  ContactsAuth({Key? key, required this.farmer}) : super(key: key);
  @override
  _ContactsAuthState createState() => _ContactsAuthState();
}

class _ContactsAuthState extends State<ContactsAuth> {
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
                  Text("Contact Person")
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
                        onTap: () {},
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Contact 1"),
                                Text("Replace text with appropriate content")
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {},
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Contact 2"),
                                Text("Replace text with appropriate content")
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {},
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Contact 3"),
                                Text("Replace text with appropriate content")
                              ],
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
