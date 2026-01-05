import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/agent_details_provider.dart';

class PersonalInformationScreen extends StatelessWidget {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final agent = context.watch<AgentDetailsProvider>().agentDetails;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Personal Information'),
      ),

      body: agent == null
          ? const Center(child: Text("Agent details not available."))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
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
                      'Zone': agent.zone,
                      'Vehicle Type': agent.vehicleType,
                      'License Status': agent.licenseStatus,
                    },
                  ),
                ],
              ),
            ),
    );
  }

  // A reusable card widget to display sections of information.
  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Map<String, String?> details,
  }) {
    return Card(
      color: Colors.white,
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
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            // Use a Column to list the details from the map.
            ...details.entries.map(
              (entry) => _buildInfoRow(entry.key, entry.value ?? 'N/A'),
            ),
          ],
        ),
      ),
    );
  }

  // A reusable row for displaying a label and its value.
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