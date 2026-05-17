import 'package:flutter/material.dart';
import "../../core/navigation/fade_page_route.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/layouts/story_layout.dart';
import '../widgets/hud/mana_bar.dart';
import '../widgets/hud/tutorial_indicator.dart';
import '../widgets/action_panel/choice_button.dart';
import '../widgets/dialogue/dialogue_overlay.dart';
import '../providers/game_controller.dart';
import '../providers/game_state_provider.dart';
import '../../domain/entities/story_node.dart';
import 'act_transition_screen.dart';

/// Result screen - Shows evaluation feedback from Archmage Bob
///
/// Features:
/// - Large Bob mascot behind dialogue
/// - Animated mana bar change
/// - Quality score and feedback
/// - Continue button to next phase
class ResultScreen extends ConsumerWidget {
  final bool isTutorial;

  const ResultScreen({super.key, this.isTutorial = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final controllerState = ref.watch(gameControllerProvider);

    // Build feedback dialogue
    final feedbackText = _buildFeedbackText(controllerState);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              if (isTutorial)
                const SafeArea(bottom: false, child: TutorialIndicator()),

              // Animated HUD showing mana change
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
                child: StoryLayout(
                  dialogue: feedbackText,
                  speaker: Speaker.archmageBob,
                  showBob: true,
                  actionButtons: [
                    ContinueButton(
                      onPressed: () => _handleContinue(context, ref),
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

  String _buildFeedbackText(GameControllerState state) {
    // Get the last evaluation result
    final feedback = state.currentDialogue.isNotEmpty
        ? state.currentDialogue
        : 'Your spell has been evaluated.';

    return feedback;
  }

  void _handleContinue(BuildContext context, WidgetRef ref) {
    final gameState = ref.read(gameStateProvider);

    // Determine next screen based on current phase
    if (isTutorial) {
      // After tutorial, reset mana to give player a fresh start for Act 2
      ref.read(gameStateProvider.notifier).resetMana();

      // Start planning phase (this sets up controller state)
      ref.read(gameControllerProvider.notifier).startPlanningPhase();

      Navigator.of(context).pushReplacement(
        FadePageRoute(
          page: const ActTransitionScreen(storyNode: StoryNode.planning),
        ),
      );
    } else {
      final endNode = gameState.manaReserves <= 0
          ? StoryNode.badEnding
          : StoryNode.goodEnding;

      Navigator.of(context).pushReplacement(
        FadePageRoute(page: ActTransitionScreen(storyNode: endNode)),
      );
    }
  }
}

// Made with Bob
