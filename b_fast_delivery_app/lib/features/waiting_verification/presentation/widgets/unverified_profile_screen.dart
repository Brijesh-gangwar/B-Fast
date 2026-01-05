import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../main.dart';
import '../../../profile/presentation/view_model/agent_details_provider.dart';
import '../../../auth/data/services/auth_service.dart';

class UnverifiedProfileScreen extends StatelessWidget {
  const UnverifiedProfileScreen({super.key});

  // Handles logging the user out and navigating to the SplashScreen
  Future<void> _logout(BuildContext context) async {
    final authService = AuthService();
    await authService.logout();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SplashScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use a Consumer to listen to all state changes from the provider
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Profile"),
      ),
      body: Consumer<AgentDetailsProvider>(
        builder: (context, provider, child) {
          // --- STATE 1: LOADING ---
          // Show a loading indicator if the provider is fetching and has no data yet.
          if (provider.isLoading && provider.agentDetails == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- STATE 2: ERROR ---
          // Show an error message if the provider failed and has no data.
          if (provider.error != null && provider.agentDetails == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Error loading profile: ${provider.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          // --- STATE 3: NO DATA ---
          // This is a fallback in case loading is finished but data is still null.
          if (provider.agentDetails == null) {
            return const Center(child: Text("Could not find agent details."));
          }

          // --- STATE 4: SUCCESS ---
          // If we have data, get it from the provider and build the UI.
          final agent = provider.agentDetails!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(
                  title: 'User Details',
                  icon: Icons.person_outline,
                  details: {
                    'Full Name': agent.fullName,
                    'Employee ID': agent.employeeId,
                    'Email': agent.email,
                    'Phone': agent.phone,
                  },
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  title: 'Work Details',
                  icon: Icons.work_outline,
                  details: {
                    'Assigned Zone': agent.zone,
                    'Vehicle Type': agent.vehicleType,
                    'License Status': agent.licenseStatus,
                  },
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0, top: 8.0),
                          child: Text(
                            'Account',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red.shade50,
                            foregroundColor: Colors.red,
                            child: const Icon(Icons.logout),
                          ),
                          title: const Text(
                            'Logout',
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600),
                          ),
                          onTap: () => _logout(context),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // A reusable card widget for displaying sections of information
  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Map<String, String?> details,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            ...details.entries.map(
              (entry) => _buildInfoRow(entry.key, entry.value ?? 'N/A'),
            ),
          ],
        ),
      ),
    );
  }

  // A reusable row for displaying a label and its value
  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}