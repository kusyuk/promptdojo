import 'package:flutter/material.dart';
import "../../core/navigation/fade_page_route.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/characters/bob_mascot.dart';
import '../widgets/action_panel/choice_button.dart';
import '../../core/theme/app_theme.dart';
import 'act_transition_screen.dart';
import '../../domain/entities/story_node.dart';
import '../../core/services/audio_service.dart';

/// Title screen - Entry point of the game
///
/// Features:
/// - Game title with gradient
/// - Bob mascot (medium size)
/// - "Begin Your Journey" button
class TitleScreen extends ConsumerStatefulWidget {
  const TitleScreen({super.key});

  @override
  ConsumerState<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends ConsumerState<TitleScreen> {
  @override
  void initState() {
    super.initState();
    // Start looping background music immediately when TitleScreen loads
    AudioService().initializeBgm();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // Safe check to play or resume BGM on the first tap anywhere to bypass web autoplay policy limits
        AudioService().initializeBgm();
      },
      child: Scaffold(
        body: Container(
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
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // Game title
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.secondaryColor,
                          AppTheme.accentColor,
                        ],
                      ).createShader(bounds),
                      child: Text(
                        'PROMPTDOJO',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Subtitle
                    Text(
                      'The Architect\'s Awakening',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Bob mascot
                    const BobMascot(size: BobSize.medium),

                    const Spacer(),

                    // Begin button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: ChoiceButton(
                        text: 'Begin Your Journey',
                        icon: Icons.play_arrow,
                        onPressed: () {
                          // Make sure to kick off BGM on button click as well
                          AudioService().initializeBgm();
                          Navigator.of(context).pushReplacement(
                            FadePageRoute(
                              page: const ActTransitionScreen(
                                storyNode: StoryNode.tutorial,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 48),
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

// Made with Bob
