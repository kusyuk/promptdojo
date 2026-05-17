/// Represents the different story nodes/phases in the game
enum StoryNode {
  /// Act 1: Tutorial phase where user is forced to make a bad prompt
  tutorial,

  /// Act 2: Planning phase - choose to create blueprint or not
  planning,

  /// Act 2: Context phase - choose how much context to provide
  context,

  /// Act 2: Incantation phase - user writes their prompt
  incantation,

  /// Act 3: Bad ending - mana depleted
  badEnding,

  /// Act 3: Good ending - mana remaining
  goodEnding,
}

// Made with Bob
