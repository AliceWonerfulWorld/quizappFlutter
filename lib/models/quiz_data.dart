class QuizQuestion {
  final String question;
  final List<String> answers;
  final int correct;
  final String hint;

  QuizQuestion({
    required this.question,
    required this.answers,
    required this.correct,
    required this.hint,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] as String,
      answers: List<String>.from(json['answers']),
      correct: json['correct'] as int,
      hint: json['hint'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'question': question,
    'answers': answers,
    'correct': correct,
    'hint': hint,
  };
}

class QuizData {
  final List<QuizQuestion> questions;

  QuizData({required this.questions});

  factory QuizData.fromJson(Map<String, dynamic> json) {
    var questionsList = json['questions'] as List;
    List<QuizQuestion> questions = questionsList
        .map((questionJson) => QuizQuestion.fromJson(questionJson))
        .toList();
    return QuizData(questions: questions);
  }

  Map<String, dynamic> toJson() => {
    'questions': questions.map((q) => q.toJson()).toList(),
  };
}

class Lifelines {
  bool fiftyFifty;
  bool timeExtension;
  bool hintAvailable;

  Lifelines({
    this.fiftyFifty = true,
    this.timeExtension = true,
    this.hintAvailable = true,
  });

  bool get hasAvailableLifelines => fiftyFifty || timeExtension || hintAvailable;
}

// 追加: ユーザーの回答データを保持するクラス
class AnswerData {
  final bool isCorrect;
  // 必要に応じて、質問IDや選択した回答のインデックスなどを追加できます
  // final String questionId;
  // final int selectedAnswerIndex;

  AnswerData({
    required this.isCorrect,
    // this.questionId,
    // this.selectedAnswerIndex,
  });
}
