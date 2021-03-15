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

  Interceptor interceptor;
  int _correlatorBase;
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
    interceptor.interceptRequest(request, correlator);
  }

  void _interceptStreamedResponse(
    InterceptedIOStreamedResponse response,
    String correlator,
  ) {
    interceptor.interceptStreamedResponse(response, correlator);
  }

  String _generateCorrelator() {
    _exchangeCount++;
    return '$_correlatorBase-$_exchangeCount';
  }
}
