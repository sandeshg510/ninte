import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:ninte/presentation/theme/app_colors.dart';

class HabitCompletionConfetti extends StatefulWidget {
  final VoidCallback onComplete;

  const HabitCompletionConfetti({
    super.key,
    required this.onComplete,
  });

  @override
  State<HabitCompletionConfetti> createState() => _HabitCompletionConfettiState();
}

class _HabitCompletionConfettiState extends State<HabitCompletionConfetti> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<ConfettiPiece> _pieces;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pieces = List.generate(50, (index) => ConfettiPiece());

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onComplete();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Celebration text
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Text(
                      'Great Job! 🎉',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
            // Confetti pieces
            ..._pieces.map((piece) {
              final position = piece.getPosition(_controller.value);
              return Positioned(
                left: position.dx,
                top: position.dy,
                child: Transform.rotate(
                  angle: piece.rotation * _controller.value * math.pi * 4,
                  child: Opacity(
                    opacity: 1 - _controller.value,
                    child: piece.build(),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class ConfettiPiece {
  final Color color;
  final double size;
  final ConfettiShape shape;
  final Offset velocity;
  final double rotation;
  final Offset initialPosition;

  ConfettiPiece()
      : color = [
          AppColors.accent,
          AppColors.success,
          AppColors.warning,
          Color(0xFFFF69B4), // Pink
          Color(0xFF9B59B6), // Purple
        ][math.Random().nextInt(5)],
        size = math.Random().nextDouble() * 10 + 5,
        shape = ConfettiShape.values[math.Random().nextInt(ConfettiShape.values.length)],
        velocity = Offset(
          math.Random().nextDouble() * 300 - 150,
          math.Random().nextDouble() * -200 - 100,
        ),
        rotation = math.Random().nextDouble() * 2,
        initialPosition = Offset(
          math.Random().nextDouble() * 300 + 50,
          math.Random().nextDouble() * 100 + 300,
        );

  Offset getPosition(double time) {
    return Offset(
      initialPosition.dx + velocity.dx * time,
      initialPosition.dy + velocity.dy * time + 300 * time * time,
    );
  }

  Widget build() {
    switch (shape) {
      case ConfettiShape.circle:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        );
      case ConfettiShape.square:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      case ConfettiShape.star:
        return Icon(
          Icons.star,
          size: size,
          color: color,
        );
    }
  }
}

enum ConfettiShape {
  circle,
  square,
  star,
} 