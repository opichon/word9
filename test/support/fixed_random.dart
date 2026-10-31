import 'dart:math';

/// A random source that always returns the same index.
class FixedRandom implements Random {
  FixedRandom(this.value);

  final int value;

  @override
  int nextInt(int max) => value % max;

  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0;
}
