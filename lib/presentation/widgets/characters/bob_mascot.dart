import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Size variants for Bob mascot display
enum BobSize {
  /// Medium size for title and evaluation screens (~45% screen height)
  medium,

  /// Large size for behind dialogue boxes (~65% screen height)
  large,
}

/// Bob mascot widget with SVG rendering and optional animations
///
/// Displays the IBM Bob mascot from assets/images/bob_mascot.svg
/// with configurable size and floating animation.
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
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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

// Made with Bob
