
import 'package:flutter/material.dart';
import '../../data/models/agent_details_model.dart';
import '../../data/services/details_service.dart';

class AgentDetailsProvider with ChangeNotifier {
  final DetailsService _detailsService = DetailsService();

  AgentDetailsModel? _agentDetails;
  bool _isLoading = false;
  String? _error;

  AgentDetailsModel? get agentDetails => _agentDetails;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAgentDetails() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _agentDetails = await _detailsService.fetchAgentDetails();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ NEW: Method to update status and notify listeners
  Future<void> updateStatus(String newStatus) async {
    if (_agentDetails == null) return; // Guard clause

    try {
      // Call the service to update the status on the backend
      await _detailsService.updateAgentStatus(newStatus);

      // If successful, update the local state
      _agentDetails!.status = newStatus;

      // Notify all listening widgets to rebuild
      notifyListeners();
      
    } catch (e) {
      // If the API call fails, you can handle the error,
      // for example by showing a snackbar.
      _error = "Failed to update status: $e";
      notifyListeners();
    }
  }



   void incrementDeliveries() {
    // Guard against null agent details
    if (_agentDetails == null) return;

    // Get the current delivery count, defaulting to 0 if null
    final currentDeliveries = _agentDetails!.deliveries ?? 0;
    
    // Update the local agent model
    _agentDetails!.deliveries = currentDeliveries + 1;

    // Notify all listening widgets to rebuild with the new count
    notifyListeners();
  }
}