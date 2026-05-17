import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Multiline text input for user prompts
///
/// Features character counter and validation
class PromptInput extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final int? maxLength;
  final ValueChanged<String>? onChanged;

  const PromptInput({
    super.key,
    required this.controller,
    this.hintText,
    this.maxLength,
    this.onChanged,
  });

  @override
  State<PromptInput> createState() => _PromptInputState();
}

class _PromptInputState extends State<PromptInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.edit_note,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'THE SCRYING TERMINAL',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          // Text input
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: widget.controller,
              onChanged: widget.onChanged,
              maxLines: 6,
              maxLength: widget.maxLength,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText:
                    widget.hintText ??
                    'Type your incantation here...\n\n'
                        'Be specific. Define your tech stack. '
                        'Provide context. The artifact awaits your command.',
                hintStyle: TextStyle(
                  color: AppTheme.textMuted,
                  fontStyle: FontStyle.italic,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                counterStyle: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.textMuted),
              ),
            ),
          ),

          // Tips section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppTheme.accentColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tip: Include role, tech stack, constraints, and context for best results',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading indicator for API calls
class EvaluatingIndicator extends StatelessWidget {
  const EvaluatingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Archmage Bob is evaluating your spell...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'This may take a few moments',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}

// Made with Bob
