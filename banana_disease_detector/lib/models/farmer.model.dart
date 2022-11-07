import 'package:cloud_firestore/cloud_firestore.dart';

class Farmer {
  final String name;
  final String type;
  final String address;
  final String banana_type;
  final String phone;
  final double long;
  final double lat;
  String? userId;
  String? referenceID;

  Farmer(
      {required this.name,
      required this.type,
      required this.address,
      required this.banana_type,
      required this.phone,
      required this.long,
      required this.lat});

  factory Farmer.fromSnapshot(DocumentSnapshot snapshot) {
    final newFarmer = Farmer.fromJson(snapshot.data() as Map<String, dynamic>);
    newFarmer.referenceID = snapshot.reference.id;
    return newFarmer;
  }

  factory Farmer.fromJson(Map<String, dynamic> json) => _FarmerFromJson(json);

  Map<String, dynamic> toJson() => _FarmerToJson(this);

  @override
  String toString() => 'Farmer<$Farmer>';
}

Farmer _FarmerFromJson(Map<String, dynamic> json) {
  return Farmer(
      name: json["name"],
      address: json["address"],
      banana_type: json["banana_type"],
      phone: json["phone"],
      lat: json["lat"],
      type: json["type"],
      long: json["long"]);
}

Map<String, dynamic> _FarmerToJson(Farmer instance) => <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'banana_type': instance.banana_type,
      'phone': instance.phone,
      'lat': instance.lat,
      'long': instance.long,
      'type': instance.type
    };
