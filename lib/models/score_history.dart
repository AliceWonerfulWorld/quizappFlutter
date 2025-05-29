class ScoreHistory {
  final int score;
  final int totalQuestions;
  final String difficulty;
  final String date;

  ScoreHistory({
    required this.score,
    required this.totalQuestions,
    required this.difficulty,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'score': score,
      'totalQuestions': totalQuestions,
      'difficulty': difficulty,
      'date': date,
    };
  }

  factory ScoreHistory.fromMap(Map<String, dynamic> map) {
    return ScoreHistory(
      score: map['score'] as int,
      totalQuestions: map['totalQuestions'] as int,
      difficulty: map['difficulty'] as String,
      date: map['date'] as String,
    );
  }
}

List<ScoreHistory> scoreHistoryList = [];
