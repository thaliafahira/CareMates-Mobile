import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PatientService {
  static const String baseUrl = 'http://10.0.2.2:8000';
  static final storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>?> getMyPatientInfo() async {
    try {
      final token = await storage.read(key: 'access_token');

      if (token == null) {
        throw Exception('Token not found. Please log in again.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/patients/me/patient'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        // print(
        //     "Failed to fetch patient info: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      // print("Error fetching patient info: $e");
      return null;
    }
  }
}
