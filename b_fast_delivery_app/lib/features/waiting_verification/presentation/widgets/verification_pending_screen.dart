

import 'package:b_fast_delivery_app/core/helpers/snackbar_fxn.dart';
import 'package:flutter/material.dart';
import '../../../../main.dart'; // Used for navigating back to the SplashScreen
import '../../../profile/data/services/details_service.dart'; // Import the service

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  // State to manage the loading indicator on the button
  bool _isLoading = false;
  final DetailsService _detailsService = DetailsService();

  // This function now contains the core logic for checking the status
  Future<void> _checkStatus() async {
    // Prevent multiple clicks while checking
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Call the service to get the latest license status
      final licenseStatus = await _detailsService.checkLicenseStatus();

      if (!mounted) return; // Always check if the widget is still in the tree

      if (licenseStatus == "Verified") {
        // --- SUCCESS CASE ---
        // If verified, navigate to the SplashScreen to trigger the proper redirect
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SplashScreen()),
          (route) => false,
        );
      } else {
        // --- PENDING CASE ---
        // If not verified, show a SnackBar with feedback
        _showSnackBar("Your profile is still under review. Please try again later.");
      }
    } catch (e) {
      // --- ERROR CASE ---
      // If the API call fails, show an error SnackBar
      _showSnackBar("Could not check status. Please check your network and try again.", isError: true);
      debugPrint("Error checking license status: $e");
    } finally {
      // Ensure the loading state is always turned off
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Helper function to display a SnackBar
  void _showSnackBar(String message, {bool isError = false}) {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(message),
    //     backgroundColor: isError ? Colors.red : Colors.blue,
    //   ),
    // );

    showCustomMessage(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Verification Pending"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hourglass_empty_rounded,
                  size: 60, color: Colors.orange),
              const SizedBox(height: 20),
              const Text(
                'Verification in Progress',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Your documents are being reviewed. You will be able to access the dashboard once your license is verified.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                // The onPressed now calls our new logic function
                // It's disabled when _isLoading is true
                onPressed: _isLoading ? null : _checkStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 50), // Give the button a nice size
                ),
                // The label now changes to a loading indicator
                label: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Check Status Again"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

