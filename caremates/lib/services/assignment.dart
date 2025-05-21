import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CaregiverAssignmentService {
  static const String baseUrl = 'http://10.0.2.2:8000';
  static final storage = FlutterSecureStorage();

  // Create a new assignment
  static Future<Map<String, dynamic>?> createAssignment({
    required int patientId,
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    String? description,
  }) async {
    try {
      final token = await storage.read(key: 'access_token');

      if (token == null) {
        throw Exception('Token not found. Please log in again.');
      }

      // Format dates as ISO strings
      final formattedStartDate = startDate.toIso8601String();
      final formattedEndDate = endDate.toIso8601String();

      final Map<String, dynamic> body = {
        'patient_id': patientId,
        'tanggal_mulai': formattedStartDate,
        'tanggal_akhir': formattedEndDate,
        'title': title,
        'description': description ?? '',
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/assignments/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        // print(
        //     "Failed to create assignment: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      // print("Error creating assignment: $e");
      return null;
    }
  }

  // Get all assignments for the logged-in caregiver
  static Future<List<Map<String, dynamic>>?> getAssignments() async {
    try {
      final token = await storage.read(key: 'access_token');

      if (token == null) {
        throw Exception('Token not found. Please log in again.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/assignments/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print(
            "Failed to fetch assignments: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error fetching assignments: $e");
      return null;
    }
  }

  // Get assignments for a specific date
  static Future<List<Map<String, dynamic>>?> getAssignmentsByDate(
      DateTime date) async {
    try {
      final token = await storage.read(key: 'access_token');

      if (token == null) {
        throw Exception('Token not found. Please log in again.');
      }

      // Format the date as YYYY-MM-DD
      final formattedDate =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/assignments/date/$formattedDate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print(
            "Failed to fetch assignments for date: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error fetching assignments for date: $e");
      return null;
    }
  }
}
