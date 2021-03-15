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
  @JsonKey(toJson: interactionsToJson, fromJson: interactionsFromJson)
  final List<Interaction> interactions;

  Map<String, dynamic> toJson() => _$CassetteToJson(this);
  static Cassette fromJson(dynamic json) => _$CassetteFromJson(json);
}

@JsonSerializable()
class RequestInteraction extends Interaction {
  RequestInteraction({
    @required this.method,
    @required this.uri,
    @required Map<String, String> headers,
    @required String correlator,
    InteractionBody body,
  }) : super(headers: headers, body: body, correlator: correlator);
  final String method;
  final String uri;

  @override
  String toString() => 'request $method $uri ${body?.toShortString()}';

  @override
  Map<String, dynamic> toJson() => _$RequestInteractionToJson(this);
  static RequestInteraction fromJson(dynamic json) =>
      _$RequestInteractionFromJson(json);
}

@JsonSerializable()
class ResponseInteraction extends Interaction {
  ResponseInteraction({
    this.status,
    Map<String, String> headers,
    InteractionBody body,
    @required String correlator,
  }) : super(headers: headers, body: body, correlator: correlator);
  final int status;

  @override
  String toString() => 'response $status ${body?.toShortString()}';

  @override
  Map<String, dynamic> toJson() => _$ResponseInteractionToJson(this);
  static ResponseInteraction fromJson(dynamic json) =>
      _$ResponseInteractionFromJson(json);
}

List<Map<String, dynamic>> interactionsToJson(List<Interaction> interactions) {
  return interactions.map((interaction) => interaction.toJson()).toList();
}

List<Interaction> interactionsFromJson(dynamic json) {
  return (json as List<dynamic>)
      .map((element) => element.containsKey('method')
          ? RequestInteraction.fromJson(element)
          : ResponseInteraction.fromJson(element))
      .toList();
}

abstract class Interaction {
  Interaction({
    @required this.headers,
    this.body,
    @required this.correlator,
  });
  final Map<String, String> headers;
  final InteractionBody body;
  final String correlator;

  Map<String, dynamic> toJson();
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
