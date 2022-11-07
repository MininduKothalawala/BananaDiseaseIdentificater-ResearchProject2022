import 'package:cloud_firestore/cloud_firestore.dart';

class Instructor {
  final String name;
  final String token;
  final String address;
  final String phone;
  final double long;
  final double lat;
  String? userId;
  String? referenceID;

  Instructor(
      {required this.name,
      required this.token,
      required this.address,
      required this.phone,
      required this.long,
      required this.lat});

  factory Instructor.fromSnapshot(DocumentSnapshot snapshot) {
    final newInstructor =
        Instructor.fromJson(snapshot.data() as Map<String, dynamic>);
    newInstructor.referenceID = snapshot.reference.id;
    return newInstructor;
  }

  factory Instructor.fromJson(Map<String, dynamic> json) =>
      _InstructorFromJson(json);

  Map<String, dynamic> toJson() => _InstructorToJson(this);

  @override
  String toString() => 'Instructor<$Instructor>';
}

Instructor _InstructorFromJson(Map<String, dynamic> json) {
  return Instructor(
      name: json["name"],
      address: json["address"],
      token: json["token"],
      phone: json["phone"],
      lat: json["lat"],
      long: json["long"]);
}

Map<String, dynamic> _InstructorToJson(Instructor instance) =>
    <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'token': instance.token,
      'phone': instance.phone,
      'lat': instance.lat,
      'long': instance.long,
    };

class InstructorDistance {
  final String name;
  final String token;
  final String address;
  final String phone;
  final double long;
  final double lat;
  final double distance;

  InstructorDistance(
      {required this.name,
      required this.token,
      required this.address,
      required this.phone,
      required this.long,
      required this.lat,
      required this.distance});

  factory InstructorDistance.fromJson(Map<String, dynamic> json) =>
      _InstructorDistanceFromJson(json);

  Map<String, dynamic> toJson() => __InstructorDistanceToJson(this);

  @override
  String toString() => 'Instructor<$Instructor>';
}

InstructorDistance _InstructorDistanceFromJson(Map<String, dynamic> json) {
  return InstructorDistance(
      name: json["name"],
      address: json["address"],
      token: json["token"],
      phone: json["phone"],
      lat: json["lat"],
      distance: json["distance"],
      long: json["long"]);
}

Map<String, dynamic> __InstructorDistanceToJson(InstructorDistance instance) =>
    <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'token': instance.token,
      'phone': instance.phone,
      'lat': instance.lat,
      'long': instance.long,
      'distance': instance.distance
    };
