import 'package:betamax/betamax.dart';
import 'package:betamax/src/http/http_intercepting_client.dart';
import 'package:betamax/src/interactions.dart';
import 'package:betamax/src/playback_interceptor.dart';
import 'package:test/test.dart';

void main() {
  group('PlaybackInterceptor', () {
    test('plays back responses that match requests', () async {
      final client = stubSimplePlaybackClient(
        request: RequestInteraction(
          method: 'get',
          url: 'http://test.com',
          headers: {},
        ),
        response: ResponseInteraction(
          status: 418,
          headers: {
            'content-type': 'application/tea-pot',
          },
          body: InteractionBody(
            string: 'Short and stout',
            encoding: 'utf-8',
          ),
        ),
      );

      final response = await client.get(Uri.parse('http://test.com'));
      expect(response.statusCode, 418);
      expect(response.headers, {'content-type': 'application/tea-pot'});
      expect(response.body, 'Short and stout');
      expect(response.request?.method, equalsIgnoringCase('get'));
    });

    test('fails when requests are not expected', () async {
      final client = stubSimplePlaybackClient(
        request: RequestInteraction(
          method: 'post',
          url: 'http://postpostpost.com',
          headers: {},
        ),
        response: ResponseInteraction(status: 200),
      );

      expect(client.get(Uri.parse('http://getgetget.com')), throwsA(anything));
    });

    test('plays back multiple responses in sequence', () async {
      final client = stubPlaybackClientWithCassette(Cassette(
        interactions: [
          InteractionPair(
            request: RequestInteraction(
              method: 'post',
              url: 'http://postpostpost.com',
            ),
            response: ResponseInteraction(
              status: 404,
              body: InteractionBody(string: 'abcd'),
            ),
          ),
          InteractionPair(
            request: RequestInteraction(
              method: 'get',
              url: 'http://getgetget.com',
            ),
            response: ResponseInteraction(
              status: 200,
              body: InteractionBody(string: 'efgh'),
            ),
          ),
        ],
      ));

      var response = await client.post(Uri.parse('http://postpostpost.com'));
      expect(response.statusCode, 404);
      expect(response.body, 'abcd');

      response = await client.get(Uri.parse('http://getgetget.com'));
      expect(response.statusCode, 200);
      expect(response.body, 'efgh');
    });

    test('fails when requests are out of sequence', () async {
      final client = stubPlaybackClientWithCassette(Cassette(
        interactions: [
          InteractionPair(
            request: RequestInteraction(
              method: 'post',
              url: 'http://postpostpost.com',
            ),
            response: ResponseInteraction(
              status: 404,
              body: InteractionBody(string: 'abcd'),
            ),
          ),
          InteractionPair(
            request: RequestInteraction(
              method: 'get',
              url: 'http://getgetget.com',
            ),
            response: ResponseInteraction(
              status: 200,
              body: InteractionBody(string: 'efgh'),
            ),
          ),
        ],
      ));

      expect(client.get(Uri.parse('http://getgetget.com')), throwsA(anything));
    });
  });
}

HttpInterceptingClient stubSimplePlaybackClient({
  required RequestInteraction request,
  required ResponseInteraction response,
}) {
  return stubPlaybackClientWithCassette(Cassette(
    interactions: [
      InteractionPair(
        request: request,
        response: response,
      ),
    ],
  ));
}

HttpInterceptingClient stubPlaybackClientWithCassette(Cassette cassette) {
  Betamax.cassetteFs = TestPlaybackCassetteFs(cassette);
  return HttpInterceptingClient(
      interceptor: PlaybackInterceptor()
        // This path doesn't matter. The TestPlaybackCassetteFs's argument
        // is what the client uses.
        ..insertCassette('/test_cassette.json'));
}

/// Subclasses to always [read] the same cassette.
class TestPlaybackCassetteFs extends CassetteFs {
  TestPlaybackCassetteFs(this.cassette);
  final Cassette cassette;

  @override
  Cassette read(String cassettePath) => cassette;

  @override
  void write(String cassettePath, Cassette cassette) =>
      throw UnsupportedError('Write not supported');
}
