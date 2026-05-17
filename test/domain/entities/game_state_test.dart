import 'package:flutter_test/flutter_test.dart';
import 'package:promptdojo/domain/entities/game_state.dart';
import 'package:promptdojo/domain/entities/story_node.dart';

void main() {
  group('GameState', () {
    test('initial state has correct default values', () {
      final state = GameState.initial();
      
      expect(state.manaReserves, 1000);
      expect(state.hasBlueprint, false);
      expect(state.contextCost, 0);
      expect(state.currentStoryNode, StoryNode.tutorial);
    });
    
    test('copyWith creates new instance with updated values', () {
      final state = GameState.initial();
      final updated = state.copyWith(
        manaReserves: 500,
        hasBlueprint: true,
      );
      
      expect(updated.manaReserves, 500);
      expect(updated.hasBlueprint, true);
      expect(updated.contextCost, 0); // unchanged
      expect(updated.currentStoryNode, StoryNode.tutorial); // unchanged
    });
    
    test('copyWith with no parameters returns identical state', () {
      final state = GameState.initial();
      final copied = state.copyWith();
      
      expect(copied, equals(state));
    });
    
    test('toJson converts state to map correctly', () {
      final state = GameState(
        manaReserves: 750,
        hasBlueprint: true,
        contextCost: 50,
        currentStoryNode: StoryNode.planning,
      );
      
      final json = state.toJson();
      
      expect(json['manaReserves'], 750);
      expect(json['hasBlueprint'], true);
      expect(json['contextCost'], 50);
      expect(json['currentStoryNode'], 'planning');
    });
    
    test('fromJson creates state from map correctly', () {
      final json = {
        'manaReserves': 750,
        'hasBlueprint': true,
        'contextCost': 50,
        'currentStoryNode': 'planning',
      };
      
      final state = GameState.fromJson(json);
      
      expect(state.manaReserves, 750);
      expect(state.hasBlueprint, true);
      expect(state.contextCost, 50);
      expect(state.currentStoryNode, StoryNode.planning);
    });
    
    test('equality works correctly', () {
      final state1 = GameState.initial();
      final state2 = GameState.initial();
      final state3 = state1.copyWith(manaReserves: 500);
      
      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });
    
    test('toString returns readable string', () {
      final state = GameState.initial();
      final str = state.toString();
      
      expect(str, contains('GameState'));
      expect(str, contains('manaReserves: 1000'));
      expect(str, contains('hasBlueprint: false'));
    });
  });
}

// Made with Bob
