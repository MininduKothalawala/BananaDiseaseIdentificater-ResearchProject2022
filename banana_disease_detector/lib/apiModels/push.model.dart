import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

part 'push.model.g.dart';

@JsonSerializable()
class Push {
  String token;
  String message;

  Push({required this.token, required this.message});

  factory Push.fromJson(Map<String, dynamic> json) => _$PushFromJson(json);

  Map<String, dynamic> toJson() => _$PushToJson(this);
}
