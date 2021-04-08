import 'dart:io';

import 'package:betamax/betamax.dart';
import 'package:betamax/src/http/http_intercepting_client.dart';
import 'package:betamax/src/interactions.dart';
import 'package:betamax/src/recording_interceptor.dart';
import 'package:test/test.dart';

const testPort = 4563;

void main() {
  group('RecordingInterceptor', () {
    late HttpServer server;
    setUp(() async {
      server = HttpServer.listenOn(
        await ServerSocket.bind('localhost', testPort),
      );
      server.listen((request) {
        request.response
          ..statusCode = 418
          ..write('Hello, world!')
          ..close();
      });
    });

    tearDown(() async {
      await server.close();
    });

    test('records interactions into cassette objects', () async {
      final expectedUrl = 'http://localhost:$testPort/getgetget';

      final client = stubRecordingClient();
      final recordingInterceptor = client.interceptor as RecordingInterceptor;

      await client.get(Uri.parse(expectedUrl));
      final cassette = await recordingInterceptor.ejectCassette();
      final request = cassette.interactions.first.request!;
      final response = cassette.interactions.first.response!;

      expect(request.url, expectedUrl);
      expect(response.status, 418);
    });
  });
}

HttpInterceptingClient stubRecordingClient() {
  Betamax.cassetteFs = TestRecordingCassetteFs();
  return HttpInterceptingClient(
      interceptor: RecordingInterceptor()
        // This path doesn't matter. The TestPlaybackCassetteFs's argument
        // is what the client uses.
        ..insertCassette('/test_cassette.json'));
}

/// Subclasses to write the cassette to a field.
class TestRecordingCassetteFs extends CassetteFs {
  Cassette? cassette;

  @override
  Cassette read(String cassettePath) =>
      throw UnsupportedError('Read not supported');

  @override
  void write(String cassettePath, Cassette cassette) =>
      this.cassette = cassette;
}
