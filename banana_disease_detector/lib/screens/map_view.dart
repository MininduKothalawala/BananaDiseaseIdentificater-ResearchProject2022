import 'dart:io';
import 'package:banana_disease_detector/common/colors.style.dart';
import 'package:banana_disease_detector/models/disease.model.dart';
import 'package:banana_disease_detector/models/farmer.model.dart';
import 'package:banana_disease_detector/models/weather.model.dart';
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

class MapView extends StatefulWidget {
  MapView({Key? key, required this.farmer}) : super(key: key);

  final Farmer? farmer;

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late PageController _controller;

  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));
  late GoogleMapController mapController;

  final GlobalKey<ScaffoldState> _scaffoldKeyCenter =
      GlobalKey<ScaffoldState>();

  late Position _currentPosition;

  String _currentAddress = '';

  final startAddressController = TextEditingController();

  String _startAddress = '';

  Set<Marker> markers = {};

  Set<Circle> circles = {};

  late PolylinePoints polylinePoints;

  Map<PolylineId, Polyline> polylines = {};

  List<LatLng> polylineCoordinates = [];

  final Set<Marker> marker = new Set();

  int _circleIdCounter = 1;

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
  initState() {
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
    var querySnapshot =
        await collection.where("removedDisease", isEqualTo: false).get();
    for (var queryDocumentSnapshot in querySnapshot.docs) {
      Map<String, dynamic> data = queryDocumentSnapshot.data();
      ;
      setState(() {
        diseaseLocationList.add(DiseaseLocater(
            lat: data['lat'],
            long: data['long'],
            name: data['name'],
            farmerId: data['farmerId'],
            instructorId: data['instructorId'],
            date: data['date'],
            removedDisease: data['removedDisease']));
      });
    }

    // await setCircles();
    setCircles();
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

  setCircles() async {
    print("setting circles********************");
    for (var i = 0; i < diseaseLocationList.length; i++) {
      print("disease circles********************");
      print(diseaseLocationList[i].lat.toString());
      print(diseaseLocationList[i].long.toString());
      final List<Weather> weatherList = [];
      var collection = FirebaseFirestore.instance.collection('Weather');
      var querySnapshot = await collection
          .where("lat", isEqualTo: diseaseLocationList[i].lat)
          .where("long", isEqualTo: diseaseLocationList[i].long)
          .get();

//check weather is there
      if (querySnapshot.docs.isNotEmpty) {
        for (var queryDocumentSnapshot in querySnapshot.docs) {
          print("weather disease circles********************");
          Map<String, dynamic> data = queryDocumentSnapshot.data();
          print("lat isssssssssssssssss********************");
          print(data['lat']);
          setState(() {
            weatherList.add(Weather(
                lat: data['lat'],
                long: data['long'],
                monthRain1: data['monthRain1'],
                monthRain2: data['monthRain2'],
                monthRH1: data['monthRH1'],
                monthRH2: data['monthRH2'],
                monthTemp2: data['monthTemp2'],
                monthTemp1: data['monthTemp1']));
          });
        }
        String disease = diseaseLocationList[i].name;

        Map<String, dynamic> result =
            detectRadiusAndColor(weatherList, disease);
        print("result map isss");
        print(result);
        double radius = result['radius'];
        Color color = result['color'];

        final String circleIdVal = 'circle_id_$_circleIdCounter';
        _circleIdCounter++;
        circles.add(Circle(
            circleId: CircleId(circleIdVal),
            center:
                LatLng(diseaseLocationList[i].lat, diseaseLocationList[i].long),
            radius: radius,
            fillColor: color,
            strokeWidth: 3,
            strokeColor: Colors.green));
      } else {
        print("**************No location");
      }
    }
  }

//algo based on conditions
  detectRadiusAndColor(List<Weather> weatherList, disease) {
    print("**********detectRadiusAndColor called");
    print(weatherList[0].monthRH1.toString());
    double radius = 0.0;
    Color color = Colors.white;
    String tempRisk = "";
    String rainRisk = "";
    String diseaseRisk = "";
    Weather weather = weatherList[0];
    Map<String, dynamic> resultMap = {};
    if (disease == "Sigatoka") {
      if (200 < weather.monthRain1 && 50 <= weather.monthRH1 ||
          100 >= weather.monthRH1) {
        diseaseRisk = "High risk";
      } else if (200 > weather.monthRain1 && 50 <= weather.monthRH1 ||
          100 >= weather.monthRH1) {
        diseaseRisk = "Medium risk";
      } else if (200 > weather.monthRain1 && 50 > weather.monthRH1) {
        diseaseRisk = "Low risk";
      } else {
        diseaseRisk = "No risk";
      }
    } else {
      if (17 > weather.monthTemp1) {
        tempRisk = "No risk";
      } else if (34 < weather.monthTemp1) {
        tempRisk = "No risk";
      } else if (17 <= weather.monthTemp1 || weather.monthTemp1 <= 23) {
        tempRisk = "Low risk";
      } else if (24 <= weather.monthTemp1 || weather.monthTemp1 <= 34) {
        tempRisk = "High risk";
      }

      if (200 > weather.monthRain1) {
        rainRisk = "Low risk";
      } else if (200 == weather.monthRain1) {
        rainRisk = "Medium risk";
      } else if (200 < weather.monthRain1) {
        rainRisk = "High risk";
      } else {
        rainRisk = "No risk";
      }

      //if any is high return high
      if (tempRisk == "High risk" || rainRisk == "High risk") {
        diseaseRisk = "High risk";
        double radius = 4000 * 4;
        color = Colors.red;
        resultMap["color"] = color;
        resultMap["radius"] = radius;
      } else if (tempRisk == "Low risk" || rainRisk == "Low risk") {
        diseaseRisk = "Low risk";
        double radius = 4000 * 2;
        color = Colors.yellow;
        resultMap["color"] = color;
        resultMap["radius"] = radius;
      } else if (tempRisk == "Medium risk" || rainRisk == "Medium risk") {
        diseaseRisk = "Medium risk";
        double radius = 4000 * 3;
        color = Colors.orange;
        resultMap["color"] = color;
        resultMap["radius"] = radius;
      } else {
        diseaseRisk = "No risk";
        double radius = 0;
        resultMap["color"] = color;
        resultMap["radius"] = radius;
      }
    }
    return resultMap;
  }

  Set<Circle> getCircles() {
    print("***************8cirlce" + circles.length.toString());
    return circles;
  }

  Set<Marker> getmarkers() {
    print("***************markers" + markers.length.toString());
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        key: _scaffoldKeyCenter,
        body: PageView(
          controller: _controller,
          children: [
            ListView(children: [
              Container(
                decoration: BoxDecoration(
                    color: backgroundGreen,
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10))),
                height: MediaQuery.of(context).size.height * 0.1,
                child: Row(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 8.0, top: 16, right: 8),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WelcomeScreen(
                                        farmer: widget.farmer!,
                                      )));
                        },
                        icon: Icon(Icons.arrow_back_ios),
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 16),
                      child: Text(
                        "Disease Locator",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
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
                                          color: Colors
                                              .blue.shade100, // button color
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
                                          color: Colors
                                              .blue.shade100, // button color
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
                                        color: Colors
                                            .orange.shade100, // button color
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
                  : Column()
            ]),
            ListView(children: [
              Container(
                decoration: BoxDecoration(
                    color: backgroundGreen,
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10))),
                height: MediaQuery.of(context).size.height * 0.1,
                child: Row(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 8.0, top: 16, right: 8),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WelcomeScreen(
                                        farmer: widget.farmer!,
                                      )));
                        },
                        icon: Icon(Icons.arrow_back_ios),
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 16),
                      child: Text(
                        "Risk Area",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
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
                                circles: getCircles(),
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
                                          color: Colors
                                              .blue.shade100, // button color
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
                                          color: Colors
                                              .blue.shade100, // button color
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
                                        color: Colors
                                            .orange.shade100, // button color
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
                  : Column()
            ])
          ],
        ));
  }
}
