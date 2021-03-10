import 'intercepted_exchanges.dart';

abstract class Interceptor {
  void interceptRequest(InterceptedBaseRequest request);
  void interceptStreamedResponse(InterceptedIOStreamedResponse response);
}
