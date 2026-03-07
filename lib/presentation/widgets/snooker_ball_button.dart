import 'package:flutter/material.dart';
import '../../data/models/snooker_ball.dart';

class SnookerBallButton extends StatelessWidget {
  final SnookerBall ball;
  final VoidCallback onTap;

  const SnookerBallButton({
    super.key,
    required this.ball,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ball == SnookerBall.black || ball == SnookerBall.brown;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: ball.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${ball.points}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            Text(
              ball.displayName,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
