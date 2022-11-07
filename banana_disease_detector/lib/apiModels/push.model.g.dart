// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Push _$PushFromJson(Map<String, dynamic> json) => Push(
      token: json['token'] as String,
      message: json['message'] as String,
    );

Map<String, dynamic> _$PushToJson(Push instance) => <String, dynamic>{
      'token': instance.token,
      'message': instance.message,
    };
