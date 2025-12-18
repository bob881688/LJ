// lib/pages/settings_page.dart
import 'package:flutter/material.dart';

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

  final List<String> _levels = ['N5', 'N4', 'N3', 'N2', 'N1'];

  @override
  void dispose() {
    _displayNameCtrl.dispose();
    _emailCtrl.dispose();
    _goalCtrl.dispose();
    super.dispose();
  }

  void _saveSettings() {
    // 這裡做簡單驗證示範，實際要串後端儲存則呼叫 API
    if (_displayNameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('請輸入使用者名稱（ユーザー名を入力してください）')));
      return;
    }

    // 模擬儲存結果
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('設定已儲存（設定を保存しました）')));
    // 若要真正儲存，請在此呼叫後端 API（PUT/POST）
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black45),
            ),
            child: const Icon(Icons.person, size: 42, color: Colors.white24),
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
                      onPressed: () {
                        // 導到帳號編輯或上傳大頭照流程
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('更改大頭照（プロフィール写真を変更）')),
                        );
                      },
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
          const Text('偏好設定（設定）', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          // 日語程度
          Row(
            children: [
              const Expanded(child: Text('日語程度（日本語レベル）')),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _level,
                    items: _levels
                        .map((l) => DropdownMenuItem(value: l, child: Text(l)))
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
          const Text('每日學習時長（毎日の学習時間）'),
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
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // 學習目標
          const Text('學習目標（学習目標）'),
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
            onTap: () => ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('變更密碼（パスワード変更）'))),
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
            onPressed: () => ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('刪除帳號（アカウント削除）請小心操作'))),
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
