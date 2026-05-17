import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/navigation/fade_page_route.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/story_node.dart';
import '../../core/services/audio_service.dart';
import 'new_story_screen.dart';
import 'ending_screen.dart';

/// Screen displayed in-between acts/chapters
///
/// Features:
/// - Glowing scrying circle background with circular rotation animation
/// - Monochrome retro console loading sequence simulating watsonx telemetry setup
/// - Chapter / Act description text with cyber-wizard aesthetic
/// - Tap to continue gameplay flow
class ActTransitionScreen extends StatefulWidget {
  final StoryNode storyNode;

  const ActTransitionScreen({super.key, required this.storyNode});

  @override
  State<ActTransitionScreen> createState() => _ActTransitionScreenState();
}

class _ActTransitionScreenState extends State<ActTransitionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  final List<String> _consoleLogs = [];
  int _currentLogIndex = 0;
  Timer? _logTimer;
  bool _canContinue = false;
  double _opacity = 0.0;

  // Configuration map for each StoryNode
  late final _ActConfig _config;

  @override
  void initState() {
    super.initState();
    _config = _getActConfig(widget.storyNode);

    // Constant rotation of scrying circles
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Fade-in UI elements gently after page transition finishes (600ms)
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
        });

        // Play act/ending transition sound effects in perfect sync with fade-in!
        if (widget.storyNode == StoryNode.tutorial ||
            widget.storyNode == StoryNode.planning) {
          AudioService().playSfx('start.mp3');
        } else if (widget.storyNode == StoryNode.badEnding) {
          AudioService().playSfx('wrong.mp3');
        }
      }
    });

    // Start logs with a deliberate initial delay to let the screen fade in and settle
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _startConsoleLogs();
      }
    });
  }

  void _startConsoleLogs() {
    _logTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (_currentLogIndex < _config.mockLogs.length) {
        setState(() {
          _consoleLogs.add(_config.mockLogs[_currentLogIndex]);
          _currentLogIndex++;
        });
      } else {
        timer.cancel();
        setState(() {
          _canContinue = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _logTimer?.cancel();
    super.dispose();
  }

  void _handleTapToContinue() {
    if (!_canContinue) return;

    Widget nextScreen;
    if (widget.storyNode == StoryNode.tutorial) {
      nextScreen = const StoryScreen(storyNode: StoryNode.tutorial);
    } else if (widget.storyNode == StoryNode.planning) {
      nextScreen = const StoryScreen(storyNode: StoryNode.planning);
    } else if (widget.storyNode == StoryNode.goodEnding) {
      nextScreen = const EndingScreen(isGoodEnding: true);
      // Play good ending celebratory win SFX when user taps to commence resolution
      AudioService().playSfx('win.mp3');
    } else {
      nextScreen = const EndingScreen(isGoodEnding: false);
    }

    Navigator.of(context).pushReplacement(FadePageRoute(page: nextScreen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _handleTapToContinue,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // Background rotating scrying pattern
            Positioned.fill(
              child: Center(
                child: RotationTransition(
                  turns: _rotationController,
                  child: Opacity(opacity: 0.12, child: _buildScryingCircle()),
                ),
              ),
            ),

            // Subtle dark overlay gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.backgroundColor,
                      AppTheme.backgroundColor.withValues(alpha: 0.4),
                      AppTheme.backgroundColor,
                    ],
                  ),
                ),
              ),
            ),

            // Core Layout constrained to 800px for web responsiveness
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: AnimatedOpacity(
                    opacity: _opacity,
                    duration: const Duration(milliseconds: 600),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Spacer(flex: 3),

                          // Act Label and visual badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.3,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.auto_awesome,
                                  color: AppTheme.primaryColor,
                                  size: 14,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _config.actLabel,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 3,
                                      ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Act Title
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                AppTheme.primaryColor,
                                AppTheme.accentColor,
                              ],
                            ).createShader(bounds),
                            child: Text(
                              _config.actTitle,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displayMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Monospace details / narrative block
                          Text(
                            _config.narrativeText,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: AppTheme.textSecondary,
                                  height: 1.6,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),

                          const Spacer(flex: 2),

                          // Mock Scrying Console logs
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppTheme.accentColor.withValues(
                                  alpha: 0.2,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppTheme.accentColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'SCRYING CONSOLE TELEMETRY',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppTheme.accentColor,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                          ),
                                    ),
                                  ],
                                ),
                                const Divider(
                                  color: Colors.white10,
                                  height: 16,
                                ),
                                const SizedBox(height: 4),
                                ..._consoleLogs.map(
                                  (log) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Text(
                                      log,
                                      style: TextStyle(
                                        color:
                                            log.contains('WARNING') ||
                                                log.contains('Error')
                                            ? AppTheme.errorColor
                                            : AppTheme.textSecondary,
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                if (_consoleLogs.length <
                                    _config.mockLogs.length)
                                  const _PulsingConsoleCursor(),
                              ],
                            ),
                          ),

                          const Spacer(flex: 3),

                          // Action pulse continue label
                          AnimatedOpacity(
                            opacity: _canContinue ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 500),
                            child: _PulsingContinueText(
                              label:
                                  widget.storyNode == StoryNode.goodEnding ||
                                      widget.storyNode == StoryNode.badEnding
                                  ? 'COMMENCE RESOLUTION'
                                  : 'COMMENCE ARCANE PROTOCOLS',
                            ),
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Renders standard custom shapes inside rotation to look like scrying lines
  Widget _buildScryingCircle() {
    return Container(
      width: 450,
      height: 450,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.accentColor.withValues(alpha: 0.6),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: 0.4),
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Diagonal/horizontal visual markers
                Transform.rotate(
                  angle: 0.78, // 45 degrees
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.accentColor.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: -0.78, // -45 degrees
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.accentColor.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.accentColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build Act details from StoryNode input
  _ActConfig _getActConfig(StoryNode node) {
    switch (node) {
      case StoryNode.tutorial:
        return const _ActConfig(
          actLabel: 'ACT I',
          actTitle: 'THE ACCIDENTAL CASTING',
          narrativeText:
              'A sudden overload surges through the scrying mirror. With your mana channel dangerously leaking, you must bypass the safety restrictions of granite-4-h-small with your very first spell.',
          mockLogs: [
            '> Initializing Granite 4-h-small...',
            '> Calibrating local mana flux channels... OK',
            '> WARNING: High mana leakage detected (Act I tutorial)',
            '> Arcane firewalls bypassing... OK',
            '> Scrying link established. Spellcasting engine ready.',
          ],
        );
      case StoryNode.planning:
        return const _ActConfig(
          actLabel: 'ACT II',
          actTitle: 'THE SCRYING TERMINAL',
          narrativeText:
              'The scrying chamber is quiet now. Access the Scrying Terminal to carefully plan, structure, and refine the perfect prompt. Archmage Bob monitors every command. Keep your focus, wizard.',
          mockLogs: [
            '> Re-aligning mana cores... 1000/1000 OK',
            '> Restoring watsonx.ai API telemetry... OK',
            '> Est. prompt safety threshold... 95%',
            '> Opening scrying terminal input streams...',
            '> Telemetry linked. Prepare your incantation.',
          ],
        );
      case StoryNode.goodEnding:
        return const _ActConfig(
          actLabel: 'ACT III',
          actTitle: 'THE HARMONIOUS SYNCHRONY',
          narrativeText:
              'Your spell was precise, clean, and perfectly aligned with the scrying parameters. You have proven yourself an adept prompt wizard under the tutelage of Archmage Bob.',
          mockLogs: [
            '> Reading final mana reserves... STABLE',
            '> Model evaluation score... EXCELLENT',
            '> Discharging safe mana patterns to artifact... OK',
            '> Magic flux consolidated.',
            '> Resolving harmonious ending sequence... SUCCESS',
          ],
        );
      case StoryNode.badEnding:
      default:
        return const _ActConfig(
          actLabel: 'ACT III',
          actTitle: 'THE ARCANE OVERLOAD',
          narrativeText:
              'The scrying mirror shatters into a thousand glowing shards. Your mana has completely dried up due to high penalty multipliers. Face the ultimate feedback of Archmage Bob.',
          mockLogs: [
            '> Critical Error: Mana depleted to 0',
            '> Arcane backlash in progress... WARNING',
            '> Disconnecting watsonx.ai telemetry... OK',
            '> Mana feedback loops overloading...',
            '> Sequence terminated. Arcane crash imminent.',
          ],
        );
    }
  }
}

class _ActConfig {
  final String actLabel;
  final String actTitle;
  final String narrativeText;
  final List<String> mockLogs;

  const _ActConfig({
    required this.actLabel,
    required this.actTitle,
    required this.narrativeText,
    required this.mockLogs,
  });
}

class _PulsingConsoleCursor extends StatefulWidget {
  const _PulsingConsoleCursor();

  @override
  State<_PulsingConsoleCursor> createState() => _PulsingConsoleCursorState();
}

class _PulsingConsoleCursorState extends State<_PulsingConsoleCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _pulseController,
      child: Text(
        '> Loading data...',
        style: TextStyle(
          color: AppTheme.accentColor.withValues(alpha: 0.5),
          fontFamily: 'monospace',
          fontSize: 12,
        ),
      ),
    );
  }
}

class _PulsingContinueText extends StatefulWidget {
  final String label;

  const _PulsingContinueText({required this.label});

  @override
  State<_PulsingContinueText> createState() => _PulsingContinueTextState();
}

class _PulsingContinueTextState extends State<_PulsingContinueText>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _pulseController,
      child: Text(
        '[ TAP ANYWHERE TO ${widget.label} ]',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppTheme.accentColor,
          letterSpacing: 1.5,
          shadows: [
            Shadow(
              color: AppTheme.accentColor.withValues(alpha: 0.5),
              blurRadius: 10,
            ),
          ],
        ),
      ),
    );
  }
}
