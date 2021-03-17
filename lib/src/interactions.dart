import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'interactions.g.dart';

@JsonSerializable()
class Cassette {
  Cassette({
    this.name,
    this.interactions,
  });

  final String name;
  final List<InteractionPair> interactions;

  Map<String, dynamic> toJson() => _$CassetteToJson(this);
  static Cassette fromJson(dynamic json) => _$CassetteFromJson(json);
}

@JsonSerializable()
class InteractionPair {
  InteractionPair({this.request, this.response});

  RequestInteraction request;
  ResponseInteraction response;

  Map<String, dynamic> toJson() => _$InteractionPairToJson(this);
  static InteractionPair fromJson(dynamic json) =>
      _$InteractionPairFromJson(json);
}

@JsonSerializable()
class RequestInteraction {
  RequestInteraction({
    @required this.method,
    @required this.url,
    @required this.headers,
    this.body,
  });

  final String method;
  final String url;
  final Map<String, String> headers;
  final InteractionBody body;

  @override
  String toString() => 'request $method $url ${body?.toShortString()}';

  Map<String, dynamic> toJson() => _$RequestInteractionToJson(this);
  static RequestInteraction fromJson(dynamic json) =>
      _$RequestInteractionFromJson(json);
}

@JsonSerializable()
class ResponseInteraction {
  ResponseInteraction({
    @required this.status,
    this.headers,
    this.body,
  });
  final int status;
  final Map<String, String> headers;
  final InteractionBody body;

  @override
  String toString() => 'response $status ${body?.toShortString()}';

  Map<String, dynamic> toJson() => _$ResponseInteractionToJson(this);
  static ResponseInteraction fromJson(dynamic json) =>
      _$ResponseInteractionFromJson(json);
}

@JsonSerializable()
class InteractionBody {
  InteractionBody({
    @required this.encoding,
    @required this.string,
  });
  final String encoding;
  final String string;

  String toShortString() {
    return string.length < 80
        ? string
        : '${string.replaceAll('\n', '').substring(0, 79)}…';
  }

  Map<String, dynamic> toJson() => _$InteractionBodyToJson(this);
  static InteractionBody fromJson(dynamic json) =>
      _$InteractionBodyFromJson(json);
}
