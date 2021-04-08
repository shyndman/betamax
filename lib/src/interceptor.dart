import 'dart:async';

import 'package:betamax/src/http/http_interceptor.dart';
import 'package:meta/meta.dart';

import 'interactions.dart';

/// An interceptor that holds a betamax cassette for context.
abstract class BetamaxInterceptor extends HttpInterceptor {
  @protected
  String? cassetteFilePath;

  /// `true` if the interceptor is currently associated with a cassette (a
  /// recording of HTTP interactions).
  bool get isCassetteInserted => cassetteFilePath != null;

  /// Begin recording or playback for the cassette named [cassetteFilePath].
  @mustCallSuper
  void insertCassette(String cassetteFilePath) {
    this.cassetteFilePath = cassetteFilePath;
  }

  /// Finish recording or playback for the cassette named [cassetteFilePath].
  FutureOr<Cassette> ejectCassette();
}
