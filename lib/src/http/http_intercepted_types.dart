import 'package:http/http.dart';
import 'package:http/io_client.dart';

import 'http_proxy_types.dart';
import 'repeatable_byte_stream.dart';

class InterceptedBaseRequest extends ProxyBaseRequest {
  InterceptedBaseRequest(BaseRequest inner) : super(inner);

  RepeatableByteStream _repeatableStream;

  @override
  ByteStream finalize() =>
      _repeatableStream ??= RepeatableByteStream(super.finalize());
}

class InterceptedIOStreamedResponse extends ProxyIOStreamedResponse {
  InterceptedIOStreamedResponse(IOStreamedResponse inner) : super(inner);

  RepeatableByteStream _repeatableStream;

  @override
  ByteStream get stream =>
      _repeatableStream ??= RepeatableByteStream(super.stream);
}
