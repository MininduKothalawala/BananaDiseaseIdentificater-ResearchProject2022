// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use

import 'dart:io';

import 'package:banana_disease_detector/common/colors.style.dart';
import 'package:banana_disease_detector/models/farmer.model.dart';
import 'package:banana_disease_detector/screens/contactsAuth.dart';
import 'package:banana_disease_detector/screens/disease_select.dart';
import 'package:banana_disease_detector/screens/map_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class WelcomeScreen extends StatefulWidget {
  final Farmer farmer;

  WelcomeScreen({Key? key, required this.farmer}) : super(key: key);
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late FirebaseMessaging messaging;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Language? selectedLang;

  List<Language> languageList = [
    Language(
      langName: 'English - UK',
      locale: const Locale('en'),
    ),
    Language(
      langName: 'Sinhala - LK',
      locale: const Locale('si'),
    )
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    selectedLang = languageList.singleWhere((e) => e.locale == context.locale);
    return Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: [
            Container(
                height: height * 0.3,
                width: width,
                decoration: BoxDecoration(
                    color: backgroundGreen,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Spacer(),
                        DropdownButton<Language>(
                          iconSize: 18,
                          elevation: 16,
                          value: selectedLang,
                          style: const TextStyle(color: Colors.black),
                          underline: Container(
                            padding: const EdgeInsets.only(left: 4, right: 4),
                            color: Colors.transparent,
                          ),
                          onChanged: (newValue) {
                            setState(() {
                              selectedLang = newValue!;
                            });
                            if (newValue!.langName == 'English - UK') {
                              context.setLocale(const Locale('en'));
                            } else if (newValue.langName == 'Sinhala - LK') {
                              context.setLocale(const Locale('si'));
                            }
                          },
                          items: languageList.map<DropdownMenuItem<Language>>(
                              (Language value) {
                            return DropdownMenuItem<Language>(
                              value: value,
                              child: Text(
                                value.langName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        IconButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pushReplacementNamed('/signIn');
                            },
                            icon: Icon(Icons.logout)),
                      ],
                    ),
                    // Row(
                    //   crossAxisAlignment: CrossAxisAlignment.end,
                    //   children: [
                    //     Spacer(),
                    //     IconButton(
                    //         onPressed: () {
                    //           Navigator.of(context)
                    //               .pushReplacementNamed('/signIn');
                    //         },
                    //         icon: Icon(Icons.logout)),
                    //   ],
                    // ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Welcome " + widget.farmer.name),
                    )
                  ],
                )),
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
                                  builder: (context) => DiseaseSelect(
                                        farmer: widget.farmer,
                                      )));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              padding: EdgeInsets.all(10),
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(40)),
                                border: Border.all(
                                    color: Colors.grey.shade100,
                                    width: 5.0,
                                    style: BorderStyle.solid),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: ExactAssetImage(
                                            'assets/images/disease.jpeg'),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "disease_identification".tr(),
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "disease_det".tr(),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 5,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              )),
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
                                  builder: (context) => MapView(
                                        farmer: widget.farmer,
                                      )));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              padding: EdgeInsets.all(10),
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(40)),
                                border: Border.all(
                                    color: Colors.grey.shade100,
                                    width: 5.0,
                                    style: BorderStyle.solid),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: ExactAssetImage(
                                            'assets/images/map.png'),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "map_visualization".tr(),
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "map_det".tr(),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              )),
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
                                  builder: (context) => ContactsAuth(
                                        farmer: widget.farmer,
                                      )));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              padding: EdgeInsets.all(10),
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(40)),
                                border: Border.all(
                                    color: Colors.grey.shade100,
                                    width: 5.0,
                                    style: BorderStyle.solid),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: ExactAssetImage(
                                            'assets/images/contact.jpeg'),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "contacts".tr(),
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "contact_det".tr(),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              )),
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

class Language {
  Locale locale;
  String langName;
  Language({
    required this.locale,
    required this.langName,
  });
}
