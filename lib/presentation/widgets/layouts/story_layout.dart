import 'package:flutter/material.dart';
import '../characters/bob_mascot.dart';
import '../dialogue/dialogue_overlay.dart';
import '../action_panel/choice_button.dart';
import '../../../core/theme/app_theme.dart';

/// Layout widget that combines Bob mascot, dialogue, and action buttons
///
/// This widget creates the standard story screen layout:
/// - Background (cyber theme or Bob mascot)
/// - Dialogue overlay (centered)
/// - Action buttons (bottom)
///
/// Bob appears large behind the dialogue when Archmage Bob is speaking.
class StoryLayout extends StatefulWidget {
  final String dialogue;
  final Speaker speaker;
  final List<Widget> actionButtons;
  final bool showBob;
  final Widget? customBackground;

  const StoryLayout({
    super.key,
    required this.dialogue,
    required this.speaker,
    required this.actionButtons,
    this.showBob = true,
    this.customBackground,
  });

  @override
  State<StoryLayout> createState() => _StoryLayoutState();
}

class _StoryLayoutState extends State<StoryLayout> {
  bool _isDialogueComplete = false;

  @override
  void initState() {
    super.initState();
    _isDialogueComplete = false;
  }

  @override
  void didUpdateWidget(covariant StoryLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset typing completion tracking when dialogue changes
    if (widget.dialogue != oldWidget.dialogue) {
      setState(() {
        _isDialogueComplete = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Process action buttons to only enable ContinueButtons once the dialogue typewriter finishes
    final processedButtons = widget.actionButtons.map((button) {
      if (button is ContinueButton) {
        return ContinueButton(
          onPressed: button.onPressed,
          isEnabled: _isDialogueComplete,
        );
      }
      return button;
    }).toList();

    return Stack(
      children: [
        // Background
        if (widget.customBackground != null)
          Positioned.fill(child: widget.customBackground!)
        else
          Positioned.fill(
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
            ),
          ),

        // Bob mascot (positioned higher, behind dialogue)
        if (widget.showBob && widget.speaker == Speaker.archmageBob)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom:
                MediaQuery.of(context).size.height *
                0.35, // Push Bob up, leave bottom 35% for dialogue
            child: Center(child: BobMascot(size: BobSize.large, opacity: 0.9)),
          ),

        // Content
        SafeArea(
          child: Column(
            children: [
              // Middle section: Dialogue
              Expanded(
                child: Column(
                  children: [
                    // Spacer to push dialogue down (only overlays bottom of Bob)
                    const Spacer(flex: 6),

                    // Dialogue overlay (positioned lower)
                    Flexible(
                      flex: 4,
                      child: DialogueOverlay(
                        text: widget.dialogue,
                        speaker: widget.speaker,
                        onComplete: () {
                          if (mounted) {
                            setState(() {
                              _isDialogueComplete = true;
                            });
                          }
                        },
                      ),
                    ),

                    // Spacer between dialogue and buttons
                    const Spacer(flex: 1),
                  ],
                ),
              ),

              // Bottom section: Action buttons anchored to bottom
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                child: Center(
                  child: IntrinsicWidth(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: processedButtons.map((button) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: button,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Made with Bob
