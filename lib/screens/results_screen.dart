import 'package:flutter/material.dart';
import '../models/quiz_data.dart'; // QuizQuestion と AnswerData をインポート

class ResultsScreen extends StatelessWidget {
  // final int score; // userAnswers から計算するため削除
  // final int totalQuestions; // questions.length から取得するため削除
  final String difficulty;
  final List<QuizQuestion> questions;
  final List<AnswerData> userAnswers;

  const ResultsScreen({
    Key? key,
    required this.difficulty,
    required this.questions,
    required this.userAnswers,
  }) : super(key: key);

  Widget _getFeedbackIcon(double percentage) {
    if (percentage >= 0.8) {
      return Icon(Icons.sentiment_very_satisfied, color: Colors.green, size: 30);
    } else if (percentage >= 0.5) {
      return Icon(Icons.sentiment_satisfied, color: Colors.blue, size: 30);
    } else {
      return Icon(Icons.sentiment_very_dissatisfied, color: Colors.red, size: 30);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalQuestionsCount = questions.length;
    final int correctAnswers = userAnswers.where((answer) => answer.isCorrect).length;
    final double percentage = totalQuestionsCount > 0 ? correctAnswers / totalQuestionsCount : 0.0;

    String feedbackText;
    Color feedbackColor;

    if (percentage >= 0.8) {
      feedbackText = '素晴らしい！全問正解、またはそれに近いです！';
      feedbackColor = Colors.green.shade700;
    } else if (percentage >= 0.5) {
      feedbackText = 'よくできました！半分以上正解です！';
      feedbackColor = Colors.blue.shade700;
    } else {
      feedbackText = 'もう少し頑張りましょう！';
      feedbackColor = Colors.red.shade700;
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6DD5ED), Color(0xFF2193B0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -30,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'クイズ結果',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black.withOpacity(0.3),
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20), // 変更
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield, color: Colors.yellow.shade700, size: 20),
                            SizedBox(width: 8),
                            Text(
                              '難易度: ${difficulty.toUpperCase()}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 35), // 変更
                    Card(
                      elevation: 12.0, // 変更
                      margin: EdgeInsets.symmetric(horizontal: 16.0), // 変更
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      color: Colors.white.withOpacity(0.95),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
                        child: Column(
                          children: [
                            Text(
                              'スコア',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: Colors.blueGrey.shade700,
                              ),
                            ),
                            SizedBox(height: 15),
                            Text(
                              '$correctAnswers / $totalQuestionsCount',
                              style: TextStyle(
                                fontSize: 72, // 変更
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2193B0),
                                letterSpacing: 2.0, // 追加
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '正解率: ${(percentage * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 24, // 変更
                                color: Colors.blueGrey.shade600,
                                fontWeight: FontWeight.w500, // 追加
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 35), // 変更
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: feedbackColor.withOpacity(0.25), // 透明度を調整 (0.15 -> 0.25)
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: feedbackColor, width: 1.5)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _getFeedbackIcon(percentage),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feedbackText,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w500,
                                color: Colors.white, // 文字色を白に変更
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 50), // 変更
                    ElevatedButton.icon(
                      icon: Icon(Icons.refresh, color: Colors.white),
                      label: Text('もう一度同じ難易度で挑戦', style: TextStyle(fontSize: 18, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
                        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 30), // 変更
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8, // 変更
                      ),
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          '/quiz',
                          arguments: difficulty,
                        );
                      },
                    ),
                    SizedBox(height: 25), // 変更
                    OutlinedButton.icon(
                      icon: Icon(Icons.home, color: Colors.white70),
                      label: Text('タイトルに戻る', style: TextStyle(fontSize: 18, color: Colors.white70)),
                       style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 30), // 変更
                        side: BorderSide(color: Colors.white70, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                      },
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
