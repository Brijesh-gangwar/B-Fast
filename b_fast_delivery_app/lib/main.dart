import 'package:b_fast_delivery_app/features/orders/presentation/view_model.dart/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/profile/presentation/view_model/agent_details_provider.dart';
import 'features/dashboard/presentation/screens/home_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/waiting_verification/presentation/screens/waiting_screen.dart'; 
import 'features/auth/data/services/auth_service.dart';
import 'features/profile/data/services/details_service.dart'; 


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AgentDetailsProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delivery Agent App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateUser();
  }

  Future<void> _navigateUser() async {
    // Wait for the splash screen duration
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authService = AuthService();
    final employeeId = await authService.getSavedEmployeeId();

    if (employeeId != null) {
      // User is logged in, so check their license status
      try {
        final detailsService = DetailsService();
        final licenseStatus = await detailsService.checkLicenseStatus();

        if (!mounted) return;

        if (licenseStatus == "Verified") {
          // If verified, navigate to the main HomeScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          // If status is "Pending", "Rejected", or anything else, go to WaitingScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const WaitingHomeScreen()),
          );
        }
      } catch (e) {

        debugPrint("Error checking license status: $e");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WaitingHomeScreen()),
        );
      }
    } else {
      // User is not logged in, navigate to the LoginScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delivery_dining, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              "Delivery Agent",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}