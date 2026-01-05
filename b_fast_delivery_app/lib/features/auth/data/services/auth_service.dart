
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/secrets.dart';

class AuthService {
  // Singleton instance
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _keyEmployeeId = "employeeId";


  Future<Map<String, dynamic>> login(String email, String employeeId) async {
    final url = Uri.parse("$baseUrl/login");
    final body = jsonEncode({
      "email": email,
      "employeeId": employeeId,
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["success"] == true) {
        // Store employeeId locally upon successful login
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyEmployeeId, data["employeeId"]);

        // Return both success and license status
        return {
          "success": true,
          "licenseStatus": data["licenseStatus"] ?? 'Pending',
        };
      }
    }
    
    // If login fails for any reason, return success as false
    return {"success": false};
  }

  Future<String?> getSavedEmployeeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmployeeId);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyEmployeeId);
  }
}
