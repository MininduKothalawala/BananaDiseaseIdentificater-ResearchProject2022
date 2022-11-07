 
import 'package:json_annotation/json_annotation.dart';

part 'response.model.g.dart';

@JsonSerializable()
class ResponseApi {
  String disease;

  ResponseApi({required this.disease});

  factory ResponseApi.fromJson(Map<String, dynamic> json) =>
      _$ResponseApiFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseApiToJson(this);
}
