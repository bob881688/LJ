import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://119.14.200.30:8000";

  // 設定使用者 ID (目前寫死為 "1")
  static const String currentUserId = "1";

  // 練習
  static Future<Map<String, dynamic>> generateQuiz(String type, String level) async {
    final url = Uri.parse('$baseUrl/api/quiz/generate?type=$type&level=$level');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('載入失敗');
      }
    } catch (e) {
      throw Exception('連線錯誤: $e');
    }
  }

  // 語句收藏
  static Future<List<dynamic>> getFavorites() async {
    final url = Uri.parse('$baseUrl/api/favorites?user_id=$currentUserId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> addFavorite(String japanese, String meaning) async {
    final url = Uri.parse('$baseUrl/api/favorites/add');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "user_id": currentUserId,
          "japanese": japanese,
          "meaning": meaning,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 學習紀錄
  static Future<void> saveQuizResult(int score, int total, List<Map<String, dynamic>> details) async {
    final url = Uri.parse('$baseUrl/api/history/save');
    try {
      await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "user_id": currentUserId,
          "score": score,
          "total_questions": total,
          "details": details,
        }),
      );
      print("紀錄存檔成功！");
    } catch (e) {
      print("存檔失敗: $e");
    }
  }

  static Future<List<dynamic>> getHistoryList() async {
    final url = Uri.parse('$baseUrl/api/history/list?user_id=$currentUserId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      print("取得列表失敗: $e");
    }
    return [];
  }

  static Future<List<dynamic>> getHistoryDetails(int historyId) async {
    final url = Uri.parse('$baseUrl/api/history/details/$historyId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      print("取得詳細失敗: $e");
    }
    return [];
  }
}