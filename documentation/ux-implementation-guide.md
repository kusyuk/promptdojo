# PromptDojo UX Implementation Guide

This guide provides detailed implementation steps for the UX redesign, with code examples and best practices.

## Phase 1: Core Components

### 1.1 BobMascot Widget

Create a reusable widget for displaying Bob with different sizes and animations.

**File**: `lib/presentation/widgets/characters/bob_mascot.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum BobSize {
  small,   // Not used in current design
  medium,  // Title, Evaluation screens
  large,   // Behind dialogue boxes
}

class BobMascot extends StatefulWidget {
  final BobSize size;
  final bool animate;
  final double opacity;
  
  const BobMascot({
    super.key,
    this.size = BobSize.large,
    this.animate = true,
    this.opacity = 1.0,
  });
  
  @override
  State<BobMascot> createState() => _BobMascotState();
}

class _BobMascotState extends State<BobMascot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;
  
  @override
  void initState() {
    super.initState();
    
    if (widget.animate) {
      _controller = AnimationController(
        duration: const Duration(seconds: 3),
        vsync: this,
      )..repeat(reverse: true);
      
      _floatAnimation = Tween<double>(
        begin: -10.0,
        end: 10.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
    }
  }
  
  @override
  void dispose() {
    if (widget.animate) {
      _controller.dispose();
    }
    super.dispose();
  }
  
  double _getHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    switch (widget.size) {
      case BobSize.small:
        return screenHeight * 0.25;
      case BobSize.medium:
        return screenHeight * 0.45;
      case BobSize.large:
        return screenHeight * 0.65;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final bobWidget = Opacity(
      opacity: widget.opacity,
      child: SvgPicture.asset(
        'assets/images/bob_mascot.svg',
        height: _getHeight(context),
        fit: BoxFit.contain,
      ),
    );
    
    if (!widget.animate) {
      return bobWidget;
    }
    
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: child,
        );
      },
      child: bobWidget,
    );
  }
}
```

### 1.2 DialogueOverlay Widget

Semi-transparent dialogue box that overlays Bob.

**File**: `lib/presentation/widgets/dialogue/dialogue_overlay.dart`

```dart
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../../core/theme/app_theme.dart';

enum Speaker {
  narrator,
  archmageBob,
}

class DialogueOverlay extends StatelessWidget {
  final String text;
  final Speaker speaker;
  final bool enableTypewriter;
  final VoidCallback? onComplete;
  
  const DialogueOverlay({
    super.key,
    required this.text,
    required this.speaker,
    this.enableTypewriter = true,
    this.onComplete,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: speaker == Speaker.archmageBob
              ? AppTheme.primaryColor.withOpacity(0.6)
              : AppTheme.accentColor.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Speaker badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: speaker == Speaker.archmageBob
                  ? AppTheme.primaryColor
                  : AppTheme.accentColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              speaker == Speaker.archmageBob
                  ? 'ARCHMAGE BOB'
                  : 'NARRATOR',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Dialogue text
          if (enableTypewriter)
            AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  text,
                  textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                    fontSize: 16,
                  ),
                  speed: const Duration(milliseconds: 40),
                ),
              ],
              totalRepeatCount: 1,
              displayFullTextOnTap: true,
              stopPauseOnTap: true,
              onFinished: onComplete,
            )
          else
            Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.5,
                fontSize: 16,
              ),
            ),
        ],
      ),
    );
  }
}
```

### 1.3 StoryLayout Widget

Combines Bob + Dialogue + Buttons in a consistent layout.

**File**: `lib/presentation/widgets/layouts/story_layout.dart`

```dart
import 'package:flutter/material.dart';
import '../characters/bob_mascot.dart';
import '../dialogue/dialogue_overlay.dart';
import '../../../core/theme/app_theme.dart';

class StoryLayout extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background
        if (customBackground != null)
          Positioned.fill(child: customBackground!)
        else
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.backgroundColor,
                    AppTheme.backgroundColor.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),
        
        // Bob mascot (behind dialogue)
        if (showBob && speaker == Speaker.archmageBob)
          Positioned.fill(
            child: Center(
              child: BobMascot(
                size: BobSize.large,
                opacity: 0.9,
              ),
            ),
          ),
        
        // Content
        SafeArea(
          child: Column(
            children: [
              // Spacer to push dialogue to center
              const Spacer(flex: 2),
              
              // Dialogue overlay
              DialogueOverlay(
                text: dialogue,
                speaker: speaker,
              ),
              
              // Spacer between dialogue and buttons
              const Spacer(flex: 1),
              
              // Action buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: actionButtons,
                ),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}
```

## Phase 2: Screen Implementations

### 2.1 TitleScreen

**File**: `lib/presentation/screens/title_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/characters/bob_mascot.dart';
import '../widgets/action_panel/choice_button.dart';
import '../../core/theme/app_theme.dart';
import 'story_screen.dart';

class TitleScreen extends ConsumerWidget {
  const TitleScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundColor,
              AppTheme.primaryColor.withOpacity(0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
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
                const BobMascot(
                  size: BobSize.medium,
                ),
                
                const Spacer(),
                
                // Begin button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: ChoiceButton(
                    text: 'Begin Your Journey',
                    icon: Icons.play_arrow,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const StoryScreen(
                            phase: GamePhase.tutorialIntro,
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
    );
  }
}
```

### 2.2 StoryScreen

**File**: `lib/presentation/screens/story_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/layouts/story_layout.dart';
import '../widgets/hud/mana_bar.dart';
import '../widgets/action_panel/choice_button.dart';
import '../widgets/dialogue/dialogue_overlay.dart';
import '../providers/game_controller.dart';
import '../providers/game_state_provider.dart';

enum GamePhase {
  tutorialIntro,
  tutorialPrompt,
  planningPhase,
  contextPhase,
  incantationIntro,
  incantationPrompt,
}

class StoryScreen extends ConsumerWidget {
  final GamePhase phase;
  
  const StoryScreen({
    super.key,
    required this.phase,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final controllerState = ref.watch(gameControllerProvider);
    
    return Scaffold(
      body: Column(
        children: [
          // Compact HUD
          Container(
            padding: const EdgeInsets.all(16),
            child: ManaBar(
              currentMana: gameState.manaReserves,
              maxMana: 1000,
              compact: true,
            ),
          ),
          
          // Story content
          Expanded(
            child: StoryLayout(
              dialogue: controllerState.currentDialogue,
              speaker: controllerState.isArchmageBob
                  ? Speaker.archmageBob
                  : Speaker.narrator,
              showBob: controllerState.isArchmageBob,
              actionButtons: _buildActionButtons(context, ref, controllerState),
            ),
          ),
        ],
      ),
    );
  }
  
  List<Widget> _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    GameControllerState state,
  ) {
    final controller = ref.read(gameControllerProvider.notifier);
    final buttons = <Widget>[];
    
    // Choice buttons
    if (state.showChoices) {
      for (int i = 0; i < state.choices.length; i++) {
        buttons.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ChoiceButton(
              text: state.choices[i],
              onPressed: () => _handleChoice(controller, i),
            ),
          ),
        );
      }
    }
    
    // Continue button
    if (state.showContinueButton) {
      buttons.add(
        ContinueButton(
          onPressed: () => _handleContinue(context, controller),
        ),
      );
    }
    
    return buttons;
  }
  
  void _handleChoice(GameController controller, int index) {
    // Handle choice based on current phase
    // Navigate to next screen as needed
  }
  
  void _handleContinue(BuildContext context, GameController controller) {
    // Handle continue based on current phase
    // Navigate to next screen as needed
  }
}
```

## Phase 3: Navigation Flow

### 3.1 Screen Transitions

Use consistent transitions between screens:

```dart
// Fade transition
Navigator.of(context).push(
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => NextScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  ),
);

// Slide transition
Navigator.of(context).push(
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => NextScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;
      
      var tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );
      
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 400),
  ),
);
```

## Phase 4: Testing Checklist

- [ ] Bob appears correctly on all screens
- [ ] Bob size is appropriate for each screen
- [ ] Dialogue box overlays Bob properly
- [ ] Semi-transparency works as expected
- [ ] Typewriter animation completes
- [ ] Button spacing is adequate
- [ ] Touch targets are large enough (48x48dp minimum)
- [ ] Transitions are smooth
- [ ] Mana bar updates correctly
- [ ] Navigation flow works end-to-end
- [ ] Back button behavior is correct
- [ ] Text is readable on all backgrounds
- [ ] Bob animation doesn't distract from dialogue

## Performance Optimization

### SVG Caching
```dart
// Preload Bob SVG in main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Preload SVG
  final loader = SvgAssetLoader('assets/images/bob_mascot.svg');
  await svg.cache.putIfAbsent(
    loader.cacheKey(null),
    () => loader.loadBytes(null),
  );
  
  runApp(const ProviderScope(child: MainApp()));
}
```

### Animation Performance
- Use `RepaintBoundary` around Bob to isolate repaints
- Disable animations on low-end devices if needed
- Use `const` constructors where possible

## Accessibility

- Ensure dialogue text has sufficient contrast
- Provide semantic labels for Bob mascot
- Support screen readers
- Allow skipping typewriter animation
- Ensure keyboard navigation works

## Next Steps

1. Implement BobMascot widget
2. Implement DialogueOverlay widget
3. Implement StoryLayout widget
4. Create TitleScreen
5. Update existing screens to use new layout
6. Test navigation flow
7. Add animations and polish
8. Optimize performance
9. Test on multiple devices
10. Gather user feedback