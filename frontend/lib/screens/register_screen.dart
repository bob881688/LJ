import 'package:flutter/material.dart';
import '../services/user_session.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pw = TextEditingController();
  final _pw2 = TextEditingController();
  bool _loading = false;
  String? _msg;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('註冊（登録）')),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: '使用者名稱（ユーザー名）'),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _email,
                decoration: const InputDecoration(labelText: '電子郵件（メール）'),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _pw,
                obscureText: true,
                decoration: const InputDecoration(labelText: '密碼（パスワード）'),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _pw2,
                obscureText: true,
                decoration: const InputDecoration(labelText: '確認密碼（確認パスワード）'),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              if (_msg != null)
                Text(_msg!, style: const TextStyle(color: Colors.greenAccent)),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _onRegister,
                      child: const Text('完成註冊（登録する）'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _onRegister() async {
    if (_name.text.trim().isEmpty ||
        _email.text.trim().isEmpty ||
        _pw.text.isEmpty) {
      setState(() => _msg = '請填完整資料（全て入力してください）');
      return;
    }
    if (_pw.text != _pw2.text) {
      setState(() => _msg = '密碼不一致（パスワードが一致しません）');
      return;
    }
    setState(() {
      _loading = true;
      _msg = null;
    });

    try{
      await RegisterAuth().registerUser(_name.text.trim(), _email.text.trim(), _pw.text);
    }catch(e){
      setState(() {
        _loading = false;
        _msg = e.toString().replaceAll('Exception: ', '');
      });

      return;
    }

    setState(() {
      _loading = false;
      _msg = '註冊完成，請登入（登録完了、ログインしてください）';
    });

    Future.delayed(
      const Duration(seconds: 1),
      () => Navigator.pushReplacementNamed(context, '/login'),
    );
  }
}
