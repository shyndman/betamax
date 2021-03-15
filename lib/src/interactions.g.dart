// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interactions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cassette _$CassetteFromJson(Map<String, dynamic> json) {
  return Cassette(
    name: json['name'] as String,
    interactions: interactionsFromJson(json['interactions']),
  );
}

Map<String, dynamic> _$CassetteToJson(Cassette instance) => <String, dynamic>{
      'name': instance.name,
      'interactions': interactionsToJson(instance.interactions),
    };

RequestInteraction _$RequestInteractionFromJson(Map<String, dynamic> json) {
  return RequestInteraction(
    method: json['method'] as String,
    uri: json['uri'] as String,
    headers: (json['headers'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as String),
    ),
    correlator: json['correlator'] as String,
    body: json['body'] == null
        ? null
        : InteractionBody.fromJson(json['body'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$RequestInteractionToJson(RequestInteraction instance) =>
    <String, dynamic>{
      'headers': instance.headers,
      'body': instance.body,
      'correlator': instance.correlator,
      'method': instance.method,
      'uri': instance.uri,
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
    correlator: json['correlator'] as String,
  );
}

Map<String, dynamic> _$ResponseInteractionToJson(
        ResponseInteraction instance) =>
    <String, dynamic>{
      'headers': instance.headers,
      'body': instance.body,
      'correlator': instance.correlator,
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
