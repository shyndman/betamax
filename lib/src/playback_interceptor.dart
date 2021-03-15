import 'package:betamax/src/http/http_intercepted_types.dart';
import 'package:betamax/src/http/http_interceptor.dart';

class RecordingInterceptor extends Interceptor {
  @override
  void interceptRequest(InterceptedBaseRequest request, String correlator) {}

  @override
  void interceptStreamedResponse(
      InterceptedIOStreamedResponse response, String correlator) {}
}
