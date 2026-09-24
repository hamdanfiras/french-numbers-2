import 'dart:math';

abstract interface class NumberSource {
  int next({required int minimum, required int maximum, int? previous});
}

class RandomNumberSource implements NumberSource {
  RandomNumberSource([Random? random]) : _random = random ?? Random();

  final Random _random;

  @override
  int next({required int minimum, required int maximum, int? previous}) {
    final count = maximum - minimum + 1;
    if (count == 1) return minimum;

    if (previous == null || previous < minimum || previous > maximum) {
      return minimum + _random.nextInt(count);
    }

    var candidate = minimum + _random.nextInt(count - 1);
    if (candidate >= previous) candidate++;
    return candidate;
  }
}
