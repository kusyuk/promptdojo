import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promptdojo/domain/entities/story_node.dart';
import 'package:promptdojo/presentation/providers/game_state_provider.dart';

void main() {
  group('GameStateNotifier', () {
    late ProviderContainer container;
    
    setUp(() {
      container = ProviderContainer();
    });
    
    tearDown(() {
      container.dispose();
    });
    
    test('initial state is correct', () {
      final state = container.read(gameStateProvider);
      
      expect(state.manaReserves, 1000);
      expect(state.hasBlueprint, false);
      expect(state.contextCost, 0);
      expect(state.currentStoryNode, StoryNode.tutorial);
    });
    
    group('Blueprint Penalty', () {
      test('applies -100 mana when hasBlueprint is false', () {
        final notifier = container.read(gameStateProvider.notifier);
        
        notifier.applyBlueprintPenalty();
        final state = container.read(gameStateProvider);
        
        expect(state.manaReserves, 900); // 1000 - 100
      });
      
      test('does not apply penalty when hasBlueprint is true', () {
        final notifier = container.read(gameStateProvider.notifier);
        
        notifier.setBlueprint(true);
        notifier.applyBlueprintPenalty();
        final state = container.read(gameStateProvider);
        
        expect(state.manaReserves, 1000); // no penalty
      });
    });
    
    group('Context Cost', () {
      test('applies context cost correctly', () {
        final notifier = container.read(gameStateProvider.notifier);
        
        notifier.applyContextCost(150);
        final state = container.read(gameStateProvider);
        
        expect(state.manaReserves, 850); // 1000 - 150
        expect(state.contextCost, 150);
      });
      
      test('applies minimal context cost', () {
        final notifier = container.read(gameStateProvider.notifier);
        
        notifier.applyContextCost(10);
        final state = container.read(gameStateProvider);
        
        expect(state.manaReserves, 990); // 1000 - 10
        expect(state.contextCost, 10);
      });
      
      test('applies medium context cost', () {
        final notifier = container.read(gameStateProvider.notifier);
        
        notifier.applyContextCost(50);
        final state = container.read(gameStateProvider);
        
        expect(state.manaReserves, 950); // 1000 - 50
        expect(state.contextCost, 50);
      });
    });
    
    group('Quality Penalty Formula', () {
      test('calculates penalty with blueprint (multiplier = 1)', () {
        final notifier = container.read(gameStateProvider.notifier);
        
        notifier.setBlueprint(true);
        
        // Test with score = 5
        // Formula: (10 - 5) * 40 * 1 = 200
        notifier.applyQualityPenalty(5);
        final state = container.read(gameStateProvider);
        
        expect(state.manaReserves, 800); // 1000 - 200
      });
      
      test('calculates penalty without blueprint (multiplier = 2)', () {
        final notifier = container.read(gameStateProvider.notifier);
        
        // hasBlueprint is false by default
        // Test with score = 5
        // Formula: (10 - 5) * 40 * 2 = 400
        notifier.applyQualityPenalty(5);
        final state = container.read(gameStateProvider);
        
        expect(state.manaReserves, 600); // 1000 - 400
      });
      
      test('worst score (1) with blueprint', () {
        final notifier = container.read(gameStateProvider.notifier);
        
        notifier.setBlueprint(true);
        // Formula: (10 - 1) * 40 * 1 = 360
        notifier.applyQualityPenalty(1);
        final state = container.read(gameStateProvider);
        
        expect(state.manaReserves, 640); // 1000 - 360
      });
      
      test('worst score (1) without blueprint', () {
        final notifier = container.read(gameStateProvider.notifier);
        
        // Formula: (10 - 1) * 40 * 2 = 720
        notifier.applyQualityPenalty(1);
        final state = container.read(gameStateProvider);
        
        expect(state.manaReserves, 280); // 1000 - 720
      });
      
      test('best score (10) with blueprint', () {
        final notifier = container.read(gameStateProvider.notifier);
        
        notifier.setBlueprint(true);
        // Formula: (10 - 10) * 40 * 1 = 0
        notifier.applyQualityPenalty(10);
        final state = container.read(gameStateProvider);
        
        expect(state.manaReserves, 1000); // no penalty
      });
      
      test('best score (10) without blueprint', () {
        final notifier = container.read(gameStateProvider.notifier);
        
        // Formula: (10 - 10) * 40 * 2 = 0
        notifier.applyQualityPenalty(10);
        final state = container.read(gameStateProvider);
        
        expect(state.manaReserves, 1000); // no penalty
      });
      
      test('mid score (7) with blueprint', () {
        final notifier = container.read(gameStateProvider.notifier);
        
        notifier.setBlueprint(true);
        // Formula: (10 - 7) * 40 * 1 = 120
        notifier.applyQualityPenalty(7);
        final state = container.read(gameStateProvider);
        
        expect(state.manaReserves, 880); // 1000 - 120
      });
      
      test('mid score (7) without blueprint', () {
        final notifier = container.read(gameStateProvider.notifier);
        
        // Formula: (10 - 7) * 40 * 2 = 240
        notifier.applyQualityPenalty(7);
        final state = container.read(gameStateProvider);
        
        expect(state.manaReserves, 760); // 1000 - 240
      });
    });
    
    group('Tutorial Penalty', () {
      test('applies 800 mana penalty', () {
        final notifier = container.read(gameStateProvider.notifier);
        
        notifier.applyTutorialPenalty();
        final state = container.read(gameStateProvider);
        
        expect(state.manaReserves, 200); // 1000 - 800
      });
    });
    
    group('State Transitions', () {
      test('advances to next story node', () {
        final notifier = container.read(gameStateProvider.notifier);
        
        notifier.advanceToNode(StoryNode.planning);
        final state = container.read(gameStateProvider);
        
        expect(state.currentStoryNode, StoryNode.planning);
      });
      
      test('setBlueprint updates blueprint status', () {
        final notifier = container.read(gameStateProvider.notifier);
        
        notifier.setBlueprint(true);
        final state = container.read(gameStateProvider);
        
        expect(state.hasBlueprint, true);
      });
    });
    
    group('Game Over Logic', () {
      test('isGameOver returns true when mana is 0', () {
        final notifier = container.read(gameStateProvider.notifier);
        
        // Deplete all mana
        notifier.applyContextCost(1000);
        
        expect(notifier.isGameOver, true);
      });
      
      test('isGameOver returns true when mana is negative', () {
        final notifier = container.read(gameStateProvider.notifier);
        
        // Deplete more than available mana
        notifier.applyContextCost(1200);
        
        expect(notifier.isGameOver, true);
      });
      
      test('isGameOver returns false when mana is positive', () {
        final notifier = container.read(gameStateProvider.notifier);
        
        notifier.applyContextCost(500);
        
        expect(notifier.isGameOver, false);
      });
      
      test('ending returns badEnding when mana <= 0', () {
        final notifier = container.read(gameStateProvider.notifier);
        
        notifier.applyContextCost(1000);
        
        expect(notifier.ending, StoryNode.badEnding);
      });
      
      test('ending returns goodEnding when mana > 0', () {
        final notifier = container.read(gameStateProvider.notifier);
        
        notifier.applyContextCost(500);
        
        expect(notifier.ending, StoryNode.goodEnding);
      });
    });
    
    group('Phase Completion Sequences', () {
      test('completePlanningPhase with blueprint chosen', () {
        final notifier = container.read(gameStateProvider.notifier);
        
        notifier.completePlanningPhase(true);
        final state = container.read(gameStateProvider);
        
        expect(state.hasBlueprint, true);
        expect(state.manaReserves, 1000); // no penalty
        expect(state.currentStoryNode, StoryNode.context);
      });
      
      test('completePlanningPhase without blueprint', () {
        final notifier = container.read(gameStateProvider.notifier);
        
        notifier.completePlanningPhase(false);
        final state = container.read(gameStateProvider);
        
        expect(state.hasBlueprint, false);
        expect(state.manaReserves, 900); // -100 penalty
        expect(state.currentStoryNode, StoryNode.context);
      });
      
      test('completeContextPhase applies cost and advances', () {
        final notifier = container.read(gameStateProvider.notifier);
        
        notifier.completeContextPhase(150);
        final state = container.read(gameStateProvider);
        
        expect(state.contextCost, 150);
        expect(state.manaReserves, 850);
        expect(state.currentStoryNode, StoryNode.incantation);
      });
      
      test('completeIncantationPhase with good score', () {
        final notifier = container.read(gameStateProvider.notifier);
        
        notifier.setBlueprint(true);
        notifier.completeIncantationPhase(9);
        final state = container.read(gameStateProvider);
        
        // Penalty: (10 - 9) * 40 * 1 = 40
        expect(state.manaReserves, 960);
        expect(state.currentStoryNode, StoryNode.goodEnding);
      });
      
      test('completeIncantationPhase with bad score leads to bad ending', () {
        final notifier = container.read(gameStateProvider.notifier);
        
        // Start with depleted mana
        notifier.applyContextCost(900);
        notifier.completeIncantationPhase(1);
        final state = container.read(gameStateProvider);
        
        expect(state.currentStoryNode, StoryNode.badEnding);
      });
    });
    
    group('Reset Game', () {
      test('resetGame returns to initial state', () {
        final notifier = container.read(gameStateProvider.notifier);
        
        // Make some changes
        notifier.setBlueprint(true);
        notifier.applyContextCost(500);
        notifier.advanceToNode(StoryNode.incantation);
        
        // Reset
        notifier.resetGame();
        final state = container.read(gameStateProvider);
        
        expect(state.manaReserves, 1000);
        expect(state.hasBlueprint, false);
        expect(state.contextCost, 0);
        expect(state.currentStoryNode, StoryNode.tutorial);
      });
    });
    
    group('Edge Cases', () {
      test('mana can go negative', () {
        final notifier = container.read(gameStateProvider.notifier);
        
        notifier.applyContextCost(1200);
        final state = container.read(gameStateProvider);
        
        expect(state.manaReserves, -200);
      });
      
      test('quality score is clamped to valid range', () {
        final notifier = container.read(gameStateProvider.notifier);
        
        // Score above 10 should be treated as 10
        notifier.applyQualityPenalty(15);
        final state = container.read(gameStateProvider);
        
        expect(state.manaReserves, 1000); // no penalty for score 10
      });
    });
  });
}

// Made with Bob
