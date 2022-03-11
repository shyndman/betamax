import 'package:test/test.dart';
import 'package:test_api/src/backend/invoker.dart';
import 'package:betamax/betamax.dart';

void main() {
  group('cassette paths', () {
    group('a', () {
      group('b', () {
        group('c', () {
          test('are automatically generated appropriately', () async {
            expect(
                Betamax.cassettePathFromTest(Invoker.current!.liveTest),
                equals(
                  [
                    'cassette paths',
                    'a',
                    'b',
                    'c',
                    'are automatically generated appropriately',
                  ],
                ));
          });
        });
      });
    });
  });
}
