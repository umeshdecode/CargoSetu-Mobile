import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static Future<bool> signUp(Map data) async {
    final res = await http.post(
      Uri.parse("https://your-api-url.com/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }
}
