import 'package:flutter/material.dart';
import '../services/api_service.dart'; // 連到 api_service

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<dynamic> notes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() async {
    final data = await ApiService.getFavorites();
    if (mounted) {
      setState(() {
        notes = data;
        isLoading = false;
      });
    }
  }

  void _showAddDialog() {
    final japaneseController = TextEditingController();
    final meaningController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text("新增語句", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: japaneseController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "日文",
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
            TextField(
              controller: meaningController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "意思 / 筆記",
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("取消", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE57373),
            ),
            onPressed: () async {
              if (japaneseController.text.isNotEmpty) {
                await ApiService.addFavorite(
                  japaneseController.text,
                  meaningController.text,
                );
                Navigator.pop(ctx);
                _loadNotes();
              }
            },
            child: const Text("儲存", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "語句收藏",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text("お気に入り", style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        top: false,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : notes.isEmpty
            ? const Center(
                child: Text("目前沒有收藏", style: TextStyle(color: Colors.grey)),
              )
            : ListView.separated(
                itemCount: notes.length,
                separatorBuilder: (ctx, index) =>
                    const Divider(color: Colors.white24, height: 1),
                itemBuilder: (ctx, index) {
                  final note = notes[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    title: Text(
                      note['japanese'],
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      note['meaning'] ?? "",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFFE57373),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
