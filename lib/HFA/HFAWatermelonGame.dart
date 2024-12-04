import 'dart:math';
import 'package:flutter/material.dart';

class WatermelonGame extends StatefulWidget {
  const WatermelonGame({super.key});

  @override
  _WatermelonGameState createState() => _WatermelonGameState();
}

class _WatermelonGameState extends State<WatermelonGame> with TickerProviderStateMixin {
  double watermelonX = 150; // 西瓜中心X
  double watermelonY = 300; // 西瓜中心Y
  double watermelonRadius = 150; // 西瓜半径
  bool isCut = false; // 是否被切割
  Offset? cutLineStart; // 切割线起点
  Offset? cutLineEnd; // 切割线终点
  double newRadius = 0; // 新的西瓜半径
  late AnimationController animationController; // 动画控制器
  late AnimationController sliceAnimationController; // 切割动画控制器
  double sliceOffset = 0; // 切割的西瓜飞出去的偏移量

  @override
  void initState() {
    super.initState();

    // 动画控制器：用于生成新西瓜的动画
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    )..addListener(() {
      setState(() {
        newRadius = watermelonRadius * animationController.value;
        if (animationController.isCompleted) {
          // 动画完成后，将新的部分设为当前西瓜
          watermelonRadius = newRadius;
          isCut = false;
        }
      });
    });

    // 切割动画控制器：用于西瓜飞出去的动画
    sliceAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..addListener(() {
      setState(() {
        sliceOffset = sliceAnimationController.value * 200; // 控制西瓜飞出去的距离
      });
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    sliceAnimationController.dispose();
    super.dispose();
  }

  void handleCut(Offset start, Offset end) {
    if (isCut) return;

    // 检测切线是否穿过西瓜
    final dx = watermelonX - start.dx;
    final dy = watermelonY - start.dy;
    final distance = sqrt(dx * dx + dy * dy);
    if (distance <= watermelonRadius) {
      setState(() {
        isCut = true;
        cutLineStart = start;
        cutLineEnd = end;
      });

      // 开始飞出去动画
      sliceAnimationController.forward(from: 0.0);

      // 开始生成新西瓜的动画
      animationController.forward(from: 0.0);
    }
  }

  void resetGame() {
    setState(() {
      // 重置一个随机的新西瓜
      final screenSize = MediaQuery.of(context).size;
      watermelonX = Random().nextDouble() * (screenSize.width - 200) + 100;
      watermelonY = Random().nextDouble() * (screenSize.height - 200) + 100;
      watermelonRadius = 150;
      isCut = false;
      cutLineStart = null;
      cutLineEnd = null;
      newRadius = 0;
      sliceOffset = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      body: GestureDetector(
        onPanStart: (details) {
          // 切线起点
          setState(() {
            cutLineStart = details.localPosition;
          });
        },
        onPanUpdate: (details) {
          // 切线终点
          setState(() {
            cutLineEnd = details.localPosition;
          });
        },
        onPanEnd: (_) {
          if (cutLineStart != null && cutLineEnd != null) {
            handleCut(cutLineStart!, cutLineEnd!);
          }
        },
        child: Stack(
          children: [
            // 显示西瓜
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: WatermelonPainter(
                watermelonX: watermelonX,
                watermelonY: watermelonY,
                watermelonRadius: isCut ? newRadius : watermelonRadius,
                isCut: isCut,
                cutLineStart: cutLineStart,
                cutLineEnd: cutLineEnd,
                sliceOffset: sliceOffset,
              ),
            ),
            // 显示刀
            if (cutLineStart != null && cutLineEnd != null)
              Positioned(
                left: cutLineStart!.dx - 25,
                top: cutLineStart!.dy - 25,
                child: Transform.rotate(
                  angle: atan2(cutLineEnd!.dy - cutLineStart!.dy, cutLineEnd!.dx - cutLineStart!.dx),
                  child: Image.asset(
                    'assets/knife.png', // 需要准备一把刀的图片
                    width: 50,
                    height: 50,
                  ),
                ),
              ),
            // 游戏重置按钮
            Positioned(
              top: 40,
              right: 20,
              child: ElevatedButton(
                onPressed: resetGame,
                child: Text("Reset Game"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WatermelonPainter extends CustomPainter {
  final double watermelonX;
  final double watermelonY;
  final double watermelonRadius;
  final bool isCut;
  final Offset? cutLineStart;
  final Offset? cutLineEnd;
  final double sliceOffset;

  WatermelonPainter({
    required this.watermelonX,
    required this.watermelonY,
    required this.watermelonRadius,
    required this.isCut,
    this.cutLineStart,
    this.cutLineEnd,
    this.sliceOffset = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // 绘制西瓜主体
    paint.color = Colors.green;
    canvas.drawCircle(Offset(watermelonX, watermelonY), watermelonRadius, paint);

    // 绘制西瓜纹理
    paint.color = Colors.red;
    canvas.drawCircle(
      Offset(watermelonX, watermelonY),
      watermelonRadius - 10,
      paint,
    );

    // 如果被切，绘制切线
    if (isCut && cutLineStart != null && cutLineEnd != null) {
      paint.color = Colors.black;
      paint.strokeWidth = 4;
      canvas.drawLine(cutLineStart!, cutLineEnd!, paint);
    }

    // 如果西瓜已经被切割，绘制切割后的效果
    if (isCut) {
      // 左半部分
      paint.color = Colors.green.withOpacity(0.6);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(watermelonX, watermelonY), radius: watermelonRadius),
        -pi / 2,
        pi,
        true,
        paint,
      );

      // 右半部分（飞出去的）
      paint.color = Colors.green.withOpacity(0.6);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(watermelonX + sliceOffset, watermelonY), radius: watermelonRadius),
        pi / 2,
        pi,
        true,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}