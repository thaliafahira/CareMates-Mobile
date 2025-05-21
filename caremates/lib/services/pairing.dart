import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PairingService {
  static const String baseUrl = 'http://10.0.2.2:8000';
  static final storage = FlutterSecureStorage();

  static Future<int?> pairPatient({
    required String name,
    required String address,
    required String gender,
    required DateTime birthDate,
    required String disease,
  }) async {
    try {
      final token = await storage.read(key: 'access_token');

      if (token == null) {
        throw Exception('Token not found. Please log in again.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/patients/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "nama": name,
          "alamat": address,
          "tanggal_lahir": birthDate.toIso8601String(),
          "jenis_kelamin": gender,
          "penyakit": disease,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return json['id']; // Make sure your FastAPI returns patient.id
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<bool> pairDevice({
    required String serialNumber,
    required String tipe,
    required String status,
  }) async {
    final token = await storage.read(key: 'access_token');

    if (token == null) {
      throw Exception('Token not found. Please log in again.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/devices/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "serial_number": serialNumber,
        "tipe": "gelang",
        "status": "non-aktif",
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> assignPatientToUser(int patientId) async {
    final token = await storage.read(key: 'access_token');

    if (token == null) {
      throw Exception('Token not found. Please log in again.');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/api/v1/patients/assign_patient/$patientId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      // Optional: print error details for debugging
      // print("Failed to assign patient: ${response.statusCode} - ${response.body}");
      return false;
    }
  }
}
