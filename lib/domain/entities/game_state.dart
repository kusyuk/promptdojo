import 'story_node.dart';

/// Represents the current state of the game
///
/// This class manages all game state including mana reserves, blueprint status,
/// context cost, and the current story node. It's immutable and uses copyWith
/// for state updates.
class GameState {
  /// Current mana reserves (starts at 1000)
  final int manaReserves;

  /// Whether the player chose to create a blueprint/PRD
  final bool hasBlueprint;

  /// Cost of context window usage
  final int contextCost;

  /// Current story node/phase
  final StoryNode currentStoryNode;

  const GameState({
    required this.manaReserves,
    required this.hasBlueprint,
    required this.contextCost,
    required this.currentStoryNode,
  });

  /// Initial game state
  factory GameState.initial() {
    return const GameState(
      manaReserves: 1000,
      hasBlueprint: false,
      contextCost: 0,
      currentStoryNode: StoryNode.tutorial,
    );
  }

  /// Creates a copy of this state with the given fields replaced
  GameState copyWith({
    int? manaReserves,
    bool? hasBlueprint,
    int? contextCost,
    StoryNode? currentStoryNode,
  }) {
    return GameState(
      manaReserves: manaReserves ?? this.manaReserves,
      hasBlueprint: hasBlueprint ?? this.hasBlueprint,
      contextCost: contextCost ?? this.contextCost,
      currentStoryNode: currentStoryNode ?? this.currentStoryNode,
    );
  }

  /// Converts state to JSON
  Map<String, dynamic> toJson() {
    return {
      'manaReserves': manaReserves,
      'hasBlueprint': hasBlueprint,
      'contextCost': contextCost,
      'currentStoryNode': currentStoryNode.name,
    };
  }

  /// Creates state from JSON
  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      manaReserves: json['manaReserves'] as int,
      hasBlueprint: json['hasBlueprint'] as bool,
      contextCost: json['contextCost'] as int,
      currentStoryNode: StoryNode.values.firstWhere(
        (node) => node.name == json['currentStoryNode'],
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GameState &&
        other.manaReserves == manaReserves &&
        other.hasBlueprint == hasBlueprint &&
        other.contextCost == contextCost &&
        other.currentStoryNode == currentStoryNode;
  }

  @override
  int get hashCode {
    return Object.hash(
      manaReserves,
      hasBlueprint,
      contextCost,
      currentStoryNode,
    );
  }

  @override
  String toString() {
    return 'GameState(manaReserves: $manaReserves, hasBlueprint: $hasBlueprint, '
        'contextCost: $contextCost, currentStoryNode: $currentStoryNode)';
  }
}

// Made with Bob
