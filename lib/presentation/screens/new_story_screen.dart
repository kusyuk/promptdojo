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
import '../../data/repositories/story_repository.dart';
import '../../data/models/story_node_data.dart';
import 'prompt_input_screen.dart';

/// New story screen using the redesigned UX
///
/// Features:
/// - Compact mana bar at top
/// - Large Bob mascot behind dialogue (when Bob speaks)
/// - Dialogue overlay centered
/// - Action buttons at bottom
class StoryScreen extends ConsumerStatefulWidget {
  final StoryNode storyNode;

  const StoryScreen({super.key, required this.storyNode});

  @override
  ConsumerState<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends ConsumerState<StoryScreen> {
  late StoryNodeData? nodeData;

  @override
  void initState() {
    super.initState();
    // Load story data for this node
    nodeData = StoryRepository.getNodeData(widget.storyNode);

    // Initialize game controller if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(gameControllerProvider.notifier);

      // Start game if this is tutorial
      if (widget.storyNode == StoryNode.tutorial) {
        controller.startGame();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final controllerState = ref.watch(gameControllerProvider);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              if (widget.storyNode == StoryNode.tutorial)
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

              // Story content
              Expanded(
                child: StoryLayout(
                  dialogue: controllerState.currentDialogue.isNotEmpty
                      ? controllerState.currentDialogue
                      : (nodeData?.dialogue ?? 'Loading...'),
                  speaker: controllerState.isArchmageBob
                      ? Speaker.archmageBob
                      : Speaker.narrator,
                  showBob: controllerState.isArchmageBob,
                  actionButtons: _buildActionButtons(controllerState),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons(GameControllerState state) {
    final buttons = <Widget>[];

    // Show choices if available
    if (state.showChoices && state.choices.isNotEmpty) {
      for (int i = 0; i < state.choices.length; i++) {
        buttons.add(
          ChoiceButton(
            text: state.choices[i],
            onPressed: () => _handleChoice(i),
          ),
        );
      }
    }
    // Show continue button for reactions, prompt input, or default
    else if (state.showContinueButton ||
        state.showPromptInput ||
        buttons.isEmpty) {
      buttons.add(ContinueButton(onPressed: () => _handleContinue()));
    }

    return buttons;
  }

  void _handleChoice(int index) {
    final controller = ref.read(gameControllerProvider.notifier);
    final currentNode = ref.read(gameStateProvider).currentStoryNode;

    if (currentNode == StoryNode.planning) {
      controller.selectPlanningChoice(index);
    } else if (currentNode == StoryNode.context) {
      controller.selectContextChoice(index);
    }

    // Don't navigate immediately - let the Continue button handle it
    // The controller will show the reaction dialogue with a Continue button
  }

  void _handleContinue() {
    final controller = ref.read(gameControllerProvider.notifier);
    final controllerState = ref.read(gameControllerProvider);
    final currentNode = ref.read(gameStateProvider).currentStoryNode;

    // Check if we're showing a reaction (after a choice was made)
    // Reaction state: showContinueButton=true, showChoices=false, choices is empty
    final isShowingReaction =
        controllerState.showContinueButton &&
        !controllerState.showChoices &&
        controllerState.choices.isEmpty;

    // Check if we're being prompted for input
    final isPromptingInput = controllerState.showPromptInput;

    // Debug logging
    print('🔍 Continue clicked:');
    print('  currentNode: $currentNode');
    print('  isShowingReaction: $isShowingReaction');
    print('  isPromptingInput: $isPromptingInput');
    print('  showContinueButton: ${controllerState.showContinueButton}');
    print('  showChoices: ${controllerState.showChoices}');
    print('  choices.length: ${controllerState.choices.length}');

    if (currentNode == StoryNode.tutorial) {
      // Tutorial: Navigate to forced prompt input
      print('✅ Navigating to tutorial prompt input');
      _navigateToPromptInput(
        instructionText: 'Approach the terminal and cast your first spell.',
        forcedPrompt: 'Build me a global trading app.',
        isTutorial: true,
      );
    } else if (currentNode == StoryNode.context && isShowingReaction) {
      // After planning choice reaction, start context phase
      print('✅ Starting context phase');
      controller.startContextPhase();
    } else if (currentNode == StoryNode.incantation && isShowingReaction) {
      // After context choice reaction, start incantation phase
      print('✅ Starting incantation phase');
      controller.startIncantationPhase();
    } else if (currentNode == StoryNode.incantation && isPromptingInput) {
      // Incantation phase prompting for input: Navigate to prompt input screen
      print('✅ Navigating to incantation prompt input');
      _navigateToPromptInput(
        instructionText:
            'The moment of truth. Type your spell to construct the Authentication Portal.',
        isTutorial: false,
      );
    } else {
      // Default: navigate to next node
      print('✅ Navigating to next node (default)');
      _navigateNext();
    }
  }

  void _navigateNext() {
    final currentNode = ref.read(gameStateProvider).currentStoryNode;
    StoryNode? nextNode;

    switch (currentNode) {
      case StoryNode.tutorial:
        nextNode = StoryNode.planning;
        break;
      case StoryNode.planning:
        nextNode = StoryNode.context;
        break;
      case StoryNode.context:
        nextNode = StoryNode.incantation;
        break;
      case StoryNode.incantation:
        // Check ending
        final mana = ref.read(gameStateProvider).manaReserves;
        nextNode = mana > 0 ? StoryNode.goodEnding : StoryNode.badEnding;
        break;
      default:
        return;
    }

    if (nextNode != null) {
      Navigator.of(
        context,
      ).pushReplacement(FadePageRoute(page: StoryScreen(storyNode: nextNode)));
    }
  }

  void _navigateToPromptInput({
    required String instructionText,
    String? forcedPrompt,
    required bool isTutorial,
  }) {
    Navigator.of(context).pushReplacement(
      FadePageRoute(
        page: PromptInputScreen(
          instructionText: instructionText,
          forcedPrompt: forcedPrompt,
          isTutorial: isTutorial,
        ),
      ),
    );
  }
}

// Made with Bob
