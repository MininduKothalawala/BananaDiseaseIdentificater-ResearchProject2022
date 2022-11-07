import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

part 'request.model.g.dart';

@JsonSerializable()
class Request {
   String filePath;

  Request({required this.filePath});

  factory Request.fromJson(Map<String, dynamic> json) =>
      _$RequestFromJson(json);

  Map<String, dynamic> toJson() => _$RequestToJson(this);
}
