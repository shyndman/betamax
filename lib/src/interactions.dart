import 'dart:async';

import 'package:json_annotation/json_annotation.dart';

part 'interactions.g.dart';

class Recording {
  Recording(this.name, {required this.onStop});

  final String name;
  final List<Interaction> interactions = [];
  final void Function() onStop;
  bool running = true;

  final _outstandingCorrelators = <String>{};
  Completer<void>? _responsesReceivedCompletor;

  void addRequest(RequestInteraction interaction) {
    if (!running) {
      throw StateError('Cannot add interactions to a stopped Recording');
    }

    _outstandingCorrelators.add(interaction.correlator);
    interactions.add(interaction);
  }

  void addResponse(ResponseInteraction response) {
    if (!_outstandingCorrelators.contains(response.correlator)) {
      throw StateError(
          'Received a response correlator without an associated request, '
          'correlator=${response.correlator}');
    }

    _outstandingCorrelators.remove(response.correlator);

    if (!running &&
        _outstandingCorrelators.isEmpty &&
        _responsesReceivedCompletor != null) {
      _responsesReceivedCompletor!.complete();
      _responsesReceivedCompletor = null;
    }

    interactions.add(response);
  }

  /// Returns a future that resolves when all outstanding responses have been
  /// received by the recorder.
  Future<void> waitForOutstandingResponses() {
    assert(!running,
        'Please stop the recorder before waiting for outstanding responses');

    if (_outstandingCorrelators.isEmpty) {
      return Future.value();
    }

    _responsesReceivedCompletor ??= Completer();
    return _responsesReceivedCompletor!.future;
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
    required String correlator,
    InteractionBody? body,
  }) : super(headers: headers, body: body, correlator: correlator);
  final String method;
  final String uri;

  @override
  String toString() => 'request $method $uri ${body?.toShortString()}';

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
    required String correlator,
  }) : super(headers: headers, body: body, correlator: correlator);
  final int status;

  @override
  String toString() => 'response $status ${body?.toShortString()}';

  Map<String, dynamic> toJson() => _$ResponseInteractionToJson(this);
  static ResponseInteraction fromJson(dynamic json) =>
      _$ResponseInteractionFromJson(json);
}

abstract class Interaction {
  Interaction({required this.headers, this.body, required this.correlator});
  final Map<String, String> headers;
  final InteractionBody? body;
  final String correlator;
}

@JsonSerializable()
class InteractionBody {
  InteractionBody({required this.encoding, required this.string});
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
