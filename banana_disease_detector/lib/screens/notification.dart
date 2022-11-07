// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use

import 'dart:io';

import 'package:banana_disease_detector/common/colors.style.dart';
import 'package:banana_disease_detector/models/instructor.model.dart';
import 'package:banana_disease_detector/models/instructor.model.dart';
import 'package:banana_disease_detector/models/notification.model.dart';
import 'package:banana_disease_detector/screens/disease_select.dart';
import 'package:banana_disease_detector/screens/map_view.dart';
import 'package:banana_disease_detector/screens/welcomInstructor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class NotificationScreen extends StatefulWidget {
  final Instructor? instructor;

  NotificationScreen({Key? key, required this.instructor}) : super(key: key);
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late FirebaseMessaging messaging;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<NotificationIns> notiList = [];

  @override
  void initState() {
    super.initState();
    getData();
        FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("message recieved");
      print(event.notification!.body);
      var snackbar = new SnackBar(
        content: new Text(event.notification!.body.toString()),
        backgroundColor: Colors.redAccent,
      );
      _scaffoldKey.currentState?.showSnackBar(snackbar);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
    });
  }

  Future<void> getData() async {
    var collection = FirebaseFirestore.instance.collection('Notifications');
    var querySnapshot = await collection
        .where("instructorId", isEqualTo: widget.instructor!.name)
        .get();
    for (var queryDocumentSnapshot in querySnapshot.docs) {
      Map<String, dynamic> data = queryDocumentSnapshot.data();
      setState(() {
        notiList.add(NotificationIns(
            name: data['name'],
            long: data['long'],
            lat: data['lat'],
            farmerId: data['farmerId'],
            date: data['date'],
            instructorId: data['instructorId']));

        notiList.sort((a, b) {
          //sorting in ascending order
          return DateTime.parse(b.date.toDate().toString())
              .compareTo(DateTime.parse(a.date.toDate().toString()));
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: [
            Container(
                height: height * 0.3,
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => WelcomeInstructor(
                                            instructor: widget.instructor!,
                                          )));
                            },
                            icon: Icon(Icons.arrow_back_ios)),
                      ],
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Welcome " + widget.instructor!.name),
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
                  child: ListView.builder(
                    itemCount: notiList.length,
                    itemBuilder: (_, i) {
                      NotificationIns noti = notiList[i];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(40)),
                            border: Border.all(
                                color: Colors.grey.shade100,
                                width: 5.0,
                                style: BorderStyle.solid),
                          ),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: width - 40,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text(
                                        "Disease: " + noti.name,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      "Date:" + noti.date.toDate().toString(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Container(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
          ],
        ));
  }
}
