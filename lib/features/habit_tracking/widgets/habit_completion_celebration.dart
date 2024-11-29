import 'package:flutter/material.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'dart:math' as math;

class HabitCompletionCelebration extends StatefulWidget {
  final VoidCallback onComplete;

  const HabitCompletionCelebration({
    super.key,
    required this.onComplete,
  });

  @override
  State<HabitCompletionCelebration> createState() => _HabitCompletionCelebrationState();
}

class _HabitCompletionCelebrationState extends State<HabitCompletionCelebration> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _particles = List.generate(20, (index) => Particle());

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
            ..._particles.map((particle) {
              final position = particle.getPosition(_controller.value);
              return Positioned(
                left: position.dx,
                top: position.dy,
                child: Transform.rotate(
                  angle: particle.rotation * _controller.value * math.pi * 2,
                  child: Opacity(
                    opacity: 1 - _controller.value,
                    child: Icon(
                      particle.icon,
                      color: particle.color,
                      size: particle.size * (1 - _controller.value * 0.5),
                    ),
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

class Particle {
  final double size;
  final Color color;
  final IconData icon;
  final Offset velocity;
  final double rotation;
  final Offset initialPosition;

  Particle()
      : size = math.Random().nextDouble() * 20 + 10,
        color = [
          AppColors.accent,
          AppColors.success,
          AppColors.warning,
        ][math.Random().nextInt(3)],
        icon = [
          Icons.star_rounded,
          Icons.favorite_rounded,
          Icons.emoji_events_rounded,
          Icons.local_fire_department_rounded,
        ][math.Random().nextInt(4)],
        velocity = Offset(
          math.Random().nextDouble() * 200 - 100,
          math.Random().nextDouble() * -100 - 50,
        ),
        rotation = math.Random().nextDouble() * 2,
        initialPosition = Offset(
          math.Random().nextDouble() * 100 + 100,
          math.Random().nextDouble() * 100 + 100,
        );

  Offset getPosition(double time) {
    return Offset(
      initialPosition.dx + velocity.dx * time,
      initialPosition.dy + velocity.dy * time + 100 * time * time,
    );
  }
} 