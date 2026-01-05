


import 'package:flutter/material.dart';

import '../../../../core/helpers/snackbar_fxn.dart';
import '../../data/services/auth_service.dart';
import '../../../dashboard/presentation/screens/home_screen.dart';

import '../../../waiting_verification/presentation/screens/waiting_screen.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = AuthService();
      // 1. Get the result map from the login service
      final loginResult = await authService.login(
        _emailController.text.trim(),
        _employeeIdController.text.trim(),
      );

      if (loginResult["success"] == true) {
        if (!mounted) return;
        
        showCustomMessage(context, "Login successful ✅");
        
        // 2. Check the licenseStatus to determine navigation
        if (loginResult["licenseStatus"] == "Verified") {
          // Navigate to the main dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          // Navigate to the waiting screen for unverified users
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const WaitingHomeScreen()),
          );
        }
      } else {
        setState(() => _errorMessage = "Invalid credentials. Please try again.");
      }
    } catch (e) {
      setState(() => _errorMessage = "An error occurred: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // ✅ UI: Set a clean background color
      backgroundColor: Colors.white,
      // ✅ UI: Use SafeArea instead of AppBar
      body: SafeArea(
        // ✅ UI: Make screen scrollable to avoid keyboard overflow
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              // ✅ UI: Make children stretch to fill width
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Header ---
                const SizedBox(height: 40),
                const Icon(
                  Icons.local_shipping_outlined,
                  size: 80,
                  color: Colors.black87,
                ),
                const SizedBox(height: 24),
                Text(
                  "Welcome, Agent",
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Sign in to your account to continue",
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium
                      ?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 40),

                // --- Email Field ---
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none, // No visible border
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Enter your email" : null,
                ),
                const SizedBox(height: 16),

                // --- Employee ID Field ---
                TextFormField(
                  controller: _employeeIdController,
                  decoration: InputDecoration(
                    labelText: "Employee ID",
                    prefixIcon: const Icon(Icons.badge_outlined),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? "Enter your employee ID"
                      : null,
                ),
                const SizedBox(height: 24),

                // --- Error Message ---
                if (_errorMessage != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                                color: Colors.red, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // --- Login Button ---
                ElevatedButton(
                  // ✅ UI: Disable button when loading
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  // ✅ UI: Show loading indicator inside the button
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}