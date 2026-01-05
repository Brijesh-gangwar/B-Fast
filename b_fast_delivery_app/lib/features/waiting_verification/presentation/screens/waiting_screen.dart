

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../profile/presentation/view_model/agent_details_provider.dart';
import '../widgets/unverified_profile_screen.dart';
import '../widgets/verification_pending_screen.dart';

class WaitingHomeScreen extends StatefulWidget {
  const WaitingHomeScreen({super.key});

  @override
  State<WaitingHomeScreen> createState() => _WaitingHomeScreenState();
}

class _WaitingHomeScreenState extends State<WaitingHomeScreen> {
  int _selectedIndex = 0;

  // The two screens managed by this parent screen
  static const List<Widget> _widgetOptions = <Widget>[
    VerificationScreen(),
    UnverifiedProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // Use context.read for a one-time call within initState.
      context.read<AgentDetailsProvider>().fetchAgentDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.hourglass_empty),
            label: 'Verification',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}