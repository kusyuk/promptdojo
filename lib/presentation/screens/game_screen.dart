import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_state_provider.dart';
import '../providers/game_controller.dart';
import '../widgets/hud/mana_bar.dart';
import '../widgets/action_panel/dialogue_box.dart';
import '../widgets/action_panel/choice_button.dart';
import '../widgets/action_panel/prompt_input.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/story_node.dart';
import '../providers/watsonx_health_provider.dart';
import '../widgets/hud/sandbox_warning_banner.dart';

/// Main game screen with three-section layout
///
/// Layout structure:
/// - Top: HUD (mana bar, status indicators)
/// - Center: Stage (backgrounds, characters)
/// - Bottom: Action panel (dialogue, choices, input)
class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final controllerState = ref.watch(gameControllerProvider);
    final watsonxHealth = ref.watch(watsonxHealthProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top HUD Section
            _buildHUD(context, gameState.manaReserves),

            // Health Warning Banner
            watsonxHealth.when(
              data: (isHealthy) => isHealthy
                  ? const SizedBox.shrink()
                  : const SandboxWarningBanner(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SandboxWarningBanner(),
            ),

            // Center Stage Section (Expanded)
            Expanded(child: _buildStage(context)),

            // Bottom Action Panel Section
            _buildActionPanel(context, ref, controllerState),
          ],
        ),
      ),
    );
  }

  /// Build the HUD section with mana bar
  Widget _buildHUD(BuildContext context, int manaReserves) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Game title
          Text(
            'PROMPTDOJO',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),

          // Mana bar
          ManaBar(currentMana: manaReserves),
        ],
      ),
    );
  }

  /// Build the center stage section
  Widget _buildStage(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.backgroundColor,
            AppTheme.backgroundColor.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder for character/background
            Icon(
              Icons.auto_awesome,
              size: 120,
              color: AppTheme.primaryColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'The Architect\'s Awakening',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the action panel section
  Widget _buildActionPanel(
    BuildContext context,
    WidgetRef ref,
    GameControllerState controllerState,
  ) {
    final controller = ref.read(gameControllerProvider.notifier);
    final promptController = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error message
            if (controllerState.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.errorColor),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: AppTheme.errorColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        controllerState.errorMessage!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.errorColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Dialogue box
            if (controllerState.isArchmageBob)
              ArchmageBobDialogue(
                text: controllerState.currentDialogue,
                isTyping: !controllerState.isEvaluating,
              )
            else
              DialogueBox(
                text: controllerState.currentDialogue,
                speaker: 'NARRATOR',
                isTyping: true,
              ),

            const SizedBox(height: 16),

            // Evaluating indicator
            if (controllerState.isEvaluating) const EvaluatingIndicator(),

            // Prompt input
            if (controllerState.showPromptInput) ...[
              PromptInput(controller: promptController, maxLength: 500),
              const SizedBox(height: 16),
              SubmitPromptButton(
                onPressed: () {
                  controller.submitPrompt(promptController.text);
                },
              ),
            ],

            // Forced prompt (tutorial)
            if (controllerState.showForcedPrompt) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.errorColor),
                ),
                child: Column(
                  children: [
                    Text(
                      '"Build me a global trading app."',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppTheme.errorColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ChoiceButton(
                      text: 'Cast Spell (Forced)',
                      icon: Icons.warning,
                      onPressed: () => controller.executeForcedPrompt(),
                    ),
                  ],
                ),
              ),
            ],

            // Choice buttons
            if (controllerState.showChoices)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: List.generate(
                  controllerState.choices.length,
                  (index) => ChoiceButton(
                    text: controllerState.choices[index],
                    onPressed: () {
                      if (ref.read(gameStateProvider).currentStoryNode ==
                          StoryNode.planning) {
                        controller.selectPlanningChoice(index);
                      } else {
                        controller.selectContextChoice(index);
                      }
                    },
                  ),
                ),
              ),

            // Continue button
            if (controllerState.showContinueButton)
              ContinueButton(
                onPressed: () {
                  final currentNode = ref
                      .read(gameStateProvider)
                      .currentStoryNode;

                  if (currentNode == StoryNode.tutorial) {
                    controller.continueTutorial();
                  } else if (currentNode == StoryNode.planning) {
                    controller.startContextPhase();
                  } else if (currentNode == StoryNode.context) {
                    controller.startIncantationPhase();
                  } else if (currentNode == StoryNode.incantation) {
                    controller.showEnding();
                  } else {
                    controller.showBobIntroduction();
                  }
                },
              ),

            // Play again button
            if (controllerState.showPlayAgainButton)
              ChoiceButton(
                text: 'Play Again',
                icon: Icons.replay,
                onPressed: () => controller.playAgain(),
              ),

            // Start game button (initial state)
            if (!controllerState.showContinueButton &&
                !controllerState.showChoices &&
                !controllerState.showPromptInput &&
                !controllerState.showForcedPrompt &&
                !controllerState.showPlayAgainButton)
              ChoiceButton(
                text: 'Begin Your Journey',
                icon: Icons.play_arrow,
                onPressed: () => controller.startGame(),
              ),
          ],
        ),
      ),
    );
  }
}

// Made with Bob
