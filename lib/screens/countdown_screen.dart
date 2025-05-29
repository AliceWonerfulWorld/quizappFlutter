import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

class CountdownScreen extends StatefulWidget {
  final String difficulty;

  const CountdownScreen({
    Key? key,
    required this.difficulty,
  }) : super(key: key);

  @override
  _CountdownScreenState createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> with SingleTickerProviderStateMixin {
  int _countdown = 3;
  late Timer _timer;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotateAnimation;
  late String _difficulty;

  @override
  void initState() {
    super.initState();
    _difficulty = widget.difficulty;
    
    _controller = AnimationController(
      duration: Duration(milliseconds: 900),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.5, 1.0, curve: Curves.easeOut),
    ));

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: math.pi * 2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _startCountdown();
  }

  void _startCountdown() {
    _controller.forward();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        if (_countdown > 1) {
          _countdown--;
          _controller.reset();
          _controller.forward();
        } else {
          _timer.cancel();
          Navigator.pushReplacementNamed(context, '/quiz', arguments: _difficulty);
        }
      });
    });
  }

  Color _getDifficultyColor() {
    switch (_difficulty) {
      case 'easy':
        return Colors.green.shade400;
      case 'medium':
        return Colors.orange.shade400;
      case 'hard':
        return Colors.red.shade400;
      default:
        return Colors.blue.shade400;
    }
  }

  String _getDifficultyText() {
    switch (_difficulty) {
      case 'easy':
        return 'かんたん';
      case 'medium':
        return 'ふつう';
      case 'hard':
        return 'むずかしい';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _timer.cancel();
        return true;
      },
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: FloatingActionButton(
            heroTag: 'homeButton',
            elevation: 4,
            backgroundColor: Colors.white.withOpacity(0.9),
            child: Icon(
              Icons.home_rounded,
              color: Theme.of(context).primaryColor,
              size: 32,
            ),
            onPressed: () {
              _timer.cancel();
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _getDifficultyColor().withOpacity(0.8),
                _getDifficultyColor().withOpacity(0.4),
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // 背景の装飾要素
                ...List.generate(10, (index) {
                  final random = math.Random();
                  return Positioned(
                    left: random.nextDouble() * MediaQuery.of(context).size.width,
                    top: random.nextDouble() * MediaQuery.of(context).size.height,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: _getDifficultyColor().withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getDifficultyText(),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: _getDifficultyColor().withOpacity(0.5),
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 40),
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Transform.rotate(
                              angle: _rotateAnimation.value,
                              child: Opacity(
                                opacity: _opacityAnimation.value,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: _getDifficultyColor(),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: _getDifficultyColor().withOpacity(0.5),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      _countdown.toString(),
                                      style: TextStyle(
                                        fontSize: 60,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
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
