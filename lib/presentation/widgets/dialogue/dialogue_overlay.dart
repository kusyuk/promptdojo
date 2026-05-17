import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../../core/theme/app_theme.dart';

/// Speaker identification for dialogue
enum Speaker { narrator, archmageBob }

/// Semi-transparent dialogue box that overlays Bob mascot
///
/// Features:
/// - Speaker badge (NARRATOR or ARCHMAGE BOB)
/// - Typewriter animation for text
/// - Semi-transparent background with blur effect
/// - Color-coded borders based on speaker
/// - Auto-scrolling to bottom during active text typing
/// - Pulsing double-down arrow indicating scrollable content
class DialogueOverlay extends StatefulWidget {
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
  State<DialogueOverlay> createState() => _DialogueOverlayState();
}

class _DialogueOverlayState extends State<DialogueOverlay> {
  late final ScrollController _scrollController;
  Timer? _scrollTimer;
  bool _showScrollIndicator = false;
  bool _isTypingComplete = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_updateScrollIndicator);

    // Initialize scroll state based on typewriter setting
    if (widget.enableTypewriter) {
      _startAutoScrolling();
    } else {
      _isTypingComplete = true;
      _checkScrollability();
    }
  }

  @override
  void didUpdateWidget(covariant DialogueOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text) {
      // Text changed: reset scroll, state, and typewriter scroll routines
      _scrollTimer?.cancel();
      _isTypingComplete = false;
      _showScrollIndicator = false;

      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }

      if (widget.enableTypewriter) {
        _startAutoScrolling();
      } else {
        _isTypingComplete = true;
        _checkScrollability();
      }
    }
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.removeListener(_updateScrollIndicator);
    _scrollController.dispose();
    super.dispose();
  }

  /// Check scroll capability once layout settles
  void _checkScrollability() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _updateScrollIndicator();
    });
  }

  /// Periodically animate-scroll to bottom of the scroll container
  /// as the typewriter reveals characters line-by-line.
  void _startAutoScrolling() {
    _scrollTimer?.cancel();
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;
        
        // Only scroll if there is scrollable content and we aren't already at bottom
        if (maxScroll > 0 && currentScroll < maxScroll) {
          _scrollController.animateTo(
            maxScroll,
            duration: const Duration(milliseconds: 80),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  /// Update indicator based on user scroll offset vs maxScrollExtent
  void _updateScrollIndicator() {
    if (!mounted || !_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentOffset = _scrollController.offset;
    
    // Show indicator if there is scrollable content and user has not scrolled to the bottom
    final canScroll = maxScroll > 0;
    final reachedBottom = currentOffset >= (maxScroll - 8);
    final hasMore = canScroll && !reachedBottom;

    if (hasMore != _showScrollIndicator) {
      setState(() {
        _showScrollIndicator = hasMore;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width > 600 ? 64 : 24,
      ),
      constraints: const BoxConstraints(
        minHeight: 135,
        maxHeight: 165,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.speaker == Speaker.archmageBob
              ? AppTheme.primaryColor.withValues(alpha: 0.6)
              : AppTheme.accentColor.withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.speaker == Speaker.archmageBob
                  ? AppTheme.primaryColor
                  : AppTheme.accentColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              widget.speaker == Speaker.archmageBob ? 'ARCHMAGE BOB' : 'NARRATOR',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Dialogue text with auto-scrolling & indicator
          Flexible(
            child: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: widget.enableTypewriter
                          ? AnimatedTextKit(
                              key: ValueKey(widget.text),
                              animatedTexts: [
                                TypewriterAnimatedText(
                                  widget.text,
                                  textStyle: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(height: 1.5, fontSize: 16),
                                  speed: const Duration(milliseconds: 40),
                                ),
                              ],
                              totalRepeatCount: 1,
                              displayFullTextOnTap: true,
                              stopPauseOnTap: true,
                              pause: Duration.zero,
                              onFinished: () {
                                _scrollTimer?.cancel();
                                setState(() {
                                  _isTypingComplete = true;
                                });
                                _checkScrollability();
                                widget.onComplete?.call();
                              },
                            )
                          : Text(
                              widget.text,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                height: 1.5,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ),
                
                // Pulsing indicator if more text exists below
                if (_showScrollIndicator)
                  const Positioned(
                    bottom: 0,
                    right: 0,
                    child: _PulsingScrollIndicator(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A subtle, circular pulsing visual badge suggesting more text is scrollable below
class _PulsingScrollIndicator extends StatefulWidget {
  const _PulsingScrollIndicator();

  @override
  State<_PulsingScrollIndicator> createState() => _PulsingScrollIndicatorState();
}

class _PulsingScrollIndicatorState extends State<_PulsingScrollIndicator>
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
      opacity: Tween<double>(begin: 0.3, end: 1.0).animate(_pulseController),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.accentColor.withValues(alpha: 0.6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentColor.withValues(alpha: 0.3),
              blurRadius: 6,
            ),
          ],
        ),
        child: const Icon(
          Icons.keyboard_double_arrow_down,
          color: AppTheme.accentColor,
          size: 12,
        ),
      ),
    );
  }
}

// Made with Bob
