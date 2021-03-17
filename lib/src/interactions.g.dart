// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interactions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cassette _$CassetteFromJson(Map<String, dynamic> json) {
  return Cassette(
    name: json['name'] as String,
    interactions: (json['interactions'] as List)
        ?.map((e) => e == null
            ? null
            : InteractionPair.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$CassetteToJson(Cassette instance) => <String, dynamic>{
      'name': instance.name,
      'interactions': instance.interactions,
    };

InteractionPair _$InteractionPairFromJson(Map<String, dynamic> json) {
  return InteractionPair(
    request: json['request'] == null
        ? null
        : RequestInteraction.fromJson(json['request'] as Map<String, dynamic>),
    response: json['response'] == null
        ? null
        : ResponseInteraction.fromJson(
            json['response'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$InteractionPairToJson(InteractionPair instance) =>
    <String, dynamic>{
      'request': instance.request,
      'response': instance.response,
    };

RequestInteraction _$RequestInteractionFromJson(Map<String, dynamic> json) {
  return RequestInteraction(
    method: json['method'] as String,
    url: json['uri'] as String,
    headers: (json['headers'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as String),
    ),
    body: json['body'] == null
        ? null
        : InteractionBody.fromJson(json['body'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$RequestInteractionToJson(RequestInteraction instance) =>
    <String, dynamic>{
      'method': instance.method,
      'uri': instance.url,
      'headers': instance.headers,
      'body': instance.body,
    };

ResponseInteraction _$ResponseInteractionFromJson(Map<String, dynamic> json) {
  return ResponseInteraction(
    status: json['status'] as int,
    headers: (json['headers'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as String),
    ),
    body: json['body'] == null
        ? null
        : InteractionBody.fromJson(json['body'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$ResponseInteractionToJson(
        ResponseInteraction instance) =>
    <String, dynamic>{
      'status': instance.status,
      'headers': instance.headers,
      'body': instance.body,
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
