import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter_tts/flutter_tts.dart'; // tts
import '../services/api_service.dart';

class QuizScreen extends StatefulWidget {
  final String mode;
  const QuizScreen({super.key, required this.mode});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  final int totalQuestions = 5;
  int score = 0;

  Map<String, dynamic>? currentQuiz;
  bool isLoading = true;
  bool answered = false;
  int? selectedIndex;
  bool selectedWasCorrect = false;

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _ttsLoading = false;

  // 每一題的變數
  List<Map<String, dynamic>> historyDetails = [];
  List<int> hasBeenSeenQuzid = [];

  // final FlutterTts flutterTts = FlutterTts(); // tts

  @override
  void initState() {
    super.initState();
    // initTts(); // tts
    loadNewQuestion();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  /* tts
  void initTts() async {
    await flutterTts.setLanguage("ja-JP");
  }
  */

  void loadNewQuestion() async {
    if (currentQuestionIndex >= totalQuestions) {
      _showResultDialog();
      return;
    }

    setState(() {
      isLoading = true;
      answered = false;
      currentQuiz = null;
      selectedIndex = null;
      selectedWasCorrect = false;
    });

    try {
      var quizData = await ApiService.generateQuiz(widget.mode, "N5");
      while (hasBeenSeenQuzid.contains(quizData['quiz_id'])) {
        quizData = await ApiService.generateQuiz(widget.mode, "N5");
      }

      hasBeenSeenQuzid.add(quizData['quiz_id']);

      if (mounted) {
        setState(() {
          currentQuiz = quizData;
          isLoading = false;
          currentQuestionIndex++;
        });
      }
    } catch (e) {
      print("抓取失敗: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  void playSound() async {
    if (_ttsLoading) return;
    final quiz = currentQuiz;
    if (quiz == null) return;

    final text = (quiz['question'] ?? '').toString();
    if (text.trim().isEmpty) return;

    setState(() => _ttsLoading = true);
    try {
      final bytes = await ApiService.textToSpeechBytes(text);
      await _audioPlayer.stop();
      await _audioPlayer.play(BytesSource(bytes));
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('朗讀失敗：$msg')));
    } finally {
      if (mounted) setState(() => _ttsLoading = false);
    }
  }

  void _showResultDialog() {
    // 測驗結束，呼叫存檔
    ApiService.saveQuizResult(score, totalQuestions, historyDetails);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("練習結束！"),
        content: Text(
          "恭喜你完成了！\n\n得分：$score / $totalQuestions",
          style: const TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE57373),
              ),
              child: const Text("結束", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "測驗中 (${widget.mode == 'word' ? '單字' : '句子'} $currentQuestionIndex/$totalQuestions)",
        ),
      ),
      body: SafeArea(
        top: false,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : currentQuiz == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "連線失敗，請檢查後端",
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: loadNewQuestion,
                      child: const Text("重試"),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      currentQuiz!['question'],
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    // 喇叭
                    if (widget.mode == 'sentence')
                      IconButton(
                        icon: const Icon(
                          Icons.volume_up,
                          color: Colors.white,
                          size: 40,
                        ),
                        onPressed: playSound,
                      ),

                    const Spacer(),

                    ...List.generate(currentQuiz!['options'].length, (index) {
                      var option = currentQuiz!['options'][index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.resolveWith<Color>((
                                    states,
                                  ) {
                                    // 題目已作答：
                                    if (answered) {
                                      // 被點選的按鈕：對=綠、錯=紅
                                      if (selectedIndex == index) {
                                        return option['is_correct']
                                            ? Colors.green
                                            : Colors.red;
                                      }
                                      // 其他按鈕：如果所選是錯的，標示正確答案為綠色，其餘灰色；
                                      // 如果所選是對的，其餘全部灰色。
                                      if (!selectedWasCorrect &&
                                          option['is_correct'] == true) {
                                        return Colors.green;
                                      }
                                      return Colors.grey;
                                    }
                                    // 題目尚未作答：預設主色
                                    return const Color(0xFFE57373);
                                  }),
                              foregroundColor:
                                  WidgetStateProperty.resolveWith<Color>((
                                    states,
                                  ) {
                                    return Colors.white;
                                  }),
                              overlayColor:
                                  WidgetStateProperty.resolveWith<Color?>((
                                    states,
                                  ) {
                                    // Keep ripple subtle on active state; none when disabled
                                    if (states.contains(WidgetState.disabled))
                                      return null;
                                    return Colors.white.withValues(alpha: 0.12);
                                  }),
                            ),
                            onPressed: answered
                                ? null
                                : () {
                                    setState(() {
                                      answered = true;
                                      selectedIndex = index;
                                      selectedWasCorrect =
                                          option['is_correct'] == true;
                                      if (option['is_correct']) score++;

                                      // 記錄這一題的詳細狀況
                                      String correctText = "未知";
                                      try {
                                        var correctOption =
                                            currentQuiz!['options'].firstWhere(
                                              (o) => o['is_correct'] == true,
                                              orElse: () => null,
                                            );
                                        if (correctOption != null) {
                                          correctText = correctOption['text'];
                                        }
                                      } catch (e) {
                                        print("找不到正確答案: $e");
                                      }

                                      historyDetails.add({
                                        "question": currentQuiz!['question'],
                                        "user_answer": option['text'],
                                        "correct_answer": correctText,
                                        "is_correct": option['is_correct'],
                                        "options": currentQuiz!['options'],
                                      });
                                    });
                                    Future.delayed(
                                      const Duration(seconds: 1),
                                      loadNewQuestion,
                                    );
                                  },
                            child: Text(
                              option['text'],
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }
}
