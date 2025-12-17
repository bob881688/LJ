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

  static void setUser(Map<String, dynamic> user) {
    currentUser.value = user;
  }

  static void clear() {
    currentUser.value = null;
  }
}

class loginAuth{
	// http://10.0.2.2:8000
	static const String baseUrl = "http://127.0.0.1:8000";
	
	/// Basic Auth: 以 Authorization: Basic base64(username:password)
  /// 呼叫後端 GET /users/me，成功回傳使用者資料。
  static Future<Map<String, dynamic>> getCurrentUserBasic(
    String username,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/users/me');
    final token = base64Encode(utf8.encode('$username:$password'));
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Basic $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes))
            as Map<String, dynamic>;
      }
      if (response.statusCode == 401) {
        throw Exception('帳號或密碼錯誤');
      }

      throw Exception('登入失敗（${response.statusCode}）');
    
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
