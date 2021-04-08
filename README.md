# Betamax
[![betamax Pub](https://img.shields.io/pub/v/betamax)](https://pub.dev/packages/betamax)
[![test](https://github.com/madewithfelt/betamax/actions/workflows/test.yml/badge.svg)](https://github.com/madewithfelt/betamax/actions/workflows/test.yml)

Record your test suite's HTTP interactions and replay them during future test
runs for fast, deterministic, accurate tests.

Like Ruby's VCR, but for the [`http`](https://pub.dev/packages/http) Dart
package.

Implements a custom client capable of recording all types of request, including
`StreamedRequest`s and `MultipartRequest`s.

```dart
import 'package:betamax/betamax.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() async {
  setUpAll(() {
    // We use an environment variable to determine whether we should be
    // recording or playing back HTTP interactions.
    final recordFixtures = bool.fromEnvironment('RECORD_HTTP_FIXTURES');

    Betamax.configureSuite(
      // The name of the test suite (I generally name this according to file)
      suiteName: 'echo',
      // Whether to record HTTP traffic passing through Betamax clients, or
      // to playback existing fixtures
      mode: recordFixtures ? Mode.recording : Mode.playback,
      // Path relative to `/test` where your fixtures should be stored
      relativeCassettePath: 'http_fixtures',
    );
  });

  late http.Client httpClient;
  setUp(() {
    // Sets up a new client according to the options provided to
    // `configureSuite`.
    httpClient = Betamax.clientForTest();
  });

  // Writes/reads a cassette (http fixture) to
  // `/test/http_fixtures/echo/response_is_ok.json`
  test('response is OK', () async {
    final response =
        await httpClient.get(Uri.parse('http://scooterlabs.com/echo?foo=bar'));
    expect(response.statusCode, 200);
  });
}
```

## Getting started
### Latest Release

```yaml
dependencies:
  betamax: ^1.0.0
```
