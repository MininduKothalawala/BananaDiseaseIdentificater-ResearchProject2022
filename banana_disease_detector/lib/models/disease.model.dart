import 'package:cloud_firestore/cloud_firestore.dart';

class DiseaseLocater {
  final double long;
  final double lat;
  final String name;
  final String farmerId;
  final String instructorId;
  final bool removedDisease;
  final Timestamp date;

  String? referenceID;

  DiseaseLocater(
      {required this.lat,
      required this.long,
      required this.name,
      required this.farmerId,
      required this.removedDisease,
      required this.instructorId,
      required this.date});

  factory DiseaseLocater.fromSnapshot(DocumentSnapshot snapshot) {
    final newPassanger =
        DiseaseLocater.fromJson(snapshot.data() as Map<String, dynamic>);
    newPassanger.referenceID = snapshot.reference.id;
    return newPassanger;
  }

  factory DiseaseLocater.fromJson(Map<String, dynamic> json) =>
      _donorFromJson(json);

  Map<String, dynamic> toJson() => _donorToJson(this);

  @override
  String toString() => 'DiseaseLocater<$DiseaseLocater>';
}

DiseaseLocater _donorFromJson(Map<String, dynamic> json) {
  return DiseaseLocater(
      long: json["long"],
      lat: json["lat"],
      name: json["name"],
      farmerId: json["farmerId"],
      date: json["date"],
      instructorId: json["instructorId"],
      removedDisease: json["removedDisease"]);
}

Map<String, dynamic> _donorToJson(DiseaseLocater instance) => <String, dynamic>{
      'name': instance.name,
      'lat': instance.lat,
      'long': instance.long,
      'farmerId': instance.farmerId,
      'removedDisease': instance.removedDisease,
      'date': instance.date,
      'instructorId': instance.instructorId
    };

class DiseaseLocaterWithId {
  final double long;
  final double lat;
  final String name;
  final String farmerId;
  final String instructorId;
  final bool removedDisease;
  final Timestamp date;
  final String referenceID;

  DiseaseLocaterWithId(
      {required this.lat,
      required this.long,
      required this.name,
      required this.farmerId,
      required this.removedDisease,
      required this.instructorId,
      required this.referenceID,
      required this.date});
}
