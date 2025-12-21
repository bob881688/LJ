// lib/pages/settings_page.dart
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/user_session.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // 表單控制項
  final TextEditingController _displayNameCtrl = TextEditingController(
    text: '使用者名稱',
  );
  final TextEditingController _emailCtrl = TextEditingController(
    text: 'user@example.com',
  );
  final TextEditingController _goalCtrl = TextEditingController(
    text: '每天學習 30 分鐘，持續 3 個月（例：毎日30分、3ヶ月継続）',
  );

  String _level = 'N4';
  bool _push = true;
  bool _newsletter = false;
  double _dailyMinutes = 30;
  String _uiLang = '繁體中文（中文／日本語）';
  String? _avatarUrl;
  bool _saving = false;

  final List<String> _levels = ['N5', 'N4', 'N3', 'N2', 'N1'];

  @override
  void initState() {
    super.initState();
    final user = UserSession.currentUser.value;
    final username = (user?['username'] ?? '').toString().trim();
    final email = (user?['email'] ?? '').toString().trim();
    if (username.isNotEmpty) _displayNameCtrl.text = username;
    if (email.isNotEmpty) _emailCtrl.text = email;

    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await ApiService.getUserSettingsPublic();
      if (!mounted) return;

      setState(() {
        _avatarUrl = (settings['avatar_url'] as String?)?.trim();
        _displayNameCtrl.text =
            (settings['display_name'] ?? _displayNameCtrl.text).toString();
        _level = (settings['level'] ?? _level).toString();
        final dm = settings['daily_minutes'];
        if (dm is int) _dailyMinutes = dm.toDouble();
        _goalCtrl.text = (settings['goal'] ?? _goalCtrl.text).toString();
        _uiLang = (settings['ui_lang'] ?? _uiLang).toString();
        final push = settings['push'];
        final newsletter = settings['newsletter'];
        if (push is bool) _push = push;
        if (newsletter is bool) _newsletter = newsletter;
      });

      UserSession.setAvatarUrl(_avatarUrl);
    } catch (e) {
      // 免密碼讀取，失敗時不打擾使用者（保持預設值）
    }
  }

  @override
  void dispose() {
    _displayNameCtrl.dispose();
    _emailCtrl.dispose();
    _goalCtrl.dispose();
    super.dispose();
  }

  Future<String?> _promptPassword({required String title}) async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: ctrl,
            obscureText: true,
            decoration: const InputDecoration(labelText: '密碼'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(ctrl.text),
              child: const Text('確認'),
            ),
          ],
        );
      },
    );
    ctrl.dispose();
    final trimmed = result?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  Future<void> _saveSettings() async {
    if (_saving) return;

    if (_displayNameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('請輸入使用者名稱（ユーザー名を入力してください）')));
      return;
    }

    final password = await _promptPassword(title: '請輸入密碼以儲存設定');
    if (password == null) return;

    setState(() => _saving = true);
    try {
      await ApiService.saveUserSettings(
        password: password,
        payload: {
          'avatar_url': _avatarUrl,
          'display_name': _displayNameCtrl.text.trim(),
          'level': _level,
          'daily_minutes': _dailyMinutes.round(),
          'goal': _goalCtrl.text.trim(),
          'ui_lang': _uiLang,
          'push': _push,
          'newsletter': _newsletter,
        },
      );
      if (!mounted) return;
      UserSession.setAvatarUrl(_avatarUrl);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('設定已儲存（設定を保存しました）')));
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('儲存失敗：$msg')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _changeAvatar() async {
    final ctrl = TextEditingController(text: _avatarUrl ?? '');
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('變更大頭照（URL）'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              labelText: '圖片 URL',
              hintText: 'https://...jpg/png',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(ctrl.text),
              child: const Text('下一步'),
            ),
          ],
        );
      },
    );
    ctrl.dispose();

    final trimmed = url?.trim();
    if (trimmed == null) return;

    final password = await _promptPassword(title: '請輸入密碼以更新大頭照');
    if (password == null) return;

    setState(() {
      _avatarUrl = trimmed.isEmpty ? null : trimmed;
    });

    // 先同步到全域，讓 Drawer 先更新；若儲存失敗會由 Snackbar 告知
    UserSession.setAvatarUrl(_avatarUrl);

    try {
      await ApiService.saveUserSettings(
        password: password,
        payload: {'avatar_url': _avatarUrl},
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('大頭照已更新')));
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('更新失敗：$msg')));
    }
  }

  Future<void> _changePassword() async {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('變更密碼（パスワード変更）'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: '目前密碼'),
              ),
              TextField(
                controller: newCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: '新密碼（至少 6 碼）'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('確認'),
            ),
          ],
        );
      },
    );
    final oldPwd = oldCtrl.text.trim();
    final newPwd = newCtrl.text.trim();
    oldCtrl.dispose();
    newCtrl.dispose();
    if (ok != true) return;
    if (oldPwd.isEmpty || newPwd.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('請輸入完整的密碼欄位')));
      return;
    }

    try {
      await ApiService.changePassword(oldPassword: oldPwd, newPassword: newPwd);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('密碼已更新')));
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('變更失敗：$msg')));
    }
  }

  Future<void> _deleteAccount() async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('刪除帳號（アカウント削除）'),
          content: const Text('此操作無法復原，確定要刪除嗎？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text('刪除'),
            ),
          ],
        );
      },
    );
    if (sure != true) return;

    final password = await _promptPassword(title: '請輸入密碼以刪除帳號');
    if (password == null) return;

    try {
      await ApiService.deleteAccount(password: password);
      if (!mounted) return;
      UserSession.clear();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('刪除失敗：$msg')));
    }
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          // 大頭照（可替換成 assets 圖片）
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey.shade800,
            backgroundImage:
                (_avatarUrl != null && _avatarUrl!.trim().isNotEmpty)
                ? NetworkImage(_avatarUrl!.trim())
                : null,
            child: (_avatarUrl == null || _avatarUrl!.trim().isEmpty)
                ? const Icon(Icons.person, size: 42, color: Colors.white24)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _displayNameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: '使用者名稱（ユーザー名）',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: _emailCtrl,
                  enabled: false,
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: '電子郵件（メール）',
                    labelStyle: TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _changeAvatar,
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: const Text('變更大頭照（写真変更）'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () {
                        // 導到帳號安全頁面（範例）
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('帳號安全（アカウントのセキュリティ）')),
                        );
                      },
                      child: const Text(
                        '帳號安全（アカウント）',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '偏好設定（設定）',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          // 日語程度
          Row(
            children: [
              const Expanded(
                child: Text(
                  '日語程度（日本語レベル）',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _level,
                    style: const TextStyle(color: Colors.white),
                    dropdownColor: const Color(0xFF1A1A1A),
                    iconEnabledColor: Colors.white70,
                    items: _levels
                        .map(
                          (l) => DropdownMenuItem(
                            value: l,
                            child: Text(
                              l,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _level = v);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 每日學習時長
          const Text('每日學習時長（毎日の学習時間）', style: TextStyle(color: Colors.white)),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _dailyMinutes,
                  min: 5,
                  max: 180,
                  divisions: 35,
                  label: '${_dailyMinutes.round()} 分鐘',
                  onChanged: (v) => setState(() => _dailyMinutes = v),
                ),
              ),
              SizedBox(
                width: 70,
                child: Text(
                  '${_dailyMinutes.round()} 分鐘',
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // 學習目標
          const Text('學習目標（学習目標）', style: TextStyle(color: Colors.white)),
          const SizedBox(height: 6),
          TextField(
            controller: _goalCtrl,
            maxLines: 3,
            style: const TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              hintText: '例如：每天背 10 個單字（例：毎日10単語を覚える）',
              hintStyle: const TextStyle(color: Colors.white24),
              filled: true,
              fillColor: const Color(0xFF141414),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('通知（通知）', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('推播通知（プッシュ通知）'),
            subtitle: const Text('學習提醒、每日總結（学習リマインダー・日次サマリ）'),
            value: _push,
            onChanged: (v) => setState(() => _push = v),
          ),
          SwitchListTile(
            title: const Text('電子報（ニュースレター）'),
            subtitle: const Text('最新教學與活動（お知らせ）'),
            value: _newsletter,
            onChanged: (v) => setState(() => _newsletter = v),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '隱私與連結（プライバシー / 連携）',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.lock_outline),
            title: const Text('變更密碼（パスワード変更）'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _changePassword,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.link),
            title: const Text('連結 Google / Apple（連携アカウント）'),
            subtitle: const Text('方便快速登入（シングルサインオン）'),
            trailing: ElevatedButton(
              onPressed: () => ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('連結帳號（アカウント連携）'))),
              child: const Text('連結（連携）'),
            ),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: _deleteAccount,
            child: const Text(
              '刪除帳號（アカウント削除）',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          const Expanded(child: Text('介面語言（表示言語）')),
          DropdownButton<String>(
            value: _uiLang,
            items: const [
              DropdownMenuItem(
                value: '繁體中文（中文／日本語）',
                child: Text('繁體中文（中文／日本語）'),
              ),
              DropdownMenuItem(value: '日本語（日本語）', child: Text('日本語（日本語）')),
              DropdownMenuItem(
                value: 'English（英語）',
                child: Text('English（英語）'),
              ),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _uiLang = v);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('使用者設定（設定）'),
        backgroundColor: const Color(0xFF151515),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 20),
          children: [
            const SizedBox(height: 6),
            _buildProfileCard(),
            _buildPreferenceCard(),
            _buildNotificationCard(),
            _buildLanguageCard(),
            _buildPrivacyCard(),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('儲存設定（設定を保存）'),
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}
