import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import 'interactions.dart';
import 'intercepted_exchanges.dart';
import 'interceptor.dart';

class RecordingIOClient extends IOClient {
  RecordingIOClient([HttpClient? inner]) : super(inner) {
    _correlatorBase = identityHashCode(this);
  }

  final recordingInterceptor = RecordingInterceptor();
  late int _correlatorBase;
  int _exchangeCount = 0;

  @override
  Future<IOStreamedResponse> send(http.BaseRequest request) async {
    final exchangeCorrelator = _generateCorrelator();

    final interceptedRequest = InterceptedBaseRequest(request);
    _interceptRequest(interceptedRequest, exchangeCorrelator);

    final interceptedStreamedResponse =
        InterceptedIOStreamedResponse(await super.send(interceptedRequest));
    _interceptStreamedResponse(interceptedStreamedResponse, exchangeCorrelator);

    return interceptedStreamedResponse;
  }

  void _interceptRequest(
    InterceptedBaseRequest request,
    String correlator,
  ) {
    recordingInterceptor.interceptRequest(request, correlator);
  }

  void _interceptStreamedResponse(
    InterceptedIOStreamedResponse response,
    String correlator,
  ) {
    recordingInterceptor.interceptStreamedResponse(response, correlator);
  }

  String _generateCorrelator() {
    _exchangeCount++;
    return '$_correlatorBase-$_exchangeCount';
  }
}

class RecordingInterceptor implements Interceptor {
  Recording? _activeRecording;

  Recording start(String name) {
    if (_activeRecording != null) {
      _activeRecording!.stop();
    }

    late Recording newRecording;
    newRecording = Recording(name, onStop: () {
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

  Encoding findEncoding(String? contentTypeString) {
    if (contentTypeString == null) return latin1;

    final contentType = ContentType.parse(contentTypeString);
    final charset = contentType.charset;
    if (charset == null) return latin1;

    return Encoding.getByName(contentType.charset) ?? latin1;
  }
}
