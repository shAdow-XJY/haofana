import 'package:flutter/material.dart';

class PandaIncenseGame extends StatefulWidget {
  const PandaIncenseGame({super.key});

  @override
  _PandaIncenseGameState createState() => _PandaIncenseGameState();
}

class _PandaIncenseGameState extends State<PandaIncenseGame> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _handMovementAnimation;
  late Animation<double> _handRotationAnimation;
  late Animation<Offset> _incenseMovementAnimation;
  bool isBowing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 1));

    // 动画定义
    _handMovementAnimation = Tween<Offset>(begin: Offset(0, 0.5), end: Offset(0, 0)).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _handRotationAnimation = Tween<double>(begin: 0, end: 30).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _incenseMovementAnimation = Tween<Offset>(begin: Offset(0, 0.5), end: Offset(0, 0)).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPandaClick() {
    if (!isBowing) {
      setState(() {
        isBowing = true;
      });
      _animationController.forward(from: 0.0).then((_) {
        setState(() {
          isBowing = false;
        });
        _animationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panda Offering Incense"),
      ),
      body: GestureDetector(
        onTap: _onPandaClick,
        child: Center(
          child: SizedBox(
            width: 400,  // Set a fixed width
            height: 400, // Set a fixed height
            child: Stack(
              children: [
                Positioned.fill( // Make sure the Stack fills the parent
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Stack(
                        children: [
                          // 熊猫头部
                          Positioned(
                            left: 100,
                            top: 50,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: 90,
                                minHeight: 90,
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(radius: 10, backgroundColor: Colors.black),
                                      SizedBox(width: 10),
                                      CircleAvatar(radius: 10, backgroundColor: Colors.black),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // 熊猫身体
                          Positioned(
                            left: 80,
                            top: 140,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: 160,
                                minHeight: 120,
                              ),
                              child: Container(
                                width: 160,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.all(Radius.circular(80)),
                                ),
                              ),
                            ),
                          ),
                          // 手部 - 左手
                          Positioned(
                            left: 110,  // 左手靠近身体的左边，调整位置
                            top: 50,  // 手的位置稍微调整
                            child: Transform.rotate(
                              angle: _handRotationAnimation.value * 3.14159 / 180,
                              child: Transform.translate(
                                offset: _handMovementAnimation.value,
                                child: Container(
                                  width: 10,  // 变细的手
                                  height: 140,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          // 手部 - 右手
                          Positioned(
                            left: 200,  // 右手靠近身体的右边，调整位置
                            top: 50,  // 手的位置稍微调整
                            child: Transform.rotate(
                              angle: -_handRotationAnimation.value * 3.14159 / 180,
                              child: Transform.translate(
                                offset: _handMovementAnimation.value,
                                child: Container(
                                  width: 10,  // 变细的手
                                  height: 140,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          // 交叉的香
                          Positioned(
                            left: 140,
                            top: 15,
                            child: Transform.rotate(
                              angle: -_handRotationAnimation.value * 3.14159 / 180,
                              child: Transform.translate(
                                offset: _incenseMovementAnimation.value,
                                child: Container(
                                  width: 5,
                                  height: 50,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 160,
                            top: 15,
                            child: Transform.rotate(
                              angle: 0,
                              child: Transform.translate(
                                offset: _incenseMovementAnimation.value,
                                child: Container(
                                  width: 5,
                                  height: 50,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 175,
                            top: 15,
                            child: Transform.rotate(
                              angle: _handRotationAnimation.value * 3.14159 / 180,
                              child: Transform.translate(
                                offset: _incenseMovementAnimation.value,
                                child: Container(
                                  width: 5,
                                  height: 50,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                          // 文字提示
                          if (isBowing)
                            const Positioned(
                              left: 125,
                              top: 280,
                              child: Text(
                                "难绷...",
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}