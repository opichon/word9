/// An encouragement banner.
class EncouragementBanner {
  const EncouragementBanner({required this.text, required this.title});

  final String text;
  final String title;
}

const _nineLetterId = 'nine';

const _milestones = [
  (
    banner: EncouragementBanner(
      text: 'You have found over a third of the words.',
      title: 'Good start!',
    ),
    id: 'p35',
    share: 0.35,
  ),
  (
    banner: EncouragementBanner(
      text: 'Over two thirds found. Keep at it.',
      title: 'Great going!',
    ),
    id: 'p70',
    share: 0.70,
  ),
  (
    banner: EncouragementBanner(
      text: 'You found every word. Brilliant.',
      title: 'Puzzle complete!',
    ),
    id: 'p100',
    share: 1.0,
  ),
];

/// Chooses which banners a found word earns. Each shows once per puzzle.
class BannerTracker {
  BannerTracker({Iterable<String> shown = const []}) : _shown = {...shown};

  final Set<String> _shown;

  /// The banners already shown, by id, to be saved with the game.
  Set<String> get shown => Set.unmodifiable(_shown);

  /// The banners earned by finding [word], with [found] of [total] words now
  /// found, in the order they show: the nine-letter banner first, then only
  /// the highest percentage newly reached.
  List<EncouragementBanner> onWordFound({
    required int found,
    required int total,
    required String word,
  }) {
    final banners = <EncouragementBanner>[];
    if (word.length == 9 && _shown.add(_nineLetterId)) {
      banners.add(
        EncouragementBanner(
          text: '${word.toUpperCase()} uses every tile.',
          title: 'You found the nine-letter word!',
        ),
      );
    }
    final share = found / total;
    final reached = _milestones.where(
      (milestone) => share >= milestone.share && !_shown.contains(milestone.id),
    );
    if (reached.isNotEmpty) {
      banners.add(reached.last.banner);
      _shown.addAll(reached.map((milestone) => milestone.id));
    }
    return banners;
  }
}
