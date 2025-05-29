import 'package:flutter/material.dart';
import 'screens/title_screen.dart';
import 'screens/rules_screen.dart';
import 'screens/difficulty_screen.dart';
import 'screens/countdown_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/results_screen.dart';
import 'screens/slot_machine_screen.dart';
import 'screens/scoreboard_screen.dart';
import 'models/score_history.dart';
import 'models/quiz_data.dart'; // QuizQuestion と AnswerData のためにインポート

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'MPLUSRounded1c', // この行を追加
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => TitleScreen(),
        '/rules': (context) => RulesScreen(),
        '/difficulty': (context) => DifficultyScreen(),
        '/slot': (context) => SlotMachineScreen(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/results':
            // `ResultsScreen` の呼び出しを新しいコンストラクタに合わせて更新
            final args = settings.arguments as Map<String, dynamic>; // 想定される引数の型
            return MaterialPageRoute(
              builder: (context) => ResultsScreen(
                questions: args['questions'] as List<QuizQuestion>,
                userAnswers: args['userAnswers'] as List<AnswerData>,
                difficulty: args['difficulty'] as String,
              ),
            );
          case '/countdown':
            final difficulty = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => CountdownScreen(difficulty: difficulty),
            );
          case '/quiz':
            final difficulty = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => QuizScreen(difficulty: difficulty),
            );
          case '/scoreboard':
            return MaterialPageRoute(
              builder: (context) => ScoreboardScreen(scoreHistory: scoreHistoryList),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => TitleScreen(),
            );
        }
      },
    );
  }
}