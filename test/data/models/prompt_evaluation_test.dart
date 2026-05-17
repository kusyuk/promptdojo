import 'package:flutter_test/flutter_test.dart';
import 'package:promptdojo/data/models/prompt_evaluation.dart';

void main() {
  group('PromptEvaluation', () {
    test('fromJson creates valid evaluation', () {
      final json = {
        'quality_score': 8,
        'archmage_feedback': 'Excellent craftsmanship! Your spell is well-formed.',
      };
      
      final evaluation = PromptEvaluation.fromJson(json);
      
      expect(evaluation.qualityScore, 8);
      expect(evaluation.archmageFeedback, 'Excellent craftsmanship! Your spell is well-formed.');
    });
    
    test('fromJson validates score range - too low', () {
      final json = {
        'quality_score': 0,
        'archmage_feedback': 'Test feedback',
      };
      
      expect(
        () => PromptEvaluation.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });
    
    test('fromJson validates score range - too high', () {
      final json = {
        'quality_score': 11,
        'archmage_feedback': 'Test feedback',
      };
      
      expect(
        () => PromptEvaluation.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });
    
    test('fromJson validates score is integer', () {
      final json = {
        'quality_score': 'not a number',
        'archmage_feedback': 'Test feedback',
      };
      
      expect(
        () => PromptEvaluation.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });
    
    test('fromJson validates feedback is non-empty string', () {
      final json = {
        'quality_score': 5,
        'archmage_feedback': '',
      };
      
      expect(
        () => PromptEvaluation.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });
    
    test('fromJson validates feedback is string', () {
      final json = {
        'quality_score': 5,
        'archmage_feedback': 123,
      };
      
      expect(
        () => PromptEvaluation.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });
    
    test('toJson converts to map correctly', () {
      final evaluation = PromptEvaluation(
        qualityScore: 7,
        archmageFeedback: 'Good work, apprentice!',
      );
      
      final json = evaluation.toJson();
      
      expect(json['quality_score'], 7);
      expect(json['archmage_feedback'], 'Good work, apprentice!');
    });
    
    test('equality works correctly', () {
      final eval1 = PromptEvaluation(
        qualityScore: 8,
        archmageFeedback: 'Test',
      );
      final eval2 = PromptEvaluation(
        qualityScore: 8,
        archmageFeedback: 'Test',
      );
      final eval3 = PromptEvaluation(
        qualityScore: 7,
        archmageFeedback: 'Test',
      );
      
      expect(eval1, equals(eval2));
      expect(eval1, isNot(equals(eval3)));
    });
    
    test('toString returns readable string', () {
      final evaluation = PromptEvaluation(
        qualityScore: 9,
        archmageFeedback: 'Masterful!',
      );
      
      final str = evaluation.toString();
      
      expect(str, contains('PromptEvaluation'));
      expect(str, contains('qualityScore: 9'));
      expect(str, contains('Masterful!'));
    });
    
    test('accepts minimum valid score (1)', () {
      final json = {
        'quality_score': 1,
        'archmage_feedback': 'Terrible spell!',
      };
      
      final evaluation = PromptEvaluation.fromJson(json);
      expect(evaluation.qualityScore, 1);
    });
    
    test('accepts maximum valid score (10)', () {
      final json = {
        'quality_score': 10,
        'archmage_feedback': 'Perfect incantation!',
      };
      
      final evaluation = PromptEvaluation.fromJson(json);
      expect(evaluation.qualityScore, 10);
    });
  });
}

// Made with Bob
