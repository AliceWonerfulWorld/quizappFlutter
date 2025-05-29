import 'package:flutter/material.dart';

class RulesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar( // AppBarを削除またはコメントアウト
      //   title: Text('ルール'),
      // ),
      body: Stack( // Stackウィジェットを追加して背景とコンテンツを重ねる
        children: [
          // 背景のグラデーション
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)], // title_screen.dart と同じグラデーション
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // SafeAreaでコンテンツがステータスバー等と重ならないようにする
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0), // パディングを調整
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch, // 子要素を水平方向に広げる
                  children: <Widget>[
                    Center(
                      child: Text(
                        'クイズのルール',
                        style: TextStyle(
                          fontSize: 32, // フォントサイズ調整
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // テキスト色を白に変更
                          fontFamily: 'CoolFont', // ← フォントファミリーを指定
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
                    SizedBox(height: 30),
                    _buildRuleCard(
                      icon: Icons.check_circle_outline,
                      text: '各クイズには1つの正しい答えがあります。',
                      iconColor: Colors.greenAccent,
                    ),
                    _buildRuleCard(
                      icon: Icons.touch_app_outlined,
                      text: '質問に答えるために、選択肢の1つをタップしてください。',
                      iconColor: Colors.blueAccent,
                    ),
                    _buildRuleCard(
                      icon: Icons.help_outline,
                      text: '正解なら〇と「正解」と表示され、不正解なら×と「不正解」と表示されます。',
                      iconColor: Colors.orangeAccent,
                    ),
                    _buildRuleCard(
                      icon: Icons.format_list_numbered_outlined,
                      text: '全部で5問あります。',
                      iconColor: Colors.purpleAccent,
                    ),
                    _buildRuleCard(
                      icon: Icons.timer_outlined,
                      text: '各問題には10秒の制限時間があります。',
                      iconColor: Colors.redAccent,
                    ),
                    _buildRuleCard(
                      icon: Icons.emoji_events_outlined,
                      text: '最後に正解数が表示されます。',
                      iconColor: Colors.amberAccent,
                    ),
                    SizedBox(height: 40),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom( // ボタンのスタイルを調整
                          backgroundColor: Colors.white.withOpacity(0.9),
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2193b0), fontFamily: 'CoolFont'), // ← フォントファミリーを指定
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 5,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/difficulty');
                        },
                        child: Text('クイズを始める', style: TextStyle(color: Color(0xFF2193b0), fontFamily: 'CoolFont')), // ← フォントファミリーを指定
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ルールカードを生成するヘルパーウィジェット
Widget _buildRuleCard({required IconData icon, required String text, Color iconColor = Colors.white}) {
  return Card(
    elevation: 6.0,
    margin: EdgeInsets.symmetric(vertical: 10.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15.0),
    ),
    color: Colors.white.withOpacity(0.85), // カードの背景色と透明度
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 32.0, color: iconColor), // アイコンの色を引数で指定可能に
          SizedBox(width: 18.0),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 17, // フォントサイズ調整
                color: Colors.black87, // カード内のテキスト色
                height: 1.5, // 行間調整
                fontFamily: 'CoolFont', // ← フォントファミリーを指定
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
