import 'dart:io';
import 'dart:math';
import 'package:banana_disease_detector/apiModels/push.model.dart';
import 'package:banana_disease_detector/apiModels/response.model.dart';
import 'package:banana_disease_detector/common/colors.style.dart';
import 'package:banana_disease_detector/models/disease.model.dart';
import 'package:banana_disease_detector/models/farmer.model.dart';
import 'package:banana_disease_detector/models/instructor.model.dart';
import 'package:banana_disease_detector/models/notification.model.dart';
import 'package:banana_disease_detector/repository/disease.repo.dart';
import 'package:banana_disease_detector/repository/notification.repo.dart';
import 'package:banana_disease_detector/screens/disease_select.dart';
import 'package:banana_disease_detector/utils/const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageDetect2 extends StatefulWidget {
  final Farmer farmer;
  ImageDetect2({Key? key, required this.farmer}) : super(key: key);

  @override
  _ImageDetectState createState() => _ImageDetectState();
}

class _ImageDetectState extends State<ImageDetect2> {
  late PageController _controller;
  final DiseaseLocaterRepository diseaseLocaterRepository =
  DiseaseLocaterRepository();

  final NotificationRepository notificationRepository =
  NotificationRepository();

  File? _image;
  final picker = ImagePicker();

  Image? _imageWidget;

  img.Image? fox;
  var dio = Dio();

  String result = "";

  String showMessage = "";

  List<String> reslutList = [];
  final List<InstructorDistance> instructorDistanceList = [];

  late FirebaseMessaging messaging;
  final GlobalKey<ScaffoldState> _scaffoldKeyDetect =
  GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    _controller = PageController(
      initialPage: 0,
    );
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
      _scaffoldKeyDetect.currentState?.showSnackBar(snackbar);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
    });
    messaging.getToken().then((token) {
      print(token);
    });
  }

  // Method for retrieving the current location.didnt work with emulator
  _getCurrentLocation() async {
    print("***************current location of farmer&");
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      print(position.latitude.toString());
      return position;
    }).catchError((e) {
      print(e.toString());
      print(e);
    });
  }

  Future getImageCamera() async {
    print("pressed camera");
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      _image = File(pickedFile!.path);
      _imageWidget = Image.file(_image!);
    });
    // Position position = await _getCurrentLocation();
    // print(position);
    // _predict(_image!, position.latitude, position.longitude);
    _predict(_image!, 21.325, 34.256);
  }

  Future getImageGallery() async {
    print("pressed camera");
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile!.path);
      _imageWidget = Image.file(_image!);
    });

    _predict(_image!, widget.farmer.lat, widget.farmer.long);
  }

  calInstructorDistance(double latDisease, double longDisease) async {
    var collection = FirebaseFirestore.instance.collection('Instructors');
    var querySnapshot = await collection.get();
    for (var queryDocumentSnapshot in querySnapshot.docs) {
      Map<String, dynamic> data = queryDocumentSnapshot.data();
      print("instrucotr is********************");
      print(data['name']);
      double distance =
      calculateDistance(data['lat'], data['long'], latDisease, longDisease);
      setState(() {
        instructorDistanceList.add(InstructorDistance(
            name: data['name'],
            long: data['long'],
            token: data['token'],
            address: data['address'],
            phone: data['phone'],
            lat: data['lat'],
            distance: distance));
      });
    }
  }

  findNearestInstructorAndSendNoti(double lat, double long) {
    // instructorDistanceList.forEach((element) {
    //   print(element.toJson());
    // });
    print("find nearest********************");
    InstructorDistance nearestInstructor = instructorDistanceList.reduce(
            (currentUser, nextUser) =>
        currentUser.distance < nextUser.distance ? currentUser : nextUser);
    print(nearestInstructor.name.toString());

    //send notification
    notificationRepository.addNewNotification(NotificationIns(
        lat: lat,
        long: long,
        name: result,
        farmerId: widget.farmer.name,
        date: Timestamp.fromDate(DateTime.now()),
        instructorId: nearestInstructor.name));

    return nearestInstructor;
  }

//calculate the distance to disease location
  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future<void> _predict(File file, double lat, double long) async {
    String filePath = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      "filePath": await MultipartFile.fromFile(file.path, filename: filePath),
    });

    //using below logs to debug intergration issue
    print("IP: " + IP);
    print(IP + 'disease/');
    print('data: ' + formData.toString());
    print('file path: ' + filePath);

    Response response = await dio.post(IP + 'diseasePanama/', data: formData);

    print("IP: " + IP);
    print("response: " + response.toString());
    result = ResponseApi.fromJson(response.data).disease;

    print("***********text isss********");
    print(result);

    //check the result and notify the instuctor popup
    //get the usr cordintation and find nearest instructor
    if (result == "Panama" || result == "Sigatoka") {
      //cal instructor distance
      await calInstructorDistance(lat, long);

      //find nearest
      InstructorDistance instructor =
      findNearestInstructorAndSendNoti(lat, long);

      diseaseLocaterRepository.addNewDiseaseLocater(DiseaseLocater(
          lat: lat,
          long: long,
          name: result,
          farmerId: widget.farmer.name,
          instructorId: instructor.name,
          date: Timestamp.fromDate(DateTime.now()),
          removedDisease: false));

      String message = result +
          " identified at the cordinates " +
          lat.toString() +
          " " +
          long.toString();
      _sendPushNotification(instructor.token, message);
    }
  }

  Future<void> _sendPushNotification(String val, String message) async {
    print("**********demand called");
    Push request = Push(token: val, message: message);
    await dio.post('http://192.168.8.100:8080/sendPush/',
        data: request.toJson());
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        key: _scaffoldKeyDetect,
        body: PageView(
          controller: _controller,
          // onPageChanged: _speakPage,
          children: <Widget>[
            Stack(
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
                                    builder: (context) => DiseaseSelect(
                                      farmer: widget.farmer,
                                    )));
                          },
                          icon: Icon(Icons.arrow_back_ios)),
                      Text("image_select".tr())
                    ],
                  ),
                ),
                Stack(
                  children: <Widget>[
                    Positioned(
                      top: height * 0.2,
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width,
                        // margin: EdgeInsets.only(top: 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          border: Border.all(
                              color: Colors.grey.shade100,
                              width: 5.0,
                              style: BorderStyle.solid),
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                              minHeight: MediaQuery.of(context).size.height -
                                  MediaQuery.of(context).padding.top),
                          child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    _image == null
                                        ? Container(
                                      height: height * 0.45,
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 30),
                                        child: Text(
                                          'no_image_select'.tr(),
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ),
                                    )
                                        : Container(
                                      height: height * 0.45,
                                      constraints: BoxConstraints(
                                          maxHeight:
                                          MediaQuery.of(context)
                                              .size
                                              .height /
                                              2),
                                      decoration: BoxDecoration(
                                        border: Border.all(),
                                      ),
                                      child: _imageWidget,
                                    ),
                                    Container(
                                      height: height * 0.1,
                                      width: width,
                                      padding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                      child: ElevatedButton(
                                          child: Text(
                                              "image_select_gallery"
                                                  .tr()
                                                  .toUpperCase(),
                                              style: TextStyle(fontSize: 20)),
                                          style: ButtonStyle(
                                            shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        40.0),
                                                    side: BorderSide(
                                                        color: darkGreen))),
                                            foregroundColor:
                                            MaterialStateProperty.all<
                                                Color>(Colors.white),
                                            backgroundColor:
                                            MaterialStateProperty.all<
                                                Color>(backgroundGreen),
                                          ),
                                          onPressed: () => getImageGallery()),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      height: height * 0.1,
                                      width: width,
                                      padding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                      child: ElevatedButton(
                                          child: Text(
                                              "image_select_camera"
                                                  .tr()
                                                  .toUpperCase(),
                                              style: TextStyle(fontSize: 20)),
                                          style: ButtonStyle(
                                            shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        40.0),
                                                    side: BorderSide(
                                                        color: darkGreen))),
                                            foregroundColor:
                                            MaterialStateProperty.all<
                                                Color>(Colors.white),
                                            backgroundColor:
                                            MaterialStateProperty.all<
                                                Color>(backgroundGreen),
                                          ),
                                          onPressed: () => getImageCamera()),
                                    ),
                                  ])),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
            Stack(
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
                                    builder: (context) => DiseaseSelect(
                                      farmer: widget.farmer,
                                    )));
                          },
                          icon: Icon(Icons.arrow_back_ios)),
                      Text("Diagnosis Report")
                    ],
                  ),
                ),
                Stack(
                  children: <Widget>[
                    Positioned(
                      top: height * 0.2,
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width,
                        // margin: EdgeInsets.only(top: 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          border: Border.all(
                              color: Colors.grey.shade100,
                              width: 5.0,
                              style: BorderStyle.solid),
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                              minHeight: MediaQuery.of(context).size.height -
                                  MediaQuery.of(context).padding.top),
                          child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    _image == null
                                        ? Container(
                                      height: height * 0.45,
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 30),
                                        child: Text(
                                          'No image selected.',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ),
                                    )
                                        : Container(
                                      height: height * 0.45,
                                      constraints: BoxConstraints(
                                          maxHeight:
                                          MediaQuery.of(context)
                                              .size
                                              .height /
                                              2),
                                      decoration: BoxDecoration(
                                        border: Border.all(),
                                      ),
                                      child: _imageWidget,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    result == "Panama" || result == "Sigatoka"
                                        ? Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          result,
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 20,
                                              fontWeight:
                                              FontWeight.bold),
                                        ),
                                        Text(
                                          " Disease Identified!",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight:
                                              FontWeight.bold),
                                        )
                                      ],
                                    )
                                        : Text("No disease detected"),
                                    result == "Panama" || result == "Sigatoka"
                                        ? Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            "Please take immediate action"),
                                      ],
                                    )
                                        : Container()
                                  ])),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
            result == "Panama" || result == "Sigatoka"
                ? Stack(
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
                                    builder: (context) => DiseaseSelect(
                                      farmer: widget.farmer,
                                    )));
                          },
                          icon: Icon(Icons.arrow_back_ios)),
                      Text("How to Control")
                    ],
                  ),
                ),
                Stack(
                  children: <Widget>[
                    Positioned(
                      top: height * 0.2,
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width,
                        // margin: EdgeInsets.only(top: 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.all(Radius.circular(50)),
                          border: Border.all(
                              color: Colors.grey.shade100,
                              width: 5.0,
                              style: BorderStyle.solid),
                        ),
                        child: ConstrainedBox(
                            constraints: BoxConstraints(
                                minHeight: MediaQuery.of(context)
                                    .size
                                    .height -
                                    MediaQuery.of(context).padding.top),
                            child: Padding(
                                padding: EdgeInsets.all(20),
                                child: ListView(
                                  children: [
                                    Row(
                                      children: [
                                        result == "Panama"
                                            ? Text(
                                          "Control Measures for\n Panama Disease",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight:
                                              FontWeight.bold),
                                        )
                                            : Text(
                                          "Control Measures for\n Yello Sigatoka Disease",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight:
                                              FontWeight.bold),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    result == "Panama"
                                        ? Text(
                                        "panama, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                                        maxLines: 50,
                                        overflow:
                                        TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight:
                                            FontWeight.bold))
                                        : Text(
                                        "sigatoka ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                                        maxLines: 50,
                                        overflow:
                                        TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight:
                                            FontWeight.bold)),
                                  ],
                                ))),
                      ),
                    ),
                  ],
                )
              ],
            )
                : Container(),
          ],
          scrollDirection: Axis.horizontal,
          pageSnapping: true,
          physics: BouncingScrollPhysics(),
        ));
  }
}
