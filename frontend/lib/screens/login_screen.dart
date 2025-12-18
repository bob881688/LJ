import 'package:flutter/material.dart';
import '../services/user_session.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _username = TextEditingController();
  final _pw = TextEditingController();
  bool _loading = false;
  bool _obscurePw = true;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('登入（ログイン）')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          TextField(controller: _username, decoration: const InputDecoration(labelText: '使用者名稱（ユーザー名）'), keyboardType: TextInputType.emailAddress, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 12),
          TextField(
            controller: _pw,
            obscureText: _obscurePw,
            decoration: InputDecoration(
              labelText: '密碼（パスワード）',
              suffixIcon: IconButton(
                tooltip: _obscurePw ? '顯示密碼' : '隱藏密碼',
                icon: Icon(
                  _obscurePw ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white70,
                ),
                onPressed: () => setState(() => _obscurePw = !_obscurePw),
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 18),
          if (_error != null) Text(_error!, style: const TextStyle(color: Colors.redAccent)),
          const SizedBox(height: 6),
          _loading ? const CircularProgressIndicator() : ElevatedButton(
            onPressed: _onLogin,
            child: const Text('登入（ログイン）'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: () => Navigator.pushNamed(context, '/register'), child: const Text('註冊（登録）')),
          const SizedBox(height: 20),
          // 測試用按鈕：直接到 Home
          TextButton(onPressed: () => Navigator.pushReplacementNamed(context, '/home'), child: const Text('前往首頁（テスト）')),
        ]),
      ),
    );
  }

  void _onLogin() async {
    final username = _username.text.trim();
    final pw = _pw.text;
    if (username.isEmpty || pw.isEmpty) {
      setState(() => _error = '請輸入帳號與密碼（入力してください）');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 後端 /users/me 目前是用 Basic Auth 的 username:password
      // 這裡先把輸入欄位當成 username 使用。
      final user = await loginAuth.getCurrentUserBasic(username, pw);
      UserSession.setUser(user);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
