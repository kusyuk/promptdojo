import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// A premium visual indicator showing that the player is in Tutorial mode
class TutorialIndicator extends StatelessWidget {
  const TutorialIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppTheme.accentColor.withValues(alpha: 0.15),
            AppTheme.accentColor.withValues(alpha: 0.02),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.accentColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, color: AppTheme.accentColor, size: 16),
          const SizedBox(width: 8),
          Text(
            'ACT I: THE ACCIDENTAL CASTING • TUTORIAL MODE',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.accentColor,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.offline_bolt_outlined,
            color: AppTheme.accentColor,
            size: 16,
          ),
        ],
      ),
    );
  }
}
