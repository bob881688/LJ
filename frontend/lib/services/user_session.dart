import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// 最小的全域登入狀態（in-memory）。
///
/// - 登入成功後把 /users/me 回傳的 user map 存進來
/// - 需要顯示使用者資訊的頁面用 ValueListenableBuilder 監聽
class UserSession {
  static final ValueNotifier<Map<String, dynamic>?> currentUser =
      ValueNotifier<Map<String, dynamic>?>(null);

  // 使用者大頭貼（來自 user_settings.avatar_url）
  static final ValueNotifier<String?> avatarUrl = ValueNotifier<String?>(null);

  static void setUser(Map<String, dynamic> user) {
    currentUser.value = user;
  }

  static void setAvatarUrl(String? url) {
    final trimmed = url?.trim();
    avatarUrl.value = (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  static void clear() {
    currentUser.value = null;
    avatarUrl.value = null;
  }
}

class loginAuth {
  // http://10.0.2.2:8000
  static const String baseUrl = "http://119.14.200.30:8000";

  /// Basic Auth: 以 Authorization: Basic base64(username:password)
  /// 呼叫後端 GET /users/me，成功回傳使用者資料。
  static Future<Map<String, dynamic>> getCurrentUserBasic(
    String username,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/users/me');
    final token = base64Encode(utf8.encode('$username:$password'));
    try {
      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Basic $token',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes))
            as Map<String, dynamic>;
      }
      if (response.statusCode == 401) {
        throw Exception('帳號或密碼錯誤');
      }

      throw Exception('登入失敗（${response.statusCode})');
    } on TimeoutException {
      throw Exception('連線逾時(20 秒)');
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      // 保留明確的錯誤訊息（例如帳密錯誤、非 200 狀態碼），避免 UI 出現「連線錯誤: Exception: ...」
      if (msg == '帳號或密碼錯誤' || msg.startsWith('登入失敗')) {
        throw Exception(msg);
      }
      throw Exception('連線錯誤');
    }
  }
}

class RegisterAuth {
  static const String baseUrl = "http://119.14.200.30:8000";

  Future<void> registerUser(
    String username,
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/users/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }
      if (response.statusCode == 400) {
        throw Exception('該使用者名稱已存在（ユーザー名が既に存在します）');
      }
      if (response.statusCode == 500) {
        throw Exception('伺服器錯誤（サーバーエラー）');
      }

      throw Exception('註冊失敗（${response.statusCode}）');
    } catch (e) {
      throw Exception('${e.toString().replaceAll('Exception: ', '')}');
    }
  }
}
