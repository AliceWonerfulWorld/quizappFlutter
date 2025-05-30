import 'package:flutter/material.dart';
import 'dart:math' as math;

class TitleScreen extends StatefulWidget {
  @override
  _TitleScreenState createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconAnimation;
  late Animation<double> _titleAnimation;
  late Animation<double> _subtitleAnimation;
  late List<AnimationController> _shapeControllers;
  late List<Animation<double>> _shapeAnimations;
  late List<Animation<Offset>> _shapePositionAnimations;

  final int numberOfShapes = 15;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1800),
    );
    _iconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.0, 0.4, curve: Curves.elasticOut)),
    );
    _titleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.2, 0.7, curve: Curves.easeOutBack)),
    );
    _subtitleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.5, 1.0, curve: Curves.easeIn)),
    );

    _shapeControllers = List.generate(numberOfShapes, (index) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 4000 + math.Random().nextInt(4000)),
      )..repeat(reverse: true);
    });

    _shapeAnimations = List.generate(numberOfShapes, (index) {
      return Tween<double>(begin: 0.1, end: 0.7).animate(
        CurvedAnimation(
          parent: _shapeControllers[index],
          curve: Curves.easeInOutSine,
        ),
      );
    });

    _shapePositionAnimations = List.generate(numberOfShapes, (index) {
      final random = math.Random();
      final startOffset = Offset(
        random.nextDouble() * 1.2 - 0.1,
        random.nextDouble() * 1.2 - 0.1,
      );
      final endOffset = Offset(
        random.nextDouble() * 1.2 - 0.1,
        random.nextDouble() * 1.2 - 0.1,
      );
      return Tween<Offset>(begin: startOffset, end: endOffset).animate(
        CurvedAnimation(
          parent: _shapeControllers[index],
          curve: Curves.linear,
        ),
      );
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _shapeControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  List<Widget> _buildAnimatedShapes(Size screenSize) {
    final List<Color> shapeColors = [
      Colors.white.withOpacity(0.1),
      Colors.white.withOpacity(0.15),
      Colors.white.withOpacity(0.05),
      Colors.lightBlue.shade100.withOpacity(0.1),
      Colors.teal.shade100.withOpacity(0.08),
    ];
    final random = math.Random();

    return List.generate(numberOfShapes, (index) {
      final color = shapeColors[random.nextInt(shapeColors.length)];
      final size = random.nextDouble() * 80 + 40;
      final isCircle = random.nextBool();

      return AnimatedBuilder(
        animation: _shapeControllers[index],
        builder: (context, child) {
          final position = _shapePositionAnimations[index].value;
          return Positioned(
            left: position.dx * screenSize.width - size / 2,
            top: position.dy * screenSize.height - size / 2,
            child: Opacity(
              opacity: _shapeAnimations[index].value,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: color,
                  shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
                  borderRadius: isCircle ? null : BorderRadius.circular(random.nextDouble() * 20),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget buildMenuButton(
      BuildContext context, String title, Color startColor, Color endColor, VoidCallback onPressed) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: Tween<double>(begin: 0.5, end: 1.0)
              .animate(CurvedAnimation(parent: _controller, curve: Interval(0.6, 1.0, curve: Curves.elasticOut)))
              .value,
          child: Opacity(
            opacity: Tween<double>(begin: 0.0, end: 1.0)
                .animate(CurvedAnimation(parent: _controller, curve: Interval(0.5, 0.9, curve: Curves.easeIn)))
                .value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 12.0, horizontal: 30.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(
              color: startColor.withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 1,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            textStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontFamily: 'YourCustomFont',
            ),
          ),
          onPressed: onPressed,
          child: Text(title, style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          ..._buildAnimatedShapes(screenSize),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ScaleTransition(
                    scale: _iconAnimation,
                    child: Icon(Icons.emoji_events_rounded, size: 120, color: Colors.amber.shade300),
                  ),
                  SizedBox(height: 20),
                  FadeTransition(
                    opacity: _titleAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(begin: Offset(0, -0.5), end: Offset.zero).animate(
                        CurvedAnimation(parent: _controller, curve: Interval(0.2, 0.7, curve: Curves.easeOutBack)),
                      ),
                      child: Text(
                        'クイズマスター',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'MPLUSRounded1c', // 既存のフォント
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black.withOpacity(0.3),
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  FadeTransition(
                    opacity: _subtitleAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(begin: Offset(0, 0.8), end: Offset.zero).animate(
                        CurvedAnimation(parent: _controller, curve: Interval(0.5, 1.0, curve: Curves.easeOut)) // 少し遅れて開始、スムーズに
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          // color: Colors.black.withOpacity(0.2), // 背景を少し暗くしてテキストを際立たせる
                          // borderRadius: BorderRadius.circular(20), // 角を丸くする
                        ),
                        child: Text(
                          '知識で遊ぼう！',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.white.withOpacity(0.9),
                            fontFamily: 'MPLUSRounded1c', // MPLUSRounded1c-Regular を指定
                            fontWeight: FontWeight.normal, // Regularウェイトを指定
                            letterSpacing: 1.2, // 文字間隔を調整
                            shadows: [
                              Shadow(
                                blurRadius: 8.0,
                                color: Colors.black.withOpacity(0.4),
                                offset: Offset(1.5, 1.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 60),
                  buildMenuButton(
                    context,
                    'スタート',
                    Color(0xFF8E2DE2),
                    Color(0xFF4A00E0),
                    () {
                      Navigator.pushNamed(context, '/rules');
                    },
                  ),
                  SizedBox(height: 20),
                  buildMenuButton(
                    context,
                    'スロットゲーム',
                    Color(0xFF00B4DB),
                    Color(0xFF0083B0),
                    () {
                      Navigator.pushNamed(context, '/slot');
                    },
                  ),
                  SizedBox(height: 20),
                  buildMenuButton(
                    context,
                    'スコアボード',
                    Color(0xFFF2994A),
                    Color(0xFFF2C94C),
                    () {
                      Navigator.pushNamed(context, '/scoreboard');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// フォントファミリー 'YourCustomFont' は、実際に使用するフォント名に置き換えてください。
// pubspec.yaml にフォントが追加されていることを確認してください。
