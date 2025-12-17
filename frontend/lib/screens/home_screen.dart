// lib/pages/home_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/user_session.dart';

import 'start_screen.dart';
import 'favorites_screen.dart';
import 'history_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _News {
  final String title, summary, url, image;
  final DateTime published;
  _News(this.title, this.summary, this.url, this.image, this.published);
}

class _HomePageState extends State<HomePage> {
  final List<_News> _list = [];
  bool _loading = false;
  String _filter = '全部（全て）';
  final List<String> _chips = ['全部（全て）', '政治（政治）', '經濟（経済）', '文化（文化）', '旅遊（旅行）'];

  @override
  void initState() {
    super.initState();
    _loadMock();
  }

  Future<void> _loadMock() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 400));
    final now = DateTime.now();
    _list.clear();
    // 若有 assets 圖，可把 image 改為 'assets/images/news1.jpg'
    for (var i = 0; i < 10; i++) {
      _list.add(_News(
        '【示範】今日新聞標題 ${i + 1}（見出し）',
        '這是第${i + 1}篇新聞的摘要，摘要會顯示最多三行來預覽內容，方便使用者快速掃描。長文字會被截斷顯示 …',
        'https://www.example.com/news/${i + 1}',
        '', // image URL 或 assets path（留空顯示預設色塊）
        now.subtract(Duration(hours: i * 2)),
      ));
    }
    setState(() => _loading = false);
  }

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('無效的連結')));
      return;
    }
    try {
      final can = await canLaunchUrl(uri);
      if (can) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('無法開啟連結')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('開啟連結失敗')));
    }
  }

  Widget _buildTopBar() {
    final today = DateTime.now();
    final dateText = '${today.year}/${today.month.toString().padLeft(2, '0')}/${today.day.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        const Icon(Icons.newspaper, size: 28, color: Colors.white70),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
              '今日日本新聞',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              )
          ),
          const SizedBox(height: 2),
          Text('$dateText （本日）', style: const TextStyle(fontSize: 12, color: Colors.white54)),
        ]),
        const Spacer(),
        IconButton(
          onPressed: _loadMock,
          icon: const Icon(Icons.refresh_outlined),
          tooltip: '更新（更新）',
        )
      ]),
    );
  }

  Widget _buildChips() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, idx) {
          final label = _chips[idx];
          final selected = label == _filter;
          return ChoiceChip(
            label: Text(label, style: TextStyle(color: selected ? Colors.black : Colors.white70)),
            selected: selected,
            onSelected: (v) {
              setState(() => _filter = label);
              // 真正串後端時在這裡改參數重新抓取
            },
            backgroundColor: const Color(0xFF2A2A2A),
            selectedColor: Colors.amberAccent,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: _chips.length,
      ),
    );
  }

  Widget _buildHeroCard(_News n) {
    // 大卡樣式（PageView）
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: const Color(0xFF2D2D2D)),
      ),
      child: InkWell(
        onTap: () => _open(n.url),
        borderRadius: BorderRadius.circular(14),
        child: Row(children: [
          // 圖片或色塊
          Container(
            width: 140,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), bottomLeft: Radius.circular(14)),
              color: n.image.isNotEmpty ? null : Colors.grey.shade800,
              image: n.image.isNotEmpty ? DecorationImage(image: AssetImage(n.image), fit: BoxFit.cover) : null,
            ),
            child: n.image.isEmpty
                ? const Center(child: Icon(Icons.image, size: 42, color: Colors.white24))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(n.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text(n.summary, style: const TextStyle(color: Colors.white70), maxLines: 3, overflow: TextOverflow.ellipsis),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${n.published.hour.toString().padLeft(2,'0')}:${n.published.minute.toString().padLeft(2,'0')}', style: const TextStyle(fontSize: 12, color: Colors.white38)),
                    Row(children: [
                      TextButton(
                        onPressed: () => _open(n.url),
                        child: const Text('原文（原文を開く）'),
                      ),
                      const SizedBox(width: 6),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                        child: const Text('收藏（保存）'),
                      ),
                    ]),
                  ],
                )
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildRecommendList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(children: List.generate(4, (i) {
        return Card(
          color: const Color(0xFF171717),
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            leading: Container(width: 64, height: 64, decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.play_circle_outline, color: Colors.white30)),
            title: Text('推薦影片標題 ${i + 1}（おすすめ）', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
            subtitle: const Text('短描述（短い説明）', style: TextStyle(color: Colors.white70)),
            trailing: ElevatedButton(onPressed: () {}, child: const Text('觀看（見る）')),
          ),
        );
      })),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: const Color(0xFF1A1A1A),
        child: SafeArea(
          child: Column(children: [
            ValueListenableBuilder<Map<String, dynamic>?>(
              valueListenable: UserSession.currentUser,
              builder: (context, user, _) {
                final username = (user?['username'] as String?)?.trim();
                final email = (user?['email'] as String?)?.trim();
                return UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(color: Colors.transparent),
                  currentAccountPicture: const CircleAvatar(child: Icon(Icons.person)),
                  accountName: Text(username?.isNotEmpty == true ? username! : '使用者名稱（ユーザー名）'),
                  accountEmail: Text(email?.isNotEmpty == true ? email! : '未登入（未ログイン）'),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.rocket_launch, color: Colors.white), // 白色圖示
              title: const Text('開始練習（始める）', style: TextStyle(color: Colors.white)), // 白色文字
              onTap: () {
                Navigator.pop(context); // 關選單
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StartScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.book, color: Colors.white),
              title: const Text('語句收藏（保存した例文）', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FavoritesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.white),
              title: const Text('學習紀錄（学習履歴）', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(leading: const Icon(Icons.settings, color: Colors.white), title: const Text('使用者設定（設定）', style: TextStyle(color: Colors.white)), onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            }),
            ListTile(leading: const Icon(Icons.info, color: Colors.white), title: const Text('關於（このアプリについて）', style: TextStyle(color: Colors.white)), onTap: () {}),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, minimumSize: const Size.fromHeight(48)),
                onPressed: () {
                  UserSession.clear();
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                },
                child: const Text('登出（ログアウト）'),
              ),
            )
          ]),
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFF151515),
        elevation: 0,
        title: const Text('LJ'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search), tooltip: '搜尋（検索）'),
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list), tooltip: '篩選（フィルター）'),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadMock,
        child: ListView(
          children: [
            const SizedBox(height: 8),
            _buildTopBar(),
            const SizedBox(height: 8),
            _buildChips(),
            const SizedBox(height: 12),
            // 橫向大卡（PageView）
            SizedBox(
              height: 200,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.92),
                itemCount: _list.length,
                itemBuilder: (context, idx) {
                  final n = _list[idx];
                  return _buildHeroCard(n);
                },
              ),
            ),
            const SizedBox(height: 10),
            // 推薦標題
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('推薦（おすすめ）', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white70)),
            ),
            _buildRecommendList(),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('更多新聞（もっとニュース）', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white70)),
            ),
            // 列表
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                children: _list.map((n) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    tileColor: const Color(0xFF0F0F0F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                    subtitle: Text(n.summary, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70)),
                    trailing: TextButton(onPressed: () => _open(n.url), child: const Text('原文（原文）', style: TextStyle(color: Color.fromARGB(179, 115, 1, 138)))),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
