import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8000'; 

  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Status code: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['access_token'];
        print('Access Token: $accessToken');
        return accessToken != null; // true if token exists
      } else {
        print('Login failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error during login: $e');
      return false;
    }
  }

  static Future<bool> register({
    required String nama,
    required String email,
    required String noTelepon,
    required String password,
    required String role,
  }) async {
    final url = Uri.parse('$baseUrl/api/v1/auth/register');

    try {
      final response = await http.post(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
        },
        body: jsonEncode({
          'nama': nama,
          'email': email,
          'no_telepon': "08123456789",
          'password': password,
          'role': "caregiver",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        print("Registered! Token: $token");
        return true;
      } else {
        print("Register failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Register error: $e");
      throw Exception("Failed to register");
    }
  }
}
