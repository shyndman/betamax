@Timeout(Duration(seconds: 2))
library repeatable_byte_stream_test;

import 'dart:async';

import 'package:betamax/src/http/repeatable_byte_stream.dart';
import 'package:test/test.dart';

void main() {
  group('RepeatableByteStream', () {
    test('repeats the data of its inner stream', () {
      final controller = StreamController<List<int>>();
      final byteStream = RepeatableByteStream(controller.stream);

      expect(byteStream, emits([1, 2, 3, 4]));

      controller.add([1, 2, 3, 4]);
    });

    test('supports multiple listeners', () {
      final byteStream = RepeatableByteStream(Stream.fromIterable([]));

      expect(
        () {
          byteStream.listen((value) {});
          byteStream.listen((value) {});
        },
        returnsNormally,
      );
    });

    test('re-broadcasts the inner stream even when closed', () async {
      final controller = StreamController<List<int>>();
      final byteStream = RepeatableByteStream(controller.stream);

      controller.add([1, 2, 3, 4]);
      await controller.close();

      expect(
        byteStream.toList(),
        completion([
          [1, 2, 3, 4]
        ]),
      );
    });

    test('emits the same events for all listeners', () async {
      final controller = StreamController<List<int>>();
      final byteStream = RepeatableByteStream(controller.stream);

      // 1st listener, before events emitted
      expect(
        byteStream.toList(),
        completion([
          [1, 2, 3, 4]
        ]),
      );

      controller.add([1, 2, 3, 4]);
      await controller.close();

      // 2nd listener, after bytes emitted
      expect(
        byteStream.toList(),
        completion([
          [1, 2, 3, 4]
        ]),
      );
    });
  });
}
