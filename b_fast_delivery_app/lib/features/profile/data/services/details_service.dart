

// lib/services/details_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:b_fast_delivery_app/features/profile/data/models/agent_details_model.dart';
import 'package:b_fast_delivery_app/core/secrets.dart';
import 'package:b_fast_delivery_app/features/auth/data/services/auth_service.dart';

class DetailsService {
  static final DetailsService _instance = DetailsService._internal();
  factory DetailsService() => _instance;
  DetailsService._internal();

  final AuthService authService = AuthService();

  // Fetch agent details by employeeId
  Future<AgentDetailsModel> fetchAgentDetails() async {
    final employeeId = await authService.getSavedEmployeeId();
    if (employeeId == null) {
      throw Exception('Unauthorized');
    }

    final url = Uri.parse('$baseUrl/details?employeeId=$employeeId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return AgentDetailsModel.fromJson(data);
    } else {
      throw Exception('Failed to load agent details');
    }
  }

  // ✅ NEW: Method to update agent status
  Future<void> updateAgentStatus(String status) async {
    final employeeId = await authService.getSavedEmployeeId();
    if (employeeId == null) {
      throw Exception('Unauthorized');
    }

    // Use the specific endpoint for updating the status
    final url = Uri.parse('$baseUrl/update-status');
    
    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'employeeId': employeeId,
      'status': status,
    });

    final response = await http.patch(
      url,
      headers: headers,
      body: body,
    );

    // Check if the request was successful
    if (response.statusCode != 200) {
      throw Exception('Failed to update status: ${response.body}');
    }
  }




  // check license status
  Future<String> checkLicenseStatus() async {
    final employeeId = await authService.getSavedEmployeeId();
    if (employeeId == null) {
      throw Exception('Unauthorized');
    }

    final url = Uri.parse('$baseUrl/license-status?employeeId=$employeeId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['licenseStatus'] ?? '';
    } else {
      throw Exception('Failed to check license status');
    }
  }
}