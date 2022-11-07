import 'dart:io';
import 'package:banana_disease_detector/common/colors.style.dart';
import 'package:banana_disease_detector/models/disease.model.dart';
import 'package:banana_disease_detector/models/farmer.model.dart';
import 'package:banana_disease_detector/models/instructor.model.dart';
import 'package:banana_disease_detector/screens/login.dart';
import 'package:banana_disease_detector/screens/notification.dart';
import 'package:banana_disease_detector/screens/welcome.screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class WelcomeInstructor extends StatefulWidget {
  WelcomeInstructor({Key? key, required this.instructor}) : super(key: key);

  final Instructor? instructor;

  @override
  _WelcomeInstructorState createState() => _WelcomeInstructorState();
}

class _WelcomeInstructorState extends State<WelcomeInstructor> {
  late PageController _controller;
  late FirebaseMessaging messaging;
 
  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));
  late GoogleMapController mapController;

  final GlobalKey<ScaffoldState> _scaffoldKeyCenter =
      GlobalKey<ScaffoldState>();

  late Position _currentPosition;

  String _currentAddress = '';

  final startAddressController = TextEditingController();

  String _startAddress = '';

  Set<Marker> markers = {};

  late PolylinePoints polylinePoints;

  Map<PolylineId, Polyline> polylines = {};

  List<LatLng> polylineCoordinates = [];

  final Set<Marker> marker = new Set();

  final List<DiseaseLocater> diseaseLocationList = [];

  // Method for retrieving the current location
  _getCurrentLocation() async {
    print("currrrr&&&&&&&&&&&&&&&&");
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
        print('CURRENT POS: $_currentPosition');
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
      });
      await _getAddress();
    }).catchError((e) {
      print(e);
    });
  }

  // Method for retrieving the address
  _getAddress() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
        startAddressController.text = _currentAddress;
        _startAddress = _currentAddress;
        print("************************");
        print(_startAddress);
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      initialPage: 0,
    );

    _getCurrentLocation();
    setmarkers();
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("message recieved");
      print(event.notification!.body);
      var snackbar = new SnackBar(
        content: new Text(event.notification!.body.toString()),
        backgroundColor: Colors.redAccent,
      );
      _scaffoldKeyCenter.currentState?.showSnackBar(snackbar);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
    });
  }

  setmarkers() async {
    var collection = FirebaseFirestore.instance.collection('Diseases');
    var querySnapshot = await collection
        .where("removedDisease", isEqualTo: false)
        .where("instructorId", isEqualTo: widget.instructor!.name)
        .get();
    for (var queryDocumentSnapshot in querySnapshot.docs) {
      Map<String, dynamic> data = queryDocumentSnapshot.data();
      print("lat isssssssssssssssss********************");
      print(data['lat']);
      setState(() {
        diseaseLocationList.add(DiseaseLocater(
            lat: data['lat'],
            long: data['long'],
            name: data['name'],
            farmerId: data['farmerId'],
            date: data['date'],
            instructorId: data['instructorId'],
            removedDisease: data['removedDisease']));
      });
    }

    for (var i = 0; i < diseaseLocationList.length; i++) {
      markers.add(Marker(
        //add third marker
        markerId: MarkerId(i.toString()),
        position: LatLng(diseaseLocationList[i].lat,
            diseaseLocationList[i].long), //position of marker
        infoWindow: InfoWindow(
            //popup info
            title: diseaseLocationList[i].name,
            snippet: diseaseLocationList[i].date.toDate().toString()),
        icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      ));
    }
  }

  Set<Marker> getmarkers() {
    for (var i = 0; i < diseaseLocationList.length; i++) {
      markers.add(Marker(
        //add third marker
        markerId: MarkerId(i.toString()),
        position: LatLng(diseaseLocationList[i].lat,
            diseaseLocationList[i].long), //position of marker
        infoWindow: InfoWindow(
            //popup info
            title: diseaseLocationList[i].name,
            snippet: diseaseLocationList[i].date.toDate().toString()),
        icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      ));
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        key: _scaffoldKeyCenter,
        appBar: AppBar(
          backgroundColor: backgroundGreen,
          title: Text(
            "Welcome " + widget.instructor!.name,
            style: TextStyle(fontSize: 28),
          ),
          // leading: IconButton(
          //     onPressed: () {
          //       Navigator.of(context).pushReplacementNamed('/welcome');
          //     },
          //     icon: Icon(Icons.arrow_back_ios)),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.notifications,
                color: Colors.white,
              ),
              onPressed: () async {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NotificationScreen(
                              instructor: widget.instructor!,
                            )));
              },
            ),
            IconButton(
              icon: Icon(
                Icons.logout,
                color: Colors.white,
              ),
              onPressed: () async {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => Login()));
              },
            )
          ],
        ),
        body: ListView(children: [
          diseaseLocationList.length > 0
              ? Column(
                  children: [
                    Container(
                      height: height - 70,
                      child: Stack(
                        children: <Widget>[
                          // Map View
                          GoogleMap(
                            markers: getmarkers(),
                            initialCameraPosition: _initialLocation,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: false,
                            mapType: MapType.normal,
                            zoomGesturesEnabled: true,
                            zoomControlsEnabled: false,
                            polylines: Set<Polyline>.of(polylines.values),
                            onMapCreated: (GoogleMapController controller) {
                              mapController = controller;
                            },
                          ),
                          // Show zoom buttons
                          SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  ClipOval(
                                    child: Material(
                                      color:
                                          Colors.blue.shade100, // button color
                                      child: InkWell(
                                        splashColor:
                                            Colors.blue, // inkwell color
                                        child: SizedBox(
                                          width: 50,
                                          height: 50,
                                          child: Icon(Icons.add),
                                        ),
                                        onTap: () {
                                          mapController.animateCamera(
                                            CameraUpdate.zoomIn(),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  ClipOval(
                                    child: Material(
                                      color:
                                          Colors.blue.shade100, // button color
                                      child: InkWell(
                                        splashColor:
                                            Colors.blue, // inkwell color
                                        child: SizedBox(
                                          width: 50,
                                          height: 50,
                                          child: Icon(Icons.remove),
                                        ),
                                        onTap: () {
                                          mapController.animateCamera(
                                            CameraUpdate.zoomOut(),
                                          );
                                        },
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          // Show the place input fields & button for
                          // showing the route

                          // Show current location button
                          SafeArea(
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    right: 10.0, bottom: 10.0),
                                child: ClipOval(
                                  child: Material(
                                    color:
                                        Colors.orange.shade100, // button color
                                    child: InkWell(
                                      splashColor:
                                          Colors.orange, // inkwell color
                                      child: SizedBox(
                                        width: 56,
                                        height: 56,
                                        child: Icon(Icons.my_location),
                                      ),
                                      onTap: () {
                                        mapController.animateCamera(
                                          CameraUpdate.newCameraPosition(
                                            CameraPosition(
                                              target: LatLng(
                                                _currentPosition.latitude,
                                                _currentPosition.longitude,
                                              ),
                                              zoom: 9.0,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Center(
                      child: Text("No diseases yet"),
                    )
                  ],
                )
        ]));
  }
}
