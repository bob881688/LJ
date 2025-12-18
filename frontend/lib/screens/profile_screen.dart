import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 假資料，之後可改成從後端拿 user 資訊顯示
    const username = '使用者 (範例)';
    const email = 'you@example.com';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            const SizedBox(height: 12),
            Text(
              username,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(email, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('設定'),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.help),
                title: const Text('說明與支援'),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // 登出：回到封面（或登入頁）
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text('登出'),
            ),
          ],
        ),
      ),
    );
  }
}
