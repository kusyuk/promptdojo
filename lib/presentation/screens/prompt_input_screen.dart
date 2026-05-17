import 'package:flutter/material.dart';
import "../../core/navigation/fade_page_route.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/hud/mana_bar.dart';
import '../widgets/hud/tutorial_indicator.dart';
import '../widgets/action_panel/choice_button.dart';
import '../providers/game_state_provider.dart';
import '../providers/game_controller.dart';
import '../../core/theme/app_theme.dart';
import 'evaluation_screen.dart';
import 'result_screen.dart';

/// Screen for user prompt input
///
/// Features:
/// - Large text input area
/// - Character counter
/// - Tips section
/// - "Cast Spell" button
/// - No Bob mascot (focus on input)
class PromptInputScreen extends ConsumerStatefulWidget {
  final String instructionText;
  final String? forcedPrompt;
  final bool isTutorial;

  const PromptInputScreen({
    super.key,
    required this.instructionText,
    this.forcedPrompt,
    this.isTutorial = false,
  });

  @override
  ConsumerState<PromptInputScreen> createState() => _PromptInputScreenState();
}

class _PromptInputScreenState extends ConsumerState<PromptInputScreen> {
  late TextEditingController _promptController;

  @override
  void initState() {
    super.initState();
    _promptController = TextEditingController(text: widget.forcedPrompt ?? '');
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
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
                        AppTheme.backgroundColor.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),

                          // Instruction text
                          Text(
                            widget.instructionText,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 32),

                          // Input container
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.3,
                                ),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withValues(
                                      alpha: 0.1,
                                    ),
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
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
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
                                    controller: _promptController,
                                    maxLines: 8,
                                    maxLength: 500,
                                    enabled: widget.forcedPrompt == null,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                    decoration: InputDecoration(
                                      hintText: widget.forcedPrompt == null
                                          ? 'Type your incantation here...\n\n'
                                                'Be specific. Define your tech stack. '
                                                'Provide context. The artifact awaits your command.'
                                          : null,
                                      hintStyle: TextStyle(
                                        color: AppTheme.textMuted,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                      counterStyle: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: AppTheme.textMuted),
                                    ),
                                  ),
                                ),

                                // Tips section
                                if (widget.forcedPrompt == null)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.backgroundColor
                                          .withValues(alpha: 0.5),
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.lightbulb_outline,
                                          color: AppTheme.accentColor,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Tip: Include role, tech stack, constraints, and context for best results',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: AppTheme.textSecondary,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Cast Spell button
                          ChoiceButton(
                            text: widget.forcedPrompt != null
                                ? 'Cast Spell (Forced)'
                                : 'Cast Spell',
                            icon: widget.forcedPrompt != null
                                ? Icons.warning
                                : Icons.auto_fix_high,
                            onPressed: () => _handleSubmit(),
                          ),

                          const SizedBox(height: 20),
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

  void _handleSubmit() {
    final prompt = _promptController.text.trim();

    if (prompt.isEmpty && widget.forcedPrompt == null) {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a prompt before casting your spell!'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // For tutorial, skip API call and simulate bad outcome directly
    if (widget.isTutorial) {
      // Apply tutorial penalty immediately (800 mana)
      ref.read(gameStateProvider.notifier).applyTutorialPenalty();

      // Update game controller state with tutorial aftermath feedback
      ref.read(gameControllerProvider.notifier).showTutorialResult();

      // Navigate directly to result screen
      Navigator.of(context).pushReplacement(
        FadePageRoute(page: const ResultScreen(isTutorial: true)),
      );
    } else {
      // Normal flow: Navigate to evaluation screen for API call
      Navigator.of(context).pushReplacement(
        FadePageRoute(
          page: EvaluationScreen(prompt: prompt, isTutorial: false),
        ),
      );
    }
  }
}

// Made with Bob
