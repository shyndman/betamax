import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:betamax/src/http/http_intercepted_types.dart';
import 'package:http/io_client.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

import '../betamax.dart';
import 'http/http_interceptor.dart';
import 'interceptor.dart';

class PlaybackInterceptor extends BetamaxInterceptor {
  /// The cassette being played back
  Cassette cassette;

  /// The index of the current request-response being played back
  int playheadPosition = 0;

  @override
  void insertCassette(String cassetteFilePath) {
    super.insertCassette(cassetteFilePath);

    final cassetteFile = File(join(Betamax.cassettePath, cassetteFilePath));
    if (!cassetteFile.existsSync()) {
      throw BetamaxPlaybackException('Cassette not found at $cassetteFilePath');
    }

    cassette = Cassette.fromJson(jsonDecode(cassetteFile.readAsStringSync()));
  }

  @override
  FutureOr<void> ejectCassette() {}

  @override
  OverrideResponse interceptRequest(
      InterceptedBaseRequest request, String correlator) {
    if (cassette.interactions.length <= playheadPosition) {
      fail('Unexpected request (${request.method} ${request.url})');
    }

    final interaction = cassette.interactions[playheadPosition];
    final storedReq = interaction.request;

    if (request.method.toLowerCase() != storedReq.method ||
        request.url.toString() != storedReq.url) {
      fail('Unexpected request (${request.method} ${request.url})');
    }

    playheadPosition++;

    final storedRes = interaction.response;
    return OverrideResponse(
      IOStreamedResponse(
        Stream.fromIterable([storedRes.body.string.codeUnits]),
        storedRes.status,
        headers: storedRes.headers,
      ),
    );
  }

  @override
  void interceptStreamedResponse(
      InterceptedIOStreamedResponse response, String correlator) {}
}

class BetamaxPlaybackException implements Exception {
  BetamaxPlaybackException(this.message);
  final String message;

  @override
  String toString() => 'BetamaxPlaybackException: $message';
}
