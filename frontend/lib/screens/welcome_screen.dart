import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('NihongoGo', style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('AI 日語學習助教（AI 日本語学習アシスタント）', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 36),
            Container(
              width: 320,
              height: 380,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10)],
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
                Icon(Icons.school, size: 96, color: Colors.white24),
                SizedBox(height: 12),
                Text('個人化推薦 • 即時回饋', style: TextStyle(color: Colors.white70)),
                SizedBox(height: 6),
                Text('學習新聞、影片、例句（ニュース・動画・例文）', style: TextStyle(color: Colors.white54)),
              ]),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(220, 50), backgroundColor: Colors.redAccent),
              child: const Text('登入（ログイン）'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(220, 50)),
              child: const Text('註冊（登録）', style: TextStyle(color: Colors.white)),
            ),
          ]),
        ),
      ),
    );
  }
}
