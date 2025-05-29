import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:quizapp/models/quiz_data.dart';

class QuizService {
  static Future<List<QuizQuestion>> loadQuestions(String difficulty) async {
    try {
      // JSONファイルを読み込む
      final String response = await rootBundle.loadString('assets/quiz/${difficulty}_questions.json');
      final data = await json.decode(response);
      final quizData = QuizData.fromJson(data);
      
      // 問題をシャッフル
      final questions = quizData.questions;
      questions.shuffle();
      return questions;
    } catch (e) {
      print('Error loading questions: $e');
      throw Exception('Failed to load quiz questions');
    }
  }
}
