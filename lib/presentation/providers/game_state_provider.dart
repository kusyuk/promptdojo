import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/story_node.dart';
import '../../core/services/audio_service.dart';

/// Notifier that manages game state and penalty calculations
///
/// This implements the exact penalty formulas from the PRD:
/// 1. Blueprint penalty: -100 mana if hasBlueprint == false
/// 2. Context cost: direct deduction from manaReserves
/// 3. Quality penalty: (10 - score) * 40 * (hasBlueprint ? 1 : 2)
class GameStateNotifier extends StateNotifier<GameState> {
  GameStateNotifier() : super(GameState.initial());

  /// Apply blueprint penalty if player didn't choose to create one
  /// Deducts 100 mana if hasBlueprint is false
  void applyBlueprintPenalty() {
    if (!state.hasBlueprint) {
      final newMana = state.manaReserves - 100;
      state = state.copyWith(manaReserves: newMana);
      AudioService().playSfx('wrong.mp3');
    }
  }

  /// Apply context cost penalty
  /// Directly deducts the context cost from mana reserves
  void applyContextCost(int cost) {
    final newMana = state.manaReserves - cost;
    state = state.copyWith(contextCost: cost, manaReserves: newMana);
    if (cost > 0) {
      AudioService().playSfx('wrong.mp3');
    }
  }

  /// Apply quality penalty based on API score
  /// Formula: (10 - qualityScore) * 40 * multiplier
  /// Multiplier is 2 if no blueprint, 1 if blueprint exists
  void applyQualityPenalty(int qualityScore) {
    // Ensure score is in valid range (1-10)
    final validScore = qualityScore.clamp(1, 10);

    // Calculate multiplier based on blueprint status
    final multiplier = state.hasBlueprint ? 1 : 2;

    // Calculate penalty: (10 - score) * 40 * multiplier
    final penalty = (10 - validScore) * 40 * multiplier;

    // Apply penalty
    final newMana = state.manaReserves - penalty;
    state = state.copyWith(manaReserves: newMana);
    if (penalty > 0) {
      AudioService().playSfx('wrong.mp3');
    }
  }

  /// Set blueprint status
  void setBlueprint(bool value) {
    state = state.copyWith(hasBlueprint: value);
  }

  /// Set context cost (without applying it yet)
  void setContextCost(int cost) {
    state = state.copyWith(contextCost: cost);
  }

  /// Advance to the next story node
  void advanceToNode(StoryNode node) {
    state = state.copyWith(currentStoryNode: node);
  }

  /// Reset game to initial state
  void resetGame() {
    state = GameState.initial();
  }

  /// Reset mana reserves to full (1000) - used after tutorial
  void resetMana() {
    state = state.copyWith(manaReserves: 1000);
  }

  /// Check if game is over (mana depleted)
  bool get isGameOver => state.manaReserves <= 0;

  /// Get the appropriate ending based on mana reserves
  StoryNode get ending {
    return state.manaReserves <= 0 ? StoryNode.badEnding : StoryNode.goodEnding;
  }

  /// Apply all Act 1 tutorial penalties (forced bad prompt)
  /// This deducts 800 mana as specified in the PRD
  void applyTutorialPenalty() {
    const tutorialPenalty = 800;
    final newMana = state.manaReserves - tutorialPenalty;
    state = state.copyWith(manaReserves: newMana);
    AudioService().playSfx('wrong.mp3');
  }

  /// Complete sequence for Act 2 planning phase
  /// Applies blueprint penalty if not chosen
  void completePlanningPhase(bool choseBlueprint) {
    setBlueprint(choseBlueprint);
    applyBlueprintPenalty();
    advanceToNode(StoryNode.context);
  }

  /// Complete sequence for Act 2 context phase
  /// Applies context cost and advances to incantation
  void completeContextPhase(int contextCost) {
    applyContextCost(contextCost);
    advanceToNode(StoryNode.incantation);
  }

  /// Complete sequence for Act 2 incantation phase
  /// Applies quality penalty and determines ending
  void completeIncantationPhase(int qualityScore) {
    applyQualityPenalty(qualityScore);
    advanceToNode(ending);
  }

  /// Complete sequence for Act 2 incantation phase with a fixed penalty
  void completeIncantationPhaseWithFixedPenalty(int penalty) {
    final newMana = state.manaReserves - penalty;
    state = state.copyWith(manaReserves: newMana);
    if (penalty > 0) {
      AudioService().playSfx('wrong.mp3');
    }
    advanceToNode(ending);
  }
}

/// Provider for game state
final gameStateProvider = StateNotifierProvider<GameStateNotifier, GameState>(
  (ref) => GameStateNotifier(),
);

// Made with Bob
