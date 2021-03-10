import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import 'interactions.dart';
import 'intercepted_exchanges.dart';
import 'interceptor.dart';

class RecordingIOClient extends IOClient {
  RecordingIOClient([HttpClient? inner]) : super(inner);

  RecordingInterceptor recordingInterceptor = RecordingInterceptor();

  @override
  Future<IOStreamedResponse> send(http.BaseRequest request) async {
    final interceptedRequest = InterceptedBaseRequest(request);
    _interceptRequest(interceptedRequest);

    final interceptedStreamedResponse =
        InterceptedIOStreamedResponse(await super.send(interceptedRequest));
    _interceptStreamedResponse(interceptedStreamedResponse);

    return interceptedStreamedResponse;
  }

  void _interceptRequest(InterceptedBaseRequest request) {
    recordingInterceptor.interceptRequest(request);
  }

  void _interceptStreamedResponse(InterceptedIOStreamedResponse response) {
    recordingInterceptor.interceptStreamedResponse(response);
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
  void interceptRequest(InterceptedBaseRequest request) async {
    if (_activeRecording == null) {
      return;
    }

    final contentType =
        request.headers.containsKey(HttpHeaders.contentTypeHeader)
            ? ContentType.parse(request.headers[HttpHeaders.contentTypeHeader]!)
            : null;
    final encoding = contentType?.charset ?? latin1.name;
    final bodyString = await request
        .finalize()
        .bytesToString(Encoding.getByName(encoding) ?? latin1);

    _activeRecording?.add(
      RequestInteraction(
        method: request.method.toLowerCase(),
        uri: request.url.toString(),
        headers: request.headers,
        body: bodyString.isNotEmpty
            ? InteractionBody(encoding: encoding, string: bodyString)
            : null,
      ),
    );
  }

  @override
  void interceptStreamedResponse(InterceptedIOStreamedResponse response) async {
    final recording = _activeRecording;
    if (recording == null) {
      return;
    }

    final contentType =
        ContentType.parse(response.headers[HttpHeaders.contentTypeHeader]!);
    final encoding = contentType.charset ?? latin1.name;

    recording.add(
      ResponseInteraction(
        status: response.statusCode,
        headers: response.headers,
        body: InteractionBody(
          encoding: encoding,
          string: await response.stream.bytesToString(
            Encoding.getByName(encoding) ?? latin1,
          ),
        ),
      ),
    );
  }
}
