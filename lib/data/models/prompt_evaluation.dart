/// Model for prompt evaluation response from watsonx.ai
///
/// Contains the quality score (1-10) and Archmage Bob's feedback
class PromptEvaluation {
  /// Quality score from 1 (worst) to 10 (best)
  final int qualityScore;

  /// Feedback from Archmage Bob in character
  final String archmageFeedback;

  const PromptEvaluation({
    required this.qualityScore,
    required this.archmageFeedback,
  });

  /// Create from JSON response
  factory PromptEvaluation.fromJson(Map<String, dynamic> json) {
    final score = json['quality_score'];

    // Validate score is in valid range
    if (score is! int || score < 1 || score > 10) {
      throw FormatException(
        'Invalid quality_score: $score. Must be integer between 1 and 10.',
      );
    }

    final feedback = json['archmage_feedback'];
    if (feedback is! String || feedback.isEmpty) {
      throw FormatException(
        'Invalid archmage_feedback: must be non-empty string.',
      );
    }

    return PromptEvaluation(qualityScore: score, archmageFeedback: feedback);
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'quality_score': qualityScore,
      'archmage_feedback': archmageFeedback,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PromptEvaluation &&
        other.qualityScore == qualityScore &&
        other.archmageFeedback == archmageFeedback;
  }

  @override
  int get hashCode => Object.hash(qualityScore, archmageFeedback);

  @override
  String toString() {
    return 'PromptEvaluation(qualityScore: $qualityScore, '
        'archmageFeedback: $archmageFeedback)';
  }
}

// Made with Bob
