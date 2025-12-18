import 'package:flutter/material.dart';

class PracticeMenuPage extends StatelessWidget {
  const PracticeMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("日語練習選單（練習メニュー）"),
        backgroundColor: Colors.redAccent,
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "請選擇練習類型（練習種類を選んでください）",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // 單字練習
              ElevatedButton(
                onPressed: () {
                  // TODO: 之後接到單字練習頁
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("單字練習頁尚未建立")));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: const Size(double.infinity, 60),
                ),
                child: const Text("單字練習（単語練習）", style: TextStyle(fontSize: 20)),
              ),

              const SizedBox(height: 20),

              // 句子練習
              ElevatedButton(
                onPressed: () {
                  // TODO: 之後接到句子練習頁
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("句子練習頁尚未建立")));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 60),
                ),
                child: const Text("句子練習（文練習）", style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
