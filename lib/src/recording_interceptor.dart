import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';

import '../betamax.dart';
import 'http/http_intercepted_types.dart';
import 'http/http_interceptor.dart';
import 'interactions.dart';
import 'interceptor.dart';

class RecordingInterceptor extends BetamaxInterceptor {
  final Map<String, RequestInteraction> _requestsByCorrelator = {};
  final Map<String, ResponseInteraction> _responsesByCorrelator = {};
  final _outstandingCorrelators = <String>{};
  Completer<void> _responsesReceivedCompletor;

  @override
  Future<void> ejectCassette() async {
    if (_outstandingCorrelators.isNotEmpty) {
      _responsesReceivedCompletor = Completer();
      await _responsesReceivedCompletor.future;
    }

    final pairs = _requestsByCorrelator.entries
        .map(
          (entry) => InteractionPair(
              request: entry.value,
              response: _responsesByCorrelator[entry.key]),
        )
        .toList();

    final cassette = Cassette(name: cassetteFilePath, interactions: pairs);
    final cassetteJson = JsonEncoder.withIndent('  ').convert(cassette);

    final cassetteFile = File(join(Betamax.cassettePath, cassetteFilePath));
    cassetteFile.createSync(recursive: true);
    cassetteFile.writeAsStringSync(cassetteJson);
  }

  @override
  Future<OverrideResponse> interceptRequest(
      InterceptedBaseRequest request, String correlator) async {
    final encoding =
        _findEncoding(request.headers[HttpHeaders.contentTypeHeader]);
    final bodyString = await request.finalize().bytesToString(encoding);

    _addRequestInteraction(
      RequestInteraction(
        method: request.method.toLowerCase(),
        url: request.url.toString(),
        headers: request.headers,
        body: bodyString.isNotEmpty
            ? InteractionBody(encoding: encoding.name, string: bodyString)
            : null,
      ),
      correlator,
    );

    return null; // Allow
  }

  @override
  void interceptStreamedResponse(
    InterceptedIOStreamedResponse response,
    String correlator,
  ) async {
    if (!_outstandingCorrelators.contains(correlator)) {
      throw StateError(
          'Received a response correlator without an associated request, '
          'correlator=$correlator');
    }

    final encoding =
        _findEncoding(response.headers[HttpHeaders.contentTypeHeader]);
    final bodyString = await response.stream.bytesToString(encoding);

    _addResponseInteraction(
      ResponseInteraction(
        status: response.statusCode,
        headers: response.headers,
        body: InteractionBody(
          encoding: encoding.name,
          string: bodyString,
        ),
      ),
      correlator,
    );
  }

  Encoding _findEncoding(String contentTypeString) {
    if (contentTypeString == null) return latin1;

    final contentType = ContentType.parse(contentTypeString);
    final charset = contentType.charset;
    if (charset == null) return latin1;

    return Encoding.getByName(contentType.charset) ?? latin1;
  }

  void _addRequestInteraction(
    RequestInteraction interaction,
    String correlator,
  ) {
    _outstandingCorrelators.add(correlator);
    _requestsByCorrelator[correlator] = interaction;
  }

  void _addResponseInteraction(
    ResponseInteraction response,
    String correlator,
  ) {
    _outstandingCorrelators.remove(correlator);
    _responsesByCorrelator[correlator] = response;

    if (_responsesReceivedCompletor != null &&
        _outstandingCorrelators.isEmpty) {
      _responsesReceivedCompletor.complete();
      _responsesReceivedCompletor = null;
    }
  }
}
