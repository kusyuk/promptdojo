import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../../core/theme/app_theme.dart';

/// Dialogue box with typewriter effect for narrative text
///
/// Uses animated_text_kit for letter-by-letter animation
/// Mimics classic RPG/visual novel dialogue presentation
class DialogueBox extends StatelessWidget {
  final String text;
  final String? speaker;
  final VoidCallback? onComplete;
  final bool isTyping;

  const DialogueBox({
    super.key,
    required this.text,
    this.speaker,
    this.onComplete,
    this.isTyping = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Speaker name
          if (speaker != null) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    speaker!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Dialogue text with typewriter effect
          if (isTyping)
            AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  text,
                  textStyle: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(height: 1.5),
                  speed: const Duration(milliseconds: 50),
                ),
              ],
              totalRepeatCount: 1,
              displayFullTextOnTap: true,
              stopPauseOnTap: true,
              pause: Duration.zero,
              onFinished: onComplete,
            )
          else
            Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
        ],
      ),
    );
  }
}

/// Dialogue box variant for Archmage Bob with special styling
class ArchmageBobDialogue extends StatelessWidget {
  final String text;
  final VoidCallback? onComplete;
  final bool isTyping;

  const ArchmageBobDialogue({
    super.key,
    required this.text,
    this.onComplete,
    this.isTyping = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.2),
            AppTheme.secondaryColor.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Archmage Bob header
          Row(
            children: [
              // Magic icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'ARCHMAGE BOB',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Dialogue text with typewriter effect
          if (isTyping)
            AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  text,
                  textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                  speed: const Duration(milliseconds: 50),
                ),
              ],
              totalRepeatCount: 1,
              displayFullTextOnTap: true,
              stopPauseOnTap: true,
              pause: Duration.zero,
              onFinished: onComplete,
            )
          else
            Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
}

// Made with Bob
