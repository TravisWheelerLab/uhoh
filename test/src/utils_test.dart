import 'package:test/test.dart';

import 'package:uhoh/src/utils.dart';

void main() {
  group('utils', () {
    group('wrapString', () {
      test('should wrap a simple string', () {
        var original = 'hi hi world';
        var wrapped = wrapString(original, 5);
        var lines = wrapped.split('\n');

        expect(lines, hasLength(2));
        expect(lines[0], 'hi hi');
        expect(lines[1], 'world');
      });

      test('should prepend a string to each line', () {
        var original = 'hi';
        var wrapped = wrapString(original, 5, initial: 'first');
        var lines = wrapped.split('\n');

        expect(lines, hasLength(2));
        expect(lines[0], 'first');
        expect(lines[1], 'hi');
      });

      test('should apply a hanging indent', () {
        var original = 'world hi';
        var wrapped = wrapString(original, 5, hangingIndent: 2);
        var lines = wrapped.split('\n');

        expect(lines, hasLength(2));
        expect(lines[0], 'world');
        expect(lines[1], '  hi');
      });
    });
  });
}
