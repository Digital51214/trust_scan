import 'package:flutter/material.dart';
import 'dart:math' as math;


class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Rotation animation set karna
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(); // Animation ko lagatar chalane ke liye
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF081126), // Dark blue background
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Background Glow Effect
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0xFF00CFFF).withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // 2. Rotating Circle Loader
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _controller.value * 2 * math.pi,
                  child: Container(
                    width: 150,
                    height: 150,
                    child: CustomPaint(
                      painter: RingPainter(),
                    ),
                  ),
                );
              },
            ),

            // 3. Center Logo (Shield Icon)
            // Note: Aap yahan Image.asset() bhi use kar sakte hain
            Image.asset(

             'assets/images/logo.png',
              height: 100,
              width: 100,

            ),
          ],
        ),
      ),
    );
  }
}

// Custom Painter circle/ring banane ke liye
class RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint basePaint = Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    Paint activePaint = Paint()
      ..color =  Color(0xFF00CFFF) // Bright blue color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;

    // Poora halka circle
    canvas.drawCircle(size.center(Offset.zero), size.width / 2, basePaint);

    // Moving arc (jo rotate hoga)
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      -math.pi / 2,
      math.pi / 2, // 1/4th circle fill hoga
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
