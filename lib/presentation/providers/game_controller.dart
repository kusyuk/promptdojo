import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/story_node.dart';
import '../../data/services/watsonx_service.dart';
import '../../data/repositories/story_repository.dart';
import 'game_state_provider.dart';
import 'watsonx_health_provider.dart';

/// Controller for managing game flow and story progression
class GameController extends StateNotifier<GameControllerState> {
  final Ref ref;
  final WatsonxService _watsonxService = WatsonxService();

  GameController(this.ref) : super(GameControllerState.initial());

  /// Start the game from the beginning
  void startGame() {
    // Reset game state
    ref.read(gameStateProvider.notifier).resetGame();

    // Show tutorial intro
    state = state.copyWith(
      currentDialogue: StoryRepository.tutorialIntro,
      isArchmageBob: false,
      showContinueButton: true,
      showChoices: false,
    );
  }

  /// Continue to forced bad prompt (tutorial)
  void continueTutorial() {
    state = state.copyWith(
      currentDialogue: 'Approach the terminal and cast your first spell.',
      showContinueButton: false,
      showForcedPrompt: true,
    );
  }

  /// Execute the forced bad prompt
  void executeForcedPrompt() {
    // Apply tutorial penalty (800 mana)
    ref.read(gameStateProvider.notifier).applyTutorialPenalty();

    // Show aftermath
    state = state.copyWith(
      currentDialogue: StoryRepository.tutorialAftermath,
      showForcedPrompt: false,
      showContinueButton: true,
    );
  }

  /// Show tutorial result (called after tutorial penalty is applied)
  void showTutorialResult() {
    state = state.copyWith(
      currentDialogue: StoryRepository.tutorialAftermath,
      isArchmageBob: true,
      showContinueButton: true,
      showForcedPrompt: false,
      showPromptInput: false,
    );
  }

  /// Show Archmage Bob introduction
  void showBobIntroduction() {
    state = state.copyWith(
      currentDialogue: StoryRepository.bobIntroduction,
      isArchmageBob: true,
      showContinueButton: true,
    );
  }

  /// Start Act 2: Planning Phase
  void startPlanningPhase() {
    ref.read(gameStateProvider.notifier).advanceToNode(StoryNode.planning);

    state = state.copyWith(
      currentDialogue: StoryRepository.getNodeData(
        StoryNode.planning,
      )!.dialogue,
      isArchmageBob: true,
      showContinueButton: false,
      showChoices: true,
      choices: [
        'The Vibe-Coder: "I don\'t need a plan. Let\'s code!"',
        'The Architect: "Let\'s draft a Master Blueprint (PRD) first."',
      ],
    );
  }

  /// Handle planning phase choice
  void selectPlanningChoice(int index) {
    final choseBlueprint = index == 1;

    // Update state and apply penalty
    ref.read(gameStateProvider.notifier).completePlanningPhase(choseBlueprint);

    // Show reaction
    final reaction = choseBlueprint
        ? StoryRepository.planningArchitect
        : StoryRepository.planningVibeCoder;

    state = state.copyWith(
      currentDialogue: reaction,
      isArchmageBob: true,
      showChoices: false,
      showContinueButton: true,
      choices: [], // Clear choices list for reaction detection
    );
  }

  /// Start context phase
  void startContextPhase() {
    state = state.copyWith(
      currentDialogue: StoryRepository.getNodeData(StoryNode.context)!.dialogue,
      isArchmageBob: true,
      showContinueButton: false,
      showChoices: true,
      choices: [
        'The Data Dumper: "Attach the entire 10,000-file codebase!"',
        'The Precision Caster: "Attach only auth schemas and UI style guide."',
        'The Amnesiac: "Attach nothing. It should just know."',
      ],
    );
  }

  /// Handle context phase choice
  void selectContextChoice(int index) {
    // Map choice to context cost
    final contextCosts = [150, 10, 50];
    final contextCost = contextCosts[index];

    // Apply context cost
    ref.read(gameStateProvider.notifier).completeContextPhase(contextCost);

    // Show reaction
    final reactions = [
      StoryRepository.contextDataDumper,
      StoryRepository.contextPrecision,
      StoryRepository.contextAmnesiac,
    ];

    state = state.copyWith(
      currentDialogue: reactions[index],
      isArchmageBob: true,
      showChoices: false,
      showContinueButton: true,
      choices: [], // Clear choices list for reaction detection
    );
  }

  /// Start incantation phase
  void startIncantationPhase() {
    state = state.copyWith(
      currentDialogue: StoryRepository.incantationPrompt,
      isArchmageBob: true,
      showContinueButton: false,
      showPromptInput: true,
    );
  }

  /// Submit user prompt for evaluation
  Future<void> submitPrompt(String userPrompt) async {
    if (userPrompt.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Your incantation cannot be empty!');
      return;
    }

    // Show loading state
    state = state.copyWith(
      isEvaluating: true,
      showPromptInput: false,
      currentDialogue: StoryRepository.evaluatingMessage,
      errorMessage: null,
    );

    try {
      // Call watsonx.ai API
      final evaluation = await _watsonxService.evaluatePrompt(userPrompt);

      // Apply quality penalty and determine ending
      ref
          .read(gameStateProvider.notifier)
          .completeIncantationPhase(evaluation.qualityScore);

      // Show Archmage feedback
      state = state.copyWith(
        isEvaluating: false,
        currentDialogue: evaluation.archmageFeedback,
        isArchmageBob: true,
        showContinueButton: true,
      );
    } catch (e) {
      // Trigger warning banner
      ref.read(watsonxHealthProvider.notifier).setUnhealthy();

      // Fallback algorithm so player is not blocked
      int fallbackScore = 5;
      String feedback =
          "*The arcane network is severed! I must evaluate this manually...* \n\n";

      final promptLower = userPrompt.toLowerCase();
      bool isBrief = false;
      if (promptLower.length > 50) {
        fallbackScore += 2;
        feedback += "Your incantation has good detail. ";
      } else {
        feedback += "Your incantation is quite brief. ";
        isBrief = true;
      }

      if (promptLower.contains("system") ||
          promptLower.contains("role") ||
          promptLower.contains("act as") ||
          promptLower.contains("you are")) {
        fallbackScore += 2;
        feedback += "You understand the power of assigning a role. ";
      }

      if (promptLower.contains("json") || promptLower.contains("format")) {
        fallbackScore += 1;
        feedback += "You specified an output format, wise choice. ";
      }

      if (fallbackScore > 10) fallbackScore = 10;

      // Apply quality penalty and determine ending
      if (isBrief) {
        ref
            .read(gameStateProvider.notifier)
            .completeIncantationPhaseWithFixedPenalty(800);
      } else {
        ref
            .read(gameStateProvider.notifier)
            .completeIncantationPhase(fallbackScore);
      }

      // Show Archmage feedback
      state = state.copyWith(
        isEvaluating: false,
        currentDialogue: feedback,
        isArchmageBob: true,
        showContinueButton: true,
        errorMessage: null,
      );
    }
  }

  /// Show the appropriate ending
  void showEnding() {
    final gameState = ref.read(gameStateProvider);
    final isBadEnding = gameState.manaReserves <= 0;

    final dialogue = isBadEnding
        ? StoryRepository.getBadEndingStats(
            1000 - gameState.manaReserves,
            hasBlueprint: gameState.hasBlueprint,
            contextCost: gameState.contextCost,
          )
        : StoryRepository.getGoodEndingStats(
            gameState.manaReserves,
            hasBlueprint: gameState.hasBlueprint,
            contextCost: gameState.contextCost,
          );

    state = state.copyWith(
      currentDialogue: dialogue,
      isArchmageBob: true,
      showContinueButton: false,
      showPlayAgainButton: true,
    );
  }

  /// Reset and play again
  void playAgain() {
    startGame();
  }
}

/// State for game controller
class GameControllerState {
  final String currentDialogue;
  final bool isArchmageBob;
  final bool showContinueButton;
  final bool showChoices;
  final List<String> choices;
  final bool showPromptInput;
  final bool showForcedPrompt;
  final bool isEvaluating;
  final bool showPlayAgainButton;
  final String? errorMessage;

  const GameControllerState({
    required this.currentDialogue,
    required this.isArchmageBob,
    required this.showContinueButton,
    required this.showChoices,
    required this.choices,
    required this.showPromptInput,
    required this.showForcedPrompt,
    required this.isEvaluating,
    required this.showPlayAgainButton,
    this.errorMessage,
  });

  factory GameControllerState.initial() {
    return const GameControllerState(
      currentDialogue: 'Welcome to PromptDojo: The Architect\'s Awakening',
      isArchmageBob: false,
      showContinueButton: false,
      showChoices: false,
      choices: [],
      showPromptInput: false,
      showForcedPrompt: false,
      isEvaluating: false,
      showPlayAgainButton: false,
    );
  }

  GameControllerState copyWith({
    String? currentDialogue,
    bool? isArchmageBob,
    bool? showContinueButton,
    bool? showChoices,
    List<String>? choices,
    bool? showPromptInput,
    bool? showForcedPrompt,
    bool? isEvaluating,
    bool? showPlayAgainButton,
    String? errorMessage,
  }) {
    return GameControllerState(
      currentDialogue: currentDialogue ?? this.currentDialogue,
      isArchmageBob: isArchmageBob ?? this.isArchmageBob,
      showContinueButton: showContinueButton ?? this.showContinueButton,
      showChoices: showChoices ?? this.showChoices,
      choices: choices ?? this.choices,
      showPromptInput: showPromptInput ?? this.showPromptInput,
      showForcedPrompt: showForcedPrompt ?? this.showForcedPrompt,
      isEvaluating: isEvaluating ?? this.isEvaluating,
      showPlayAgainButton: showPlayAgainButton ?? this.showPlayAgainButton,
      errorMessage: errorMessage,
    );
  }
}

/// Provider for game controller
final gameControllerProvider =
    StateNotifierProvider<GameController, GameControllerState>(
      (ref) => GameController(ref),
    );

// Made with Bob
