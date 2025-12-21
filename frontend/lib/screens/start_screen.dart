import 'package:flutter/material.dart';
import 'quiz_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("開始")),
      body: SafeArea(
        top: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "選擇要練習的項目\n練習する項目を選択してください",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // 單字
              _buildButton(context, "單字", "word"),
              const SizedBox(height: 20),

              // 語句
              _buildButton(context, "句子", "sentence"),

              const SizedBox(height: 40), // 分隔線
            ],
          ),
        ),
      ),
    );
  }

  // 按鈕樣式封裝
  Widget _buildButton(BuildContext context, String text, String mode) {
    return SizedBox(
      width: 200,
      height: 60,
      child: OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => QuizScreen(mode: mode)),
          );
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }
}
