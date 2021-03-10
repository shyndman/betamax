// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interactions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestInteraction _$RequestInteractionFromJson(Map<String, dynamic> json) {
  return RequestInteraction(
    method: json['method'] as String,
    uri: json['uri'] as String,
    headers: Map<String, String>.from(json['headers'] as Map),
    body: json['body'] == null
        ? null
        : InteractionBody.fromJson(json['body'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$RequestInteractionToJson(RequestInteraction instance) =>
    <String, dynamic>{
      'headers': instance.headers,
      'body': instance.body,
      'method': instance.method,
      'uri': instance.uri,
    };

ResponseInteraction _$ResponseInteractionFromJson(Map<String, dynamic> json) {
  return ResponseInteraction(
    status: json['status'] as int,
    headers: Map<String, String>.from(json['headers'] as Map),
    body: json['body'] == null
        ? null
        : InteractionBody.fromJson(json['body'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$ResponseInteractionToJson(
        ResponseInteraction instance) =>
    <String, dynamic>{
      'headers': instance.headers,
      'body': instance.body,
      'status': instance.status,
    };

InteractionBody _$InteractionBodyFromJson(Map<String, dynamic> json) {
  return InteractionBody(
    encoding: json['encoding'] as String,
    string: json['string'] as String,
  );
}

Map<String, dynamic> _$InteractionBodyToJson(InteractionBody instance) =>
    <String, dynamic>{
      'encoding': instance.encoding,
      'string': instance.string,
    };
