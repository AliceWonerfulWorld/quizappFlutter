import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class SlotMachineScreen extends StatefulWidget {
  @override
  _SlotMachineScreenState createState() => _SlotMachineScreenState();
}

class _SlotMachineScreenState extends State<SlotMachineScreen> with TickerProviderStateMixin {
  final List<String> symbols = ['🍒', '🍋', '🍊', '🍉', '🍇', '7️⃣', '⭐'];
  final Random random = Random();
  late List<int> reelIndices;
  late List<bool> reelStopped;
  late List<Timer> reelTimers;
  late AnimationController _spinButtonController;
  bool _isSpinning = false;
  int _coins = 100; // 初期コイン数

  @override
  void initState() {
    super.initState();
    reelIndices = List<int>.generate(3, (index) => random.nextInt(symbols.length));
    reelStopped = List<bool>.filled(3, false);
    reelTimers = [];

    _spinButtonController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  Timer startReel(int reelIndex) {
    final speedMultiplier = 1 + (reelIndex * 0.2); // リールごとに少し速度を変える
    return Timer.periodic(Duration(milliseconds: (100 * speedMultiplier).round()), (timer) {
      setState(() {
        if (!reelStopped[reelIndex]) {
          reelIndices[reelIndex] = random.nextInt(symbols.length);
        }
      });
    });
  }

  void startSpinning() {
    if (_coins < 10) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('コインが足りません'),
          content: Text('10コイン必要です。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _isSpinning = true;
      _coins -= 10; // 10コインを消費
      reelStopped = List<bool>.filled(3, false);
      reelTimers.forEach((timer) => timer.cancel());
      reelTimers = List<Timer>.generate(3, (index) => startReel(index));
    });

    // リールを自動的に停止
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(seconds: 2 + i), () {
        if (mounted && !reelStopped[i]) {
          stopReel(i);
        }
      });
    }
  }

  void stopReel(int reelIndex) {
    if (!mounted) return;
    setState(() {
      reelStopped[reelIndex] = true;
    });
    reelTimers[reelIndex].cancel();
    if (reelStopped.every((stopped) => stopped)) {
      _isSpinning = false;
      checkWin();
    }
  }

  void checkWin() {
    // 全てのリールが同じシンボルの場合
    if (reelIndices.every((index) => index == reelIndices[0])) {
      int winAmount = calculateWinAmount(reelIndices[0]);
      setState(() {
        _coins += winAmount;
      });
      showWinDialog(winAmount);
    }
  }

  int calculateWinAmount(int symbolIndex) {
    // シンボルに応じて配当を変える
    switch (symbols[symbolIndex]) {
      case '7️⃣':
        return 777;
      case '⭐':
        return 100;
      case '🍒':
        return 50;
      default:
        return 30;
    }
  }

  void showWinDialog(int winAmount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('おめでとうございます！'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$winAmountコインの勝利！'),
            SizedBox(height: 20),
            Icon(Icons.celebration, size: 50, color: Colors.amber),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    reelTimers.forEach((timer) => timer.cancel());
    _spinButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          children: [
            FloatingActionButton(
              heroTag: 'homeButton',
              elevation: 4,
              backgroundColor: Colors.white.withOpacity(0.9),
              child: Icon(
                Icons.home_rounded,
                color: Theme.of(context).primaryColor,
                size: 32,
              ),
              onPressed: () async {
                bool? shouldReturn = await showDialog<bool>(
                  context: context,
                  builder: (context) => Dialog( // AlertDialogをDialogに変更
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple.shade800, Colors.purple.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 3,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.casino_rounded, color: Colors.white, size: 28),
                              SizedBox(width: 10),
                              Text(
                                '確認',
                                style: TextStyle(
                                  fontFamily: 'MPLUSRounded1c',
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Text(
                            'タイトルに戻りますか？\n獲得したコインは保存されません。',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'MPLUSRounded1c',
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 25),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text(
                                  'キャンセル',
                                  style: TextStyle(
                                    fontFamily: 'MPLUSRounded1c',
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber.shade700,
                                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 5,
                                ),
                                child: Text(
                                  'タイトルに戻る',
                                  style: TextStyle(
                                    fontFamily: 'MPLUSRounded1c',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
                if (shouldReturn == true) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                }
              },
            ),
            SizedBox(width: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.amber.shade600,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.monetization_on,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '$_coins',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade900,
              Colors.purple.shade700,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.amber,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List<Widget>.generate(3, (index) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          symbols[reelIndices[index]],
                          style: TextStyle(fontSize: 50),
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _isSpinning ? null : startSpinning,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_circle_filled, size: 30),
                          SizedBox(width: 10),
                          Text(
                            'スピン (10コイン)',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '配当表',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildPayoutRow('7️⃣7️⃣7️⃣', '777コイン'),
                          SizedBox(width: 20),
                          _buildPayoutRow('⭐⭐⭐', '100コイン'),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildPayoutRow('🍒🍒🍒', '50コイン'),
                          SizedBox(width: 20),
                          _buildPayoutRow('その他', '30コイン'),
                        ],
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

  Widget _buildPayoutRow(String symbols, String payout) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          symbols,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        SizedBox(width: 5),
        Text(
          payout,
          style: TextStyle(
            color: Colors.amber,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
