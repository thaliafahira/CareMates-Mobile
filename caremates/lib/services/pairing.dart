import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PairingService {
  static const String baseUrl = 'http://10.0.2.2:8000';
  static final storage = FlutterSecureStorage();

  static Future<bool> pairPatient({
    required String name,
    required String address,
    required String gender,
    required DateTime birthDate,
    required String disease,
    required String deviceId,
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
        return true;
      } else {
        //print("Failed to pair patient: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      //print("Error during pairing: $e");
      return false;
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
}
