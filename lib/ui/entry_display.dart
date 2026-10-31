import 'package:flutter/material.dart';

/// The letters of the entry, which shakes each time [shakes] rises.
class EntryDisplay extends StatefulWidget {
  const EntryDisplay({required this.letters, required this.shakes, super.key});

  final List<({bool isCentre, String letter})> letters;
  final int shakes;

  @override
  State<EntryDisplay> createState() => _EntryDisplayState();
}

class _EntryDisplayState extends State<EntryDisplay>
    with SingleTickerProviderStateMixin {
  static const _shakeDistance = 6.0;

  late final AnimationController _shake = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );
  late final Animation<double> _offset = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0, end: -_shakeDistance), weight: 25),
    TweenSequenceItem(
      tween: Tween(begin: -_shakeDistance, end: _shakeDistance),
      weight: 50,
    ),
    TweenSequenceItem(tween: Tween(begin: _shakeDistance, end: 0), weight: 25),
  ]).animate(_shake);

  @override
  void didUpdateWidget(EntryDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shakes > oldWidget.shakes) _shake.forward(from: 0);
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _offset,
      builder: (context, child) => Transform.translate(
        key: const ValueKey('entry-shake'),
        offset: Offset(_offset.value, 0),
        child: child,
      ),
      child: SizedBox(
        height: 48,
        child: Center(
          child: Text.rich(
            TextSpan(
              children: [
                for (final (:isCentre, :letter) in widget.letters)
                  TextSpan(
                    style: isCentre
                        ? TextStyle(color: theme.colorScheme.primary)
                        : null,
                    text: letter.toUpperCase(),
                  ),
              ],
            ),
            key: const ValueKey('entry'),
            style: theme.textTheme.headlineMedium?.copyWith(letterSpacing: 3),
          ),
        ),
      ),
    );
  }
}
