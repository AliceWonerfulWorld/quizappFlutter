import 'package:flutter/material.dart';
import '../models/score_history.dart';

class ScoreboardScreen extends StatelessWidget {
  final List<ScoreHistory> scoreHistory;

  const ScoreboardScreen({
    Key? key,
    this.scoreHistory = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade800, Colors.blue.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'スコアボード',
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
                SizedBox(height: 30),
                Expanded(
                  child: scoreHistory.isEmpty
                      ? Center(
                          child: Text(
                            'まだスコアがありません。\nクイズに挑戦してスコアを記録しましょう！',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          itemCount: scoreHistory.length,
                          itemBuilder: (context, index) {
                            final score = scoreHistory[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              color: Colors.white.withOpacity(0.9),
                              elevation: 4,
                              child: ListTile(
                                leading: Icon(
                                  Icons.emoji_events,
                                  color: _getDifficultyColor(score.difficulty),
                                  size: 32,
                                ),
                                title: Text(
                                  '${score.score}/${score.totalQuestions}点',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '難易度: ${_getDifficultyText(score.difficulty)}\n${score.date}',
                                ),
                                trailing: Text(
                                  '${(score.score / score.totalQuestions * 100).toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _getScoreColor(score.score / score.totalQuestions),
                                  ),
                                ),
                              ),
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

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
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

  String _getDifficultyText(String difficulty) {
    switch (difficulty) {
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

  Color _getScoreColor(double percentage) {
    if (percentage >= 0.8) {
      return Colors.green;
    } else if (percentage >= 0.6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
