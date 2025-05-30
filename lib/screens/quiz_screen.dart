import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart'; // audioplayersをインポート
import '../models/score_history.dart';
import '../models/quiz_data.dart';
import '../services/quiz_service.dart';
import 'results_screen.dart'; // ResultsScreenをインポート
import '../coin_manager.dart'; // CoinManagerをインポート

class QuizScreen extends StatefulWidget {
  final String difficulty;

  const QuizScreen({
    Key? key,
    required this.difficulty,
  }) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  int _questionIndex = 0;
  int _score = 0;
  bool? _isCorrect;
  List<QuizQuestion> _questions = [];
  Timer? _timer; // late を削除し、nullable に変更
  int _timeRemaining = 10;
  late AnimationController _timerController;
  late String _difficulty;
  int? _selectedAnswerIndex;
  bool _isAnswerLocked = false;
  bool _isLoading = true;
  late Lifelines _lifelines = Lifelines();
  List<int> _hiddenAnswerIndices = [];
  List<AnswerData> _userAnswers = []; // ユーザーの回答履歴
  final AudioPlayer _audioPlayer = AudioPlayer(); // AudioPlayerのインスタンスを追加
  List<String> _shuffledAnswers = []; // シャッフルされた選択肢を保持するリスト

  @override
  void initState() {
    super.initState();
    _difficulty = widget.difficulty;
    _timerController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _getDifficultyTime()),
    )..addListener(() {
        setState(() {});
      });
    
    _initializeQuiz();
  }

  Future<void> _initializeQuiz() async {
    // ModalRouteからのarguments取得は不要。widget.difficultyを使う。
    _questions = await QuizService.loadQuestions(_difficulty);
    _userAnswers = []; // クイズ開始時に回答履歴を初期化
    _shuffleAnswers(); // 最初の質問の選択肢をシャッフル
    setState(() {
      _isLoading = false;
    });
    _startTimer(); // 最初の質問表示時にタイマーを開始
  }

  void _shuffleAnswers() {
    if (_questions.isNotEmpty && _questionIndex < _questions.length) {
      _shuffledAnswers = List<String>.from(_questions[_questionIndex].answers);
      _shuffledAnswers.shuffle();
    }
  }

  void _startTimer() {
    _timer?.cancel(); // 既存のタイマーがあれば停止
    _timeRemaining = 10;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          _timer?.cancel();
          if (!_isAnswerLocked) {
            _handleTimeout();
          }
        }
      });
    });
  }

  void _handleTimeout() {
    _isAnswerLocked = true;
    _userAnswers.add(AnswerData(isCorrect: false)); // タイムアウトは不正解として記録
    _playIncorrectSound(); // 不正解音を再生
    _showAnswerDialog(false);
  }

  int _getDifficultyTime() {
    switch (_difficulty) {
      case 'easy':
        return 15;
      case 'medium':
        return 10;
      case 'hard':
        return 7;
      default:
        return 10;
    }
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

  void _answerQuestion(int index) {
    if (_isAnswerLocked) return;
    
    _isAnswerLocked = true;
    _timer?.cancel();
    _timerController.stop();
    _selectedAnswerIndex = index; // ユーザーが選択した、シャッフル後のリストにおけるインデックス
    
    // ユーザーが選択した回答のテキスト（シャッフル後のリストから取得）
    String userAnswerText = _shuffledAnswers[index];
    
    // 正解の回答テキスト（元の問題データから取得）
    // _questions[_questionIndex].correct は、元のanswersリストにおける正解のインデックス
    String correctAnswerText = _questions[_questionIndex].answers[_questions[_questionIndex].correct];
    
    _isCorrect = (userAnswerText == correctAnswerText);

    _userAnswers.add(AnswerData(isCorrect: _isCorrect!)); // 回答結果を記録
    if (_isCorrect!) {
      _score++;
      _playCorrectSound(); // 正解音を再生
    } else {
      _playIncorrectSound(); // 不正解音を再生
    }
    
    setState(() {});
    
    Future.delayed(Duration(milliseconds: 500), () {
      _showAnswerDialog(_isCorrect!);
    });
  }

  void _showAnswerDialog(bool isCorrect) {
    String correctAnswer = _questions[_questionIndex].answers[_questions[_questionIndex].correct];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          elevation: 8,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              gradient: LinearGradient(
                colors: isCorrect
                    ? [Colors.green.shade300, Colors.green.shade600]
                    : [Colors.red.shade300, Colors.red.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  isCorrect ? '正解！' : '不正解',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'MPLUSRounded1c',
                  ),
                ),
                SizedBox(height: 20),
                Icon(
                  isCorrect ? Icons.check_circle_outline_rounded : Icons.highlight_off_rounded,
                  color: Colors.white,
                  size: 80,
                ),
                SizedBox(height: 20),
                if (!isCorrect)
                  Text(
                    '正解は: $correctAnswer',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                      fontFamily: 'MPLUSRounded1c',
                    ),
                  ),
                SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _questionIndex++;
                      _isAnswerLocked = false;
                      _selectedAnswerIndex = null;
                      _hiddenAnswerIndices = []; // 50:50の効果をリセット
                      if (_questionIndex >= _questions.length) {
                        _saveScore();
                        _finishQuiz();
                      } else {
                        _shuffleAnswers(); // 次の質問の選択肢をシャッフル
                        _startTimer();
                      }
                    });
                  },
                  child: Text(
                    '次へ',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'MPLUSRounded1c',
                      fontWeight: FontWeight.bold,
                      color: isCorrect ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // nullチェックを追加
    _timerController.dispose();
    _audioPlayer.dispose(); // AudioPlayerのリソースを解放
    super.dispose();
  }
  void _saveScore() {
    final now = DateTime.now();
    final scoreEntry = ScoreHistory(
      score: _score,
      totalQuestions: _questions.length,
      difficulty: _difficulty,
      date: '${now.year}/${now.month}/${now.day} ${now.hour}:${now.minute}:${now.second}',
    );

    scoreHistoryList.add(scoreEntry);
  }

  Future<void> _playCorrectSound() async {
    await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
  }

  Future<void> _playIncorrectSound() async {
    await _audioPlayer.play(AssetSource('sounds/incorrect.mp3'));
  }

  Future<void> _finishQuiz() async { // Future<void> に変更し、async を追加
    _timer?.cancel();

    // コイン計算
    int earnedCoins = _score * 5; // 1問正解あたり5コイン
    if (_score == _questions.length && _questions.isNotEmpty) {
      earnedCoins += 50; // 全問正解ボーナス
    }

    if (earnedCoins > 0) {
      await CoinManager.addCoins(earnedCoins); // CoinManagerを使用してコインを追加
    }

    // 結果画面へ遷移
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsScreen(
          questions: _questions,
          userAnswers: _userAnswers,
          difficulty: _difficulty,
        ),
      ),
    );
  }

  // ライフライン: 50:50を使用
  void _useFiftyFifty() {
    if (!_lifelines.fiftyFifty) return;

    setState(() {
      _lifelines.fiftyFifty = false;
      // 正解の選択肢のテキストを取得
      String correctAnswerText = _questions[_questionIndex].answers[_questions[_questionIndex].correct];
      
      // シャッフルされた選択肢の中から、正解ではない選択肢のインデックスを取得
      List<int> wrongAnswerIndicesInShuffled = [];
      for (int i = 0; i < _shuffledAnswers.length; i++) {
        if (_shuffledAnswers[i] != correctAnswerText) {
          wrongAnswerIndicesInShuffled.add(i);
        }
      }
      wrongAnswerIndicesInShuffled.shuffle();
      // _hiddenAnswerIndices には、シャッフル後のリストにおけるインデックスを保存する
      _hiddenAnswerIndices = wrongAnswerIndicesInShuffled.take(2).toList();
    });
  }

  // ライフライン: 時間延長
  void _useTimeExtension() {
    if (!_lifelines.timeExtension) return;

    setState(() {
      _lifelines.timeExtension = false;
      _timeRemaining += 10;
      _timerController.duration = Duration(seconds: _timeRemaining);
      _timerController.forward(from: 1 - (_timeRemaining / _getDifficultyTime()));
    });
  }

  // ライフライン: ヒント表示
  void _showHint() {
    if (!_lifelines.hintAvailable) return;
    
    setState(() {
      _lifelines.hintAvailable = false;
    });
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber),
              SizedBox(width: 10),
              Text('ヒント'),
            ],
          ),
          content: Text(_questions[_questionIndex].hint),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

  // ライフラインボタンを構築
  Widget _buildLifelineButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLifelineButton(
          icon: Icons.remove_circle_outline,
          onPressed: _lifelines.fiftyFifty ? _useFiftyFifty : null,
          tooltip: '50:50',
        ),
        SizedBox(width: 20),
        _buildLifelineButton(
          icon: Icons.timer,
          onPressed: _lifelines.timeExtension ? _useTimeExtension : null,
          tooltip: '+10秒',
        ),
        SizedBox(width: 20),
        _buildLifelineButton(
          icon: Icons.lightbulb_outline,
          onPressed: _lifelines.hintAvailable ? _showHint : null,
          tooltip: 'ヒント',
        ),
      ],
    );
  }

  Widget _buildLifelineButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
  }) {
    final isAvailable = onPressed != null;
    return Tooltip(
      message: tooltip,
      child: Material(
        elevation: isAvailable ? 4 : 0,
        borderRadius: BorderRadius.circular(20),
        color: isAvailable ? Colors.white.withOpacity(0.9) : Colors.white.withOpacity(0.3),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.all(12),
            child: Icon(
              icon,
              color: isAvailable ? _getDifficultyColor() : Colors.grey,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool? shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('クイズを終了しますか？'),
            content: Text('進行中のクイズが終了し、スコアは保存されません。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('キャンセル'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('終了'),
              ),
            ],
          ),
        );
        return shouldExit ?? false;
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
            onPressed: () async {
              bool? shouldReturn = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    elevation: 8,
                    backgroundColor: Colors.transparent,
                    child: Container(
                      padding: EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        gradient: LinearGradient(
                          colors: [Color(0xFFF857A6), Color(0xFFFF5858)], // 警告や注意を促すようなグラデーション
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
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.exit_to_app_rounded, // 終了や戻るを連想させるアイコン
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
                            'タイトルに戻りますか？\n進行中のクイズが終了し、スコアは保存されません。',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 17,
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
                                onPressed: () => Navigator.of(context).pop(false),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 5,
                                ),
                                child: Text(
                                  'タイトルに戻る',
                                  style: TextStyle(
                                    color: Color(0xFFF857A6), // グラデーションに合わせた色
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'MPLUSRounded1c',
                                  ),
                                ),
                                onPressed: () => Navigator.of(context).pop(true),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
              if (shouldReturn == true) {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
          ),
        ),
        body: SafeArea(
          child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _questionIndex >= _questions.length // ★ 修正: クイズが終了したかどうかのチェックを追加
                ? Center(child: CircularProgressIndicator()) // クイズ終了後の遷移待ちの間はローディング表示
                : Stack(
                    children: [
                      // 背景グラデーション＋装飾
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF4A148C), // deep purple
                              Color(0xFF1976D2), // blue
                              Color(0xFF26A69A), // teal
                            ],
                          ),
                        ),
                      ),
                      // 半透明の円や波模様を重ねる
                      Positioned(
                        top: -80,
                        left: -80,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -60,
                        right: -60,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.10),
                          ),
                        ),
                      ),
                      // メインコンテンツ
                      Column(
                        children: [
                          _buildProgressBar(),
                          SizedBox(height: 10),
                          _buildTimer(),
                          SizedBox(height: 20),
                          _buildLifelineButtons(),
                          SizedBox(height: 20),
                          _buildQuestionCard(),
                          SizedBox(height: 20),
                          _buildAnswerOptions(),
                        ],
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    if (_questions.isEmpty || _questionIndex >= _questions.length) return SizedBox.shrink(); // ★ 修正: 範囲外アクセスの防止
    return Container(
      height: 10,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Flexible(
            flex: _questionIndex + 1,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_getDifficultyColor(), _getDifficultyColor().withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Flexible(
            flex: _questions.length - (_questionIndex + 1),
            child: Container(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimer() {
    if (_questions.isEmpty || _questionIndex >= _questions.length) return SizedBox.shrink(); // ★ 修正: 範囲外アクセスの防止
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 60,
              width: 60,
              child: CircularProgressIndicator(
                value: 1 - _timerController.value,
                backgroundColor: Colors.white24,
                color: _timeRemaining > 3 ? _getDifficultyColor() : Colors.red,
                strokeWidth: 8,
              ),
            ),
            Text(
              '$_timeRemaining',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'MPLUSRounded1c', // Updated font
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Text(
          '問題 ${_questionIndex + 1}/${_questions.length}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'MPLUSRounded1c', // Updated font
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard() {
    if (_questions.isEmpty || _questionIndex >= _questions.length) return SizedBox.shrink(); // ★ 修正: 範囲外アクセスの防止
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          _questions[_questionIndex].question,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
            height: 1.5,
            fontFamily: 'MPLUSRounded1c', // Updated font
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildAnswerOptions() {
    if (_questions.isEmpty || _questionIndex >= _questions.length || _shuffledAnswers.isEmpty) return SizedBox.shrink(); // ★ 修正: 範囲外アクセスと空リストの防止
    // final answers = _questions[_questionIndex].answers; // 削除: _shuffledAnswers を使用
    return Expanded(
      child: ListView.builder(
        itemCount: _shuffledAnswers.length, // 修正: _shuffledAnswers の長さを参照
        itemBuilder: (context, index) {
          if (_hiddenAnswerIndices.contains(index)) {
            return SizedBox.shrink(); // 50:50で隠された選択肢
          }

          final bool isSelected = _selectedAnswerIndex == index;
          final bool showResult = _isAnswerLocked && isSelected;
          // final bool isCorrect = index == _questions[_questionIndex].correct; // 削除: この判定はシャッフルに対応していない
          
          Color? cardColor;
          if (showResult) {
            // 修正: state変数 _isCorrect を使用して、ユーザーの選択が正しかったかどうかに基づいて色を決定
            cardColor = _isCorrect! ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3);
          } else {
            cardColor = Colors.white.withOpacity(0.9);
          }

          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Card(
              elevation: isSelected ? 8 : 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: isSelected ? _getDifficultyColor() : Colors.transparent,
                  width: 2,
                ),
              ),
              color: cardColor,
              child: InkWell(
                onTap: _isAnswerLocked ? null : () => _answerQuestion(index),
                borderRadius: BorderRadius.circular(15),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: _getDifficultyColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + index),
                            style: TextStyle(
                              color: _getDifficultyColor(),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'MPLUSRounded1c', // Updated font
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _shuffledAnswers[index], // 修正: シャッフルされた選択肢のテキストを表示
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[800],
                            fontFamily: 'MPLUSRounded1c', // Updated font
                          ),
                        ),
                      ),
                      if (showResult)
                        Icon(
                          // 修正: state変数 _isCorrect を使用してアイコンを決定
                          _isCorrect! ? Icons.check_circle : Icons.cancel,
                          // 修正: state変数 _isCorrect を使用してアイコンの色を決定
                          color: _isCorrect! ? Colors.green : Colors.red,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
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
}
