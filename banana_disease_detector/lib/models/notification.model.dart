import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationIns {
  final double long;
  final double lat;
  final String name;
  final String farmerId;
  final Timestamp date;
  final String instructorId;

  String? referenceID;

  NotificationIns(
      {required this.lat,
      required this.long,
      required this.name,
      required this.farmerId,
      required this.date,
      required this.instructorId});

  factory NotificationIns.fromSnapshot(DocumentSnapshot snapshot) {
    final newPassanger =
        NotificationIns.fromJson(snapshot.data() as Map<String, dynamic>);
    newPassanger.referenceID = snapshot.reference.id;
    return newPassanger;
  }

  factory NotificationIns.fromJson(Map<String, dynamic> json) =>
      _donorFromJson(json);

  Map<String, dynamic> toJson() => _donorToJson(this);

  @override
  String toString() => 'NotificationIns<$NotificationIns>';
}

NotificationIns _donorFromJson(Map<String, dynamic> json) {
  return NotificationIns(
      long: json["long"],
      lat: json["lat"],
      name: json["name"],
      farmerId: json["farmerId"],
      date: json["date"],
      instructorId: json["instructorId"],
);
}

Map<String, dynamic> _donorToJson(NotificationIns instance) => <String, dynamic>{
      'name': instance.name,
      'lat': instance.lat,
      'long': instance.long,
      'farmerId': instance.farmerId,
      'date': instance.date,
      'instructorId': instance.instructorId
    };
