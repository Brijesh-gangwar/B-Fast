import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/profile/presentation/view_model/agent_details_provider.dart';

class OnlineStatusToggleCard extends StatelessWidget {
  const OnlineStatusToggleCard({super.key});

  @override
  Widget build(BuildContext context) {

    return Consumer<AgentDetailsProvider>(
      builder: (context, provider, child) {

        final bool isOnline = provider.agentDetails?.status == 'Online';

        return Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.flash_on, color: Colors.amber, size: 30),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Online', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Available for deliveries', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                Switch(
                  value: isOnline,
                  onChanged: (value) {
                    // Determine the new status string
                    final newStatus = value ? 'Online' : 'Offline';

                    context.read<AgentDetailsProvider>().updateStatus(newStatus);
                  },
                  activeColor: isOnline ? Colors.green : Colors.black,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}