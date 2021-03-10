import 'package:json_annotation/json_annotation.dart';

part 'interactions.g.dart';

class Recording {
  Recording(this.name, {required this.onStop});

  final String name;
  final List<Interaction> interactions = [];
  final void Function() onStop;
  bool running = true;

  void add(Interaction interaction) {
    if (!running) {
      throw StateError('Cannot add interactions to a stopped Recording');
    }

    interactions.add(interaction);
  }

  void stop() {
    running = false;
    onStop();
  }
}

@JsonSerializable()
class RequestInteraction extends Interaction {
  RequestInteraction({
    required this.method,
    required this.uri,
    required Map<String, String> headers,
    InteractionBody? body,
  }) : super(headers: headers, body: body);
  final String method;
  final String uri;

  Map<String, dynamic> toJson() => _$RequestInteractionToJson(this);
  static RequestInteraction fromJson(dynamic json) =>
      _$RequestInteractionFromJson(json);
}

@JsonSerializable()
class ResponseInteraction extends Interaction {
  ResponseInteraction({
    required this.status,
    required Map<String, String> headers,
    InteractionBody? body,
  }) : super(headers: headers, body: body);
  final int status;

  Map<String, dynamic> toJson() => _$ResponseInteractionToJson(this);
  static ResponseInteraction fromJson(dynamic json) =>
      _$ResponseInteractionFromJson(json);
}

abstract class Interaction {
  Interaction({required this.headers, this.body});
  final Map<String, String> headers;
  final InteractionBody? body;
}

@JsonSerializable()
class InteractionBody {
  InteractionBody({required this.encoding, required this.string});
  final String encoding;
  final String string;

  Map<String, dynamic> toJson() => _$InteractionBodyToJson(this);
  static InteractionBody fromJson(dynamic json) =>
      _$InteractionBodyFromJson(json);
}
