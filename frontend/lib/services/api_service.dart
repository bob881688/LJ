import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_session.dart';

class ApiService {
  static const String baseUrl = "http://119.14.200.30:8000";

  static int _requireCurrentUserId() {
    final user = UserSession.currentUser.value;
    if (user == null) {
      throw Exception('尚未登入');
    }

    final dynamic currendUserId = user['user_id'];
    if (currendUserId != null){
        return currendUserId;
    }
    throw Exception('找不到使用者 ID');
  }

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
    final userId = _requireCurrentUserId();
    final url = Uri.parse('$baseUrl/api/favorites?user_id=$userId');
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
      final userId = _requireCurrentUserId();
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "user_id": userId,
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
    final url = Uri.parse('$baseUrl/api/quiz/save');
    try {
      final userId = _requireCurrentUserId();
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "user_id": userId,
          "score": score,
          "total_questions": total,
          "details": details,
        }),
      );
      if (response.statusCode == 200) {
        print("紀錄存檔成功！");
      } else {
        final bodyText = utf8.decode(response.bodyBytes);
        print("存檔失敗: status=${response.statusCode} body=$bodyText");
      }
    } catch (e) {
      print("存檔失敗: $e");
    }
  }

  static Future<List<dynamic>> getHistoryList() async {
    final userId = _requireCurrentUserId();
    final url = Uri.parse('$baseUrl/api/history/list?user_id=$userId');
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