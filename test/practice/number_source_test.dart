import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:nombres_a_l_oreille/practice/number_source.dart';

void main() {
  test('random source stays in range and avoids immediate repeats', () {
    final source = RandomNumberSource(Random(42));
    int? previous;

    for (var i = 0; i < 500; i++) {
      final value = source.next(minimum: 60, maximum: 99, previous: previous);
      expect(value, inInclusiveRange(60, 99));
      expect(value, isNot(previous));
      previous = value;
    }
  });

  test('single-number range always returns that number', () {
    final source = RandomNumberSource(Random(42));
    expect(source.next(minimum: 7, maximum: 7), 7);
    expect(source.next(minimum: 7, maximum: 7, previous: 7), 7);
  });
}
