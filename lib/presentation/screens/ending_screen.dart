import 'package:flutter/material.dart';
import "../../core/navigation/fade_page_route.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/layouts/story_layout.dart';
import '../widgets/hud/mana_bar.dart';
import '../widgets/action_panel/choice_button.dart';
import '../widgets/dialogue/dialogue_overlay.dart';
import '../providers/game_state_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/game_state.dart';
import 'title_screen.dart';
import '../../data/repositories/story_repository.dart';

/// Ending screen - Shows good or bad ending
///
/// Features:
/// - Large Bob mascot behind dialogue
/// - Ending narrative
/// - Journey summary
/// - Play Again button
class EndingScreen extends ConsumerWidget {
  final bool isGoodEnding;

  const EndingScreen({super.key, required this.isGoodEnding});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);

    // Get ending dialogue
    final endingDialogue = _buildEndingDialogue(gameState);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              // Final HUD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      Text(
                        'FINAL MANA: ${gameState.manaReserves}/1000',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isGoodEnding
                                  ? AppTheme.accentColor
                                  : AppTheme.errorColor,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ManaBar(
                        currentMana: gameState.manaReserves,
                        maxMana: 1000,
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              Expanded(
                child: StoryLayout(
                  dialogue: endingDialogue,
                  speaker: Speaker.archmageBob,
                  showBob: true,
                  actionButtons: [
                    ChoiceButton(
                      text: 'Play Again',
                      icon: Icons.replay,
                      onPressed: () => _handlePlayAgain(context, ref),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildEndingDialogue(GameState gameState) {
    if (isGoodEnding) {
      return StoryRepository.getGoodEndingStats(
        gameState.manaReserves,
        hasBlueprint: gameState.hasBlueprint,
        contextCost: gameState.contextCost,
      );
    } else {
      return StoryRepository.getBadEndingStats(
        1000 - gameState.manaReserves,
        hasBlueprint: gameState.hasBlueprint,
        contextCost: gameState.contextCost,
      );
    }
  }

  void _handlePlayAgain(BuildContext context, WidgetRef ref) {
    // Reset game state
    ref.read(gameStateProvider.notifier).resetGame();

    // Navigate back to title screen
    Navigator.of(context).pushAndRemoveUntil(
      FadePageRoute(page: const TitleScreen()),
      (route) => false, // Remove all previous routes
    );
  }
}

// Made with Bob
