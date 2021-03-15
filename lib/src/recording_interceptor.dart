import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';

import 'http/http_intercepted_types.dart';
import 'http/http_interceptor.dart';
import 'interactions.dart';

class RecordingInterceptor implements Interceptor {
  Cassette _activeRecording;

  Cassette start(String name) {
    if (_activeRecording != null) {
      _activeRecording.stop();
    }

    Cassette newRecording;
    newRecording = Cassette(name, onStop: () {
      if (_activeRecording == newRecording) {
        _activeRecording = null;
      }
    });
    return _activeRecording = newRecording;
  }

  @override
  void interceptRequest(
      InterceptedBaseRequest request, String correlator) async {
    final recording = _activeRecording;
    if (recording == null) {
      return;
    }

    final encoding =
        findEncoding(request.headers[HttpHeaders.contentTypeHeader]);
    final bodyString = await request.finalize().bytesToString(encoding);

    recording.addRequest(
      RequestInteraction(
        method: request.method.toLowerCase(),
        uri: request.url.toString(),
        headers: request.headers,
        body: bodyString.isNotEmpty
            ? InteractionBody(encoding: encoding.name, string: bodyString)
            : null,
        correlator: correlator,
      ),
    );
  }

  @override
  void interceptStreamedResponse(
    InterceptedIOStreamedResponse response,
    String correlator,
  ) async {
    final recording = _activeRecording;
    if (recording == null) {
      return;
    }

    final encoding =
        findEncoding(response.headers[HttpHeaders.contentTypeHeader]);
    final bodyString = await response.stream.bytesToString(encoding);

    recording.addResponse(
      ResponseInteraction(
        status: response.statusCode,
        headers: response.headers,
        body: InteractionBody(
          encoding: encoding.name,
          string: bodyString,
        ),
        correlator: correlator,
      ),
    );
  }

  Encoding findEncoding(String contentTypeString) {
    if (contentTypeString == null) return latin1;

    final contentType = ContentType.parse(contentTypeString);
    final charset = contentType.charset;
    if (charset == null) return latin1;

    return Encoding.getByName(contentType.charset) ?? latin1;
  }
}

class Cassette {
  Cassette(this.name, {@required this.onStop});

  final String name;
  final List<Interaction> interactions = [];
  final void Function() onStop;
  bool running = true;

  final _outstandingCorrelators = <String>{};
  Completer<void> _responsesReceivedCompletor;

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
      _responsesReceivedCompletor.complete();
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
    return _responsesReceivedCompletor.future;
  }

  void stop() {
    running = false;
    onStop();
  }
}
