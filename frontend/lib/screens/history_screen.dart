import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> sessions = []; // 練習場次列表 (練習一、練習二)
  List<dynamic> currentDetails = []; // 當前選中的那場詳細內容
  int? selectedHistoryId; // 目前選中哪一場的 ID
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  // 載入練習場次
  void _loadSessions() async {
    final data = await ApiService.getHistoryList();
    if (mounted) {
      setState(() {
        sessions = data;
        if (sessions.isNotEmpty) {
          // 預設選中第一筆 (最新的)
          _loadDetails(sessions[0]['id']);
        } else {
          isLoading = false;
        }
      });
    }
  }

  // 載入某一次練習的詳細內容 (直向列表)
  void _loadDetails(int historyId) async {
    setState(() {
      selectedHistoryId = historyId;
    });

    // 呼叫後端 API
    final data = await ApiService.getHistoryDetails(historyId);

    if (mounted) {
      setState(() {
        currentDetails = data;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // 深色背景
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "學習紀錄",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            Text("學習履歷", style: TextStyle(fontSize: 14, color: Colors.white70)),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        top: false,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : sessions.isEmpty
            ? const Center(
                child: Text(
                  "目前沒有還練習紀錄，快去測驗吧！",
                  style: TextStyle(color: Colors.white),
                ),
              )
            : Column(
                children: [
                  // 模式選擇
                  Container(
                    height: 92,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal, // 橫向滑動
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: sessions.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (ctx, index) {
                        final session = sessions[index];
                        final isSelected = session['id'] == selectedHistoryId;

                        return GestureDetector(
                          onTap: () => _loadDetails(session['id']),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white24
                                  : Colors.transparent, // 選中時半透明底
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "練習 ${sessions.length - index}\n(${session['score']}/${session['total_questions']})",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  height: 1.15,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const Divider(color: Colors.white24),

                  // 詳細資料
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: currentDetails.length,
                      itemBuilder: (ctx, index) {
                        final detail = currentDetails[index];

                        // 處理選項字串 "A|B|C" -> List
                        // 如果資料庫沒存好 存到空List避免報錯
                        List<String> options = [];
                        if (detail['options'] != null &&
                            detail['options'] != "") {
                          options = (detail['options'] as String).split('|');
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white54),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "第${index + 1}問", // 第幾題
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Center(
                                child: Text(
                                  detail['question'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 15),

                              // 選項列表
                              ...options.map((optText) {
                                // 判斷這一題是使用者選的還是正確答案
                                bool isUserSelected =
                                    optText == detail['user_answer'];
                                bool isCorrect =
                                    optText == detail['correct_answer'];

                                // 外框顏色和圖示
                                Color borderColor = Colors.white;
                                IconData? icon;
                                Color iconColor = Colors.transparent;

                                if (isUserSelected) {
                                  if (isCorrect) {
                                    // 使用者選對了 綠框 綠勾
                                    borderColor = Colors.green;
                                    icon = Icons.check_circle;
                                    iconColor = Colors.green;
                                  } else {
                                    // 使用者選錯了 紅框 紅叉
                                    borderColor = Colors.red;
                                    icon = Icons.cancel;
                                    iconColor = Colors.red;
                                  }
                                } else if (isCorrect) {
                                  // 使用者沒選這個 但是正解 綠框
                                  borderColor = Colors.green;
                                }

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: borderColor,
                                      width: 2,
                                    ),
                                    color: isUserSelected
                                        ? Colors.white10
                                        : Colors.transparent,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          optText,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      if (icon != null)
                                        Icon(icon, color: iconColor),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
