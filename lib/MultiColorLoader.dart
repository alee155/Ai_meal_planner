import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoaderScreen extends StatelessWidget {
  const LoaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: const Center(child: UltraPremiumLoader()),
    );
  }
}

class UltraPremiumLoader extends StatefulWidget {
  const UltraPremiumLoader({super.key});

  @override
  State<UltraPremiumLoader> createState() => _UltraPremiumLoaderState();
}

class _UltraPremiumLoaderState extends State<UltraPremiumLoader>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  final List<Color> colors = const [
    Colors.green,
    Colors.greenAccent,
    Colors.lightGreen,
  ];

  @override
  void initState() {
    super.initState();

    // Rotation
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    // Glow pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
      lowerBound: 0.6,
      upperBound: 1.2,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationController, _pulseController]),
      builder: (_, __) {
        final rotation = _rotationController.value * 2 * pi;
        final pulse = _pulseController.value;

        return Transform.rotate(
          angle: rotation,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 🔥 Glow layer (animated)
              Container(
                width: 46.w,
                height: 46.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: colors,
                    stops: const [0.0, 0.5, 1.0],
                    transform: GradientRotation(
                      _rotationController.value * 2 * pi,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors[0].withOpacity(0.4),
                      blurRadius: 30 * pulse,
                      spreadRadius: 2 * pulse,
                    ),
                    BoxShadow(
                      color: colors[1].withOpacity(0.3),
                      blurRadius: 40 * pulse,
                      spreadRadius: 1 * pulse,
                    ),
                  ],
                ),
              ),

              // 🎯 Main ring
              Container(
                width: 46.w,
                height: 46.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: colors,
                    transform: GradientRotation(
                      _rotationController.value * 2 * pi,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
