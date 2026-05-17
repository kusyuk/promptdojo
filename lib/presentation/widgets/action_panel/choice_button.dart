import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Interactive choice button for story decisions
///
/// Features hover effects and disabled state
class ChoiceButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final IconData? icon;

  const ChoiceButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isEnabled = true,
    this.icon,
  });

  @override
  State<ChoiceButton> createState() => _ChoiceButtonState();
}

class _ChoiceButtonState extends State<ChoiceButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered && widget.isEnabled ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            gradient: widget.isEnabled
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _isHovered
                        ? [AppTheme.primaryColor, AppTheme.secondaryColor]
                        : [
                            AppTheme.primaryColor.withValues(alpha: 0.8),
                            AppTheme.secondaryColor.withValues(alpha: 0.8),
                          ],
                  )
                : null,
            color: widget.isEnabled ? null : AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isEnabled
                  ? (_isHovered
                        ? Colors.white.withValues(alpha: 0.5)
                        : Colors.transparent)
                  : AppTheme.textMuted,
              width: 2,
            ),
            boxShadow: widget.isEnabled && _isHovered
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isEnabled ? widget.onPressed : null,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: widget.isEnabled
                            ? Colors.white
                            : AppTheme.textMuted,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Flexible(
                      child: Text(
                        widget.text,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: widget.isEnabled
                              ? Colors.white
                              : AppTheme.textMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Continue button variant for advancing story
class ContinueButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isEnabled;

  const ContinueButton({
    super.key,
    required this.onPressed,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceButton(
      text: 'Continue',
      icon: Icons.arrow_forward,
      onPressed: onPressed,
      isEnabled: isEnabled,
    );
  }
}

/// Submit button for prompt input
class SubmitPromptButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const SubmitPromptButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceButton(
      text: isLoading ? 'Evaluating...' : 'Cast Spell',
      icon: isLoading ? null : Icons.auto_awesome,
      onPressed: isLoading ? null : onPressed,
      isEnabled: !isLoading,
    );
  }
}

// Made with Bob
