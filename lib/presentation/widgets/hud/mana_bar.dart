import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Animated mana bar that displays current mana reserves
///
/// Uses TweenAnimationBuilder for smooth depletion animation
/// Shows red flash effect when mana decreases
class ManaBar extends StatefulWidget {
  final int currentMana;
  final int maxMana;
  final Duration animationDuration;

  const ManaBar({
    super.key,
    required this.currentMana,
    this.maxMana = 1000,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  @override
  State<ManaBar> createState() => _ManaBarState();
}

class _ManaBarState extends State<ManaBar> with SingleTickerProviderStateMixin {
  late AnimationController _flashController;
  late Animation<Color?> _flashAnimation;
  int _previousMana = 0;

  @override
  void initState() {
    super.initState();
    _previousMana = widget.currentMana;

    // Flash animation controller
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _flashAnimation =
        ColorTween(
          begin: Colors.transparent,
          end: AppTheme.errorColor.withValues(alpha: 0.3),
        ).animate(
          CurvedAnimation(parent: _flashController, curve: Curves.easeInOut),
        );
  }

  @override
  void didUpdateWidget(ManaBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger flash animation when mana decreases
    if (widget.currentMana < _previousMana) {
      _flashController.forward(from: 0).then((_) {
        _flashController.reverse();
      });
    }

    _previousMana = widget.currentMana;
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (widget.currentMana / widget.maxMana).clamp(0.0, 1.0);
    final manaColor = AppTheme.getManaColor(percentage);

    return AnimatedBuilder(
      animation: _flashAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: _flashAnimation.value,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(2),
          child: child,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mana label and value
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'MANA RESERVES',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  '${widget.currentMana}/${widget.maxMana}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: manaColor,
                  ),
                ),
              ],
            ),
          ),

          // Mana bar
          Container(
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.manaBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.surfaceColor, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: TweenAnimationBuilder<double>(
                duration: widget.animationDuration,
                curve: Curves.easeInOut,
                tween: Tween<double>(begin: percentage, end: percentage),
                builder: (context, value, child) {
                  return Stack(
                    children: [
                      // Filled portion
                      FractionallySizedBox(
                        widthFactor: value,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                manaColor,
                                manaColor.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Shine effect
                      if (value > 0)
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: FractionallySizedBox(
                            widthFactor: value,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.3),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.5],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Warning text for low mana
          if (percentage <= 0.2 && percentage > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 8),
              child: Text(
                '⚠️ CRITICAL MANA LEVELS',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.manaCritical,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          // Depleted text
          if (percentage <= 0)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 8),
              child: Text(
                '💀 MANA DEPLETED',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Made with Bob
