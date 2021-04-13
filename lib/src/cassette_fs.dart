import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';

import '../betamax.dart';
import 'interactions.dart';
import 'playback_interceptor.dart';

/// Implemented by classes that perform the reading and writing of cassettes.
abstract class CassetteFs {
  Cassette read(String cassettePath);
  void write(String cassettePath, Cassette cassette);
}

/// Reads and writes cassettes to the local filesystem as JSON.
class JsonIoCassetteFs extends CassetteFs {
  @override
  Cassette read(String cassettePath) {
    final cassetteFile = File(join(Betamax.cassettePath!, cassettePath));
    if (!cassetteFile.existsSync()) {
      throw BetamaxPlaybackException('Fixtures not found at $cassettePath.\n'
          'Have you already recorded your interactions?');
    }

    return Cassette.fromJson(jsonDecode(cassetteFile.readAsStringSync()));
  }

  @override
  void write(String cassettePath, Cassette cassette) {
    final cassetteJson = JsonEncoder.withIndent('  ').convert(cassette);

    File(join(Betamax.cassettePath!, cassettePath))
      ..createSync(recursive: true)
      ..writeAsStringSync(cassetteJson);
  }
}
