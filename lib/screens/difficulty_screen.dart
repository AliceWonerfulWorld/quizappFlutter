import 'package:flutter/material.dart';

class DifficultyScreen extends StatefulWidget {
  @override
  _DifficultyScreenState createState() => _DifficultyScreenState();
}

class _DifficultyScreenState extends State<DifficultyScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _cardAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _cardAnimations = List.generate(3, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(index * 0.2, 0.6 + (index * 0.2), curve: Curves.easeOut),
        ),
      );
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  '難易度を選択',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'CoolFont',
                    shadows: [
                      Shadow(
                        blurRadius: 3.0,
                        color: Colors.black.withOpacity(0.4),
                        offset: Offset(1.5, 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildDifficultyCard(
                        animation: _cardAnimations[0],
                        title: 'かんたん',
                        subtitle: '初心者向け',
                        description: '基本的な問題で楽しく学べます\n制限時間: 15秒\nヒントあり',
                        color: Colors.green.shade400,
                        icon: Icons.sentiment_satisfied,
                        difficulty: 'easy',
                      ),
                      SizedBox(height: 16),
                      _buildDifficultyCard(
                        animation: _cardAnimations[1],
                        title: 'ふつう',
                        subtitle: '中級者向け',
                        description: '標準的な難しさの問題です\n制限時間: 10秒\nヒントなし',
                        color: Colors.orange.shade400,
                        icon: Icons.sentiment_neutral,
                        difficulty: 'medium',
                      ),
                      SizedBox(height: 16),
                      _buildDifficultyCard(
                        animation: _cardAnimations[2],
                        title: 'むずかしい',
                        subtitle: '上級者向け',
                        description: '挑戦しがいのある難問です\n制限時間: 7秒\nペナルティあり',
                        color: Colors.red.shade400,
                        icon: Icons.sentiment_very_satisfied,
                        difficulty: 'hard',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyCard({
    required Animation<double> animation,
    required String title,
    required String subtitle,
    required String description,
    required Color color,
    required IconData icon,
    required String difficulty,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - animation.value)),
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: () => _showDifficultyConfirmation(context, difficulty, title),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 32, color: color),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: color,
                            fontFamily: 'CoolFont',
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontFamily: 'CoolFont',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.grey[800],
                    fontFamily: 'CoolFont',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDifficultyConfirmation(BuildContext context, String difficulty, String difficultyName) {
    showDialog(
      context: context,
      barrierDismissible: false, // ダイアログ外タップで閉じないようにする
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 8,
          backgroundColor: Colors.transparent, // Dialog自体の背景は透明にする
          child: Container(
            padding: EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              gradient: LinearGradient(
                colors: [Color(0xFF6DD5ED), Color(0xFF2193B0)], // グラデーションの色を調整
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // コンテンツに合わせて高さを調整
              children: <Widget>[
                Icon(
                  Icons.help_outline_rounded, // 確認アイコン
                  color: Colors.white,
                  size: 50,
                ),
                SizedBox(height: 20),
                Text(
                  '確認',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'MPLUSRounded1c',
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  '$difficultyNameモードで開始しますか？',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.9),
                    fontFamily: 'MPLUSRounded1c',
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: Colors.white.withOpacity(0.7)),
                        ),
                      ),
                      child: Text(
                        'キャンセル',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'MPLUSRounded1c',
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        '開始',
                        style: TextStyle(
                          color: Color(0xFF2193B0), // ボタン背景に合わせたテキスト色
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'MPLUSRounded1c',
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(context, '/countdown', arguments: difficulty);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
