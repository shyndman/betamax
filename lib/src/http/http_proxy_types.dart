import 'dart:io';

import 'package:http/http.dart';
import 'package:http/io_client.dart';

class ProxyBaseRequest implements BaseRequest {
  ProxyBaseRequest(BaseRequest inner) : _inner = inner;

  final BaseRequest _inner;

  @override
  Uri get url => _inner.url;

  @override
  String get method => _inner.method;

  @override
  Map<String, String> get headers => _inner.headers;

  @override
  int? get contentLength => _inner.contentLength;

  @override
  set contentLength(int? value) => _inner.contentLength = value;

  @override
  bool get persistentConnection => _inner.persistentConnection;

  @override
  set persistentConnection(bool value) => _inner.persistentConnection = value;

  @override
  bool get followRedirects => _inner.followRedirects;

  @override
  set followRedirects(bool value) => _inner.followRedirects = value;

  @override
  int get maxRedirects => _inner.maxRedirects;

  @override
  set maxRedirects(int value) => _inner.maxRedirects = value;

  @override
  bool get finalized => _inner.finalized;

  @override
  ByteStream finalize() => _inner.finalize();

  @override
  Future<StreamedResponse> send() => _inner.send();
}

class ProxyIOStreamedResponse implements IOStreamedResponse {
  ProxyIOStreamedResponse(IOStreamedResponse inner) : _inner = inner;

  final IOStreamedResponse _inner;

  @override
  int get statusCode => _inner.statusCode;

  @override
  BaseRequest? get request => _inner.request;

  @override
  Map<String, String> get headers => _inner.headers;

  @override
  ByteStream get stream => _inner.stream;

  @override
  int? get contentLength => _inner.contentLength;

  @override
  bool get isRedirect => _inner.isRedirect;

  @override
  bool get persistentConnection => _inner.persistentConnection;

  @override
  String? get reasonPhrase => _inner.reasonPhrase;

  @override
  Future<Socket> detachSocket() => _inner.detachSocket();
}
