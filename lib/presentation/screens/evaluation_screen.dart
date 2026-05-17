import 'package:flutter/material.dart';
import "../../core/navigation/fade_page_route.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/characters/bob_mascot.dart';
import '../widgets/hud/mana_bar.dart';
import '../widgets/hud/tutorial_indicator.dart';
import '../providers/game_controller.dart';
import '../providers/game_state_provider.dart';
import '../../core/theme/app_theme.dart';
import 'result_screen.dart';

/// Evaluation screen - Shows loading state during API call
///
/// Features:
/// - Bob mascot with glow animation
/// - Loading spinner
/// - "Evaluating..." message
/// - Automatically navigates to result screen when done
class EvaluationScreen extends ConsumerStatefulWidget {
  final String prompt;
  final bool isTutorial;

  const EvaluationScreen({
    super.key,
    required this.prompt,
    this.isTutorial = false,
  });

  @override
  ConsumerState<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends ConsumerState<EvaluationScreen> {
  @override
  void initState() {
    super.initState();

    // Start evaluation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _evaluatePrompt();
    });
  }

  Future<void> _evaluatePrompt() async {
    final controller = ref.read(gameControllerProvider.notifier);

    try {
      // Submit prompt for evaluation
      await controller.submitPrompt(widget.prompt);

      // Wait a moment for dramatic effect
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate to result screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          FadePageRoute(page: ResultScreen(isTutorial: widget.isTutorial)),
        );
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error evaluating prompt: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        // Go back to input screen
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              if (widget.isTutorial)
                const SafeArea(bottom: false, child: TutorialIndicator()),

              // Compact HUD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                ),
                child: SafeArea(
                  bottom: false,
                  child: ManaBar(
                    currentMana: gameState.manaReserves,
                    maxMana: 1000,
                  ),
                ),
              ),

              // Content
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.backgroundColor,
                        AppTheme.primaryColor.withValues(alpha: 0.2),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Bob mascot with glow
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Glow effect
                              Container(
                                width: 300,
                                height: 300,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryColor.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 100,
                                      spreadRadius: 50,
                                    ),
                                  ],
                                ),
                              ),

                              // Bob
                              const BobMascot(size: BobSize.medium),
                            ],
                          ),

                          const SizedBox(height: 48),

                          // Loading spinner
                          const SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryColor,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Status text
                          Text(
                            'Archmage Bob is evaluating your spell...',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: AppTheme.textSecondary,
                                ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 12),

                          Text(
                            'This may take a few moments',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Made with Bob
