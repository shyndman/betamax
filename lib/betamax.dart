import 'dart:async';

import 'package:betamax/src/http/http_intercepting_client.dart';
import 'package:betamax/src/interceptor.dart';
import 'package:betamax/src/recording_interceptor.dart';
import 'package:http/http.dart' as http;
import 'package:pedantic/pedantic.dart';
import 'package:slugify_string/slugify_string.dart';
import 'package:test_api/src/backend/invoker.dart';

import 'src/playback_interceptor.dart';

export 'src/http/http_intercepting_client.dart';
export 'src/interactions.dart';

enum Mode {
  recording,
  playback,
}

class Betamax {
  static String? suiteName;
  static Mode? mode;
  static String? cassettePath;
  static bool get isConfigured => mode != null && cassettePath != null;

  static HttpInterceptingClient? _activeClient;

  static void configure({
    required String suiteName,
    required Mode mode,
    required String cassettePath,
  }) {
    Betamax.suiteName = suiteName;
    Betamax.mode = mode;
    Betamax.cassettePath = cassettePath;
  }

  static const String noPlaybackTag = 'no-playback';

  /// The returned client will be freed automatically when the test completes.
  static http.Client clientForTest() {
    assert(Betamax.isConfigured);
    assert(_activeClient == null);

    final interceptor = Betamax.mode == Mode.recording
        ? RecordingInterceptor()
        : PlaybackInterceptor();

    Invoker.current!.liveTest.onComplete.then((value) {
      _activeClient = null;
    });

    return _activeClient = HttpInterceptingClient(interceptor: interceptor);
  }

  static Future<void> setCassette(List<String> cassettePathParts) async {
    final cassettePath = [suiteName]
        .followedBy(cassettePathParts)
        .map((part) => Slugify(part!.trim(), delimiter: '_'))
        .join('/');

    final interceptor = _activeClient!.interceptor as BetamaxInterceptor;
    await interceptor.insertCassette(cassettePath);

    unawaited(
      Invoker.current!.liveTest.onComplete
          .then((value) => interceptor.ejectCassette()),
    );
  }
}
