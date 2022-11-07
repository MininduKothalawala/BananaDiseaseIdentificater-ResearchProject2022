import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

part 'textDisease.model.g.dart';

@JsonSerializable()
class TextDisease {
  String text;
  String language;

  TextDisease({required this.text,required this.language});

  factory TextDisease.fromJson(Map<String, dynamic> json) =>
      _$TextDiseaseFromJson(json);

  Map<String, dynamic> toJson() => _$TextDiseaseToJson(this);
}
