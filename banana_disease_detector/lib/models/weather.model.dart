import 'package:cloud_firestore/cloud_firestore.dart';

class Weather {
  final double long;
  final double lat;
  final int monthRain1;
  final int monthRain2;
  final int monthTemp1;
  final int monthTemp2;
  final int monthRH1;
  final int monthRH2;

  Weather({
    required this.monthRain1,
    required this.monthRain2,
    required this.monthTemp1,
    required this.monthTemp2,
    required this.monthRH1,
    required this.monthRH2,
    required this.lat,
    required this.long,
  });

  factory Weather.fromJson(Map<String, dynamic> json) => _donorFromJson(json);

  Map<String, dynamic> toJson() => _donorToJson(this);

  @override
  String toString() => 'DiseaseLocater<$Weather>';
}

Weather _donorFromJson(Map<String, dynamic> json) {
  return Weather(
      long: json["long"],
      lat: json["lat"],
      monthRain1: json["monthRain1"],
      monthRain2: json["monthRain2"],
      monthTemp1: json["monthTemp1"],
      monthTemp2: json["monthTemp2"],
      monthRH2: json["monthRH2"],
      monthRH1: json["monthRH1"]);
}

Map<String, dynamic> _donorToJson(Weather instance) => <String, dynamic>{
      'monthRain1': instance.monthRain1,
      'lat': instance.lat,
      'long': instance.long,
      'monthRain2': instance.monthRain2,
      'monthTemp1': instance.monthTemp1,
      'monthTemp2': instance.monthTemp2,
      'monthRH2': instance.monthRH2,
      'monthRH1': instance.monthRH1
    };
