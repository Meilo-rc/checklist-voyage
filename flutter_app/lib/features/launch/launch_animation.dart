import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const launchAnimationDuration = Duration(milliseconds: 1800);

class LaunchGate extends StatefulWidget {
  const LaunchGate({super.key, required this.home});

  final Widget home;

  @override
  State<LaunchGate> createState() => _LaunchGateState();
}

class _LaunchGateState extends State<LaunchGate> {
  var _completed = false;

  @override
  Widget build(BuildContext context) {
    if (_completed) {
      return widget.home;
    }
    return LaunchAnimation(
      onCompleted: () {
        if (mounted) {
          setState(() => _completed = true);
        }
      },
    );
  }
}

class LaunchAnimation extends StatefulWidget {
  const LaunchAnimation({super.key, required this.onCompleted});

  final VoidCallback onCompleted;

  @override
  State<LaunchAnimation> createState() => _LaunchAnimationState();
}

class _LaunchAnimationState extends State<LaunchAnimation>
    with SingleTickerProviderStateMixin {
  static const _blueSuitcase =
      'assets/launch/valise_01_grande_valise_bleue.svg';
  static const _handle = 'assets/launch/valise_02_poignee_telescopique.svg';
  static const _details = 'assets/launch/valise_03_details_noirs.svg';
  static const _pinkBag = 'assets/launch/valise_04_sac_rose.svg';
  static const _decorations =
      'assets/launch/valise_05_decorations_colorees.svg';

  late final AnimationController _controller;
  late final Animation<double> _suitcaseProgress;
  late final Animation<double> _handleProgress;
  late final Animation<double> _bagProgress;
  late final Animation<double> _decorationOpacity;
  late final Animation<double> _decorationScale;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: launchAnimationDuration)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              widget.onCompleted();
            }
          });
    _suitcaseProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.48, curve: Curves.easeOutCubic),
    );
    _handleProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.46, 0.68, curve: Curves.easeOutCubic),
    );
    _bagProgress =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 0.0,
              end: 1.035,
            ).chain(CurveTween(curve: Curves.easeOutCubic)),
            weight: 82,
          ),
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 1.035,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeOut)),
            weight: 18,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.23, 0.64),
          ),
        );
    _decorationOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.66, 0.85, curve: Curves.easeOut),
    );
    _decorationScale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.66, 0.85, curve: Curves.easeOutBack),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('launch-animation'),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final iconSize = math.min(
              math.min(constraints.maxWidth, constraints.maxHeight) * 0.39,
              210.0,
            );
            final offscreenDistance = constraints.maxWidth / 2 + iconSize;
            return Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final suitcaseX =
                      (1 - _suitcaseProgress.value) * offscreenDistance;
                  final handleY = (1 - _handleProgress.value) * iconSize * 0.27;
                  final bagX = -(1 - _bagProgress.value) * offscreenDistance;
                  return SizedBox.square(
                    key: const Key('launch-icon'),
                    dimension: iconSize,
                    child: Stack(
                      clipBehavior: Clip.none,
                      fit: StackFit.expand,
                      children: [
                        Transform.translate(
                          key: const Key('launch-handle'),
                          offset: Offset(suitcaseX, handleY),
                          child: SvgPicture.asset(_handle),
                        ),
                        Transform.translate(
                          key: const Key('launch-blue-suitcase'),
                          offset: Offset(suitcaseX, 0),
                          child: SvgPicture.asset(_blueSuitcase),
                        ),
                        Transform.translate(
                          offset: Offset(suitcaseX, 0),
                          child: SvgPicture.asset(_details),
                        ),
                        Transform.translate(
                          key: const Key('launch-pink-bag'),
                          offset: Offset(bagX, 0),
                          child: SvgPicture.asset(
                            _pinkBag,
                            clipBehavior: Clip.none,
                          ),
                        ),
                        FadeTransition(
                          key: const Key('launch-decorations'),
                          opacity: _decorationOpacity,
                          child: ScaleTransition(
                            scale: _decorationScale,
                            child: SvgPicture.asset(_decorations),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
