import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:meta/meta.dart';

import 'http_intercepted_types.dart';
import 'http_interceptor.dart';

class HttpInterceptingClient extends IOClient {
  HttpInterceptingClient({
    HttpClient inner,
    @required this.interceptor,
  }) : super(inner) {
    _correlatorBase = identityHashCode(this);
  }

  HttpInterceptor interceptor;
  int _correlatorBase;
  int _exchangeCount = 0;

  @override
  Future<IOStreamedResponse> send(http.BaseRequest request) async {
    final exchangeCorrelator = _generateCorrelator();

    final interceptedRequest = InterceptedBaseRequest(request);
    final responseOverride = await interceptor.interceptRequest(
        interceptedRequest, exchangeCorrelator);

    final streamedResponse = responseOverride != null
        ? responseOverride.streamedResponse
        : await super.send(interceptedRequest);
    final interceptedStreamedResponse =
        InterceptedIOStreamedResponse(streamedResponse);

    interceptor.interceptStreamedResponse(
        interceptedStreamedResponse, exchangeCorrelator);

    return interceptedStreamedResponse;
  }

  String _generateCorrelator() {
    _exchangeCount++;
    return '$_correlatorBase-$_exchangeCount';
  }
}
