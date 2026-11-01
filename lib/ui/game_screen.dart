import 'package:flutter/material.dart';

import '../game/word_validation.dart';
import '../state/game_controller.dart';
import 'entry_display.dart';

/// The main screen: board, entry, message, controls and words found.
class GameScreen extends StatelessWidget {
  const GameScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final board = controller.board;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('word9', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                if (board == null)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  _Board(controller: controller),
                  const SizedBox(height: 16),
                  EntryDisplay(
                    letters: board.picked
                        .map(
                          (index) => (
                            isCentre: index == centreIndex,
                            letter: board.letters[index],
                          ),
                        )
                        .toList(),
                    shakes: controller.shakes,
                  ),
                  _Message(message: controller.message),
                  const SizedBox(height: 8),
                  _Controls(controller: controller),
                  const SizedBox(height: 16),
                  _WordsFound(controller: controller),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Board extends StatelessWidget {
  const _Board({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final board = controller.board!;
    return Center(
      child: SizedBox(
        width: 300,
        child: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            for (var index = 0; index < board.letters.length; index++)
              FilledButton.tonal(
                key: ValueKey('tile-$index'),
                onPressed: board.picked.contains(index)
                    ? null
                    : () => controller.tapTile(index),
                style: index == centreIndex
                    ? FilledButton.styleFrom(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primaryContainer,
                      )
                    : null,
                child: Text(
                  board.letters[index].toUpperCase(),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.message});

  final GameMessage? message;

  @override
  Widget build(BuildContext context) {
    final message = this.message;
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 24,
      child: message == null
          ? null
          : Text(
              message.text,
              key: const ValueKey('message'),
              style: TextStyle(
                color: message.kind == MessageKind.good
                    ? colors.primary
                    : colors.error,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: controller.delete,
            child: const Text('Delete'),
          ),
        ),
        Expanded(
          child: OutlinedButton(
            onPressed: controller.shuffle,
            child: const Text('Shuffle'),
          ),
        ),
        Expanded(
          child: FilledButton(
            onPressed: controller.submit,
            child: const Text('Enter'),
          ),
        ),
      ],
    );
  }
}

class _WordsFound extends StatelessWidget {
  const _WordsFound({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final tally = controller.tally;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Words found', style: Theme.of(context).textTheme.titleMedium),
            Text('${tally.foundCount} of ${tally.total}'),
          ],
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final word in tally.foundWords) Chip(label: Text(word)),
          ],
        ),
      ],
    );
  }
}
