// lib/main.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:b_fast_user_app/providers/order_provider.dart';
import 'package:b_fast_user_app/screens/main_screen.dart';
import 'package:b_fast_user_app/secrets.dart';
import 'package:b_fast_user_app/widgets/profile/user_form_screen.dart';
import 'providers/cart_provider.dart';
import 'providers/user_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/product_provider.dart';
import 'providers/address_provider.dart';
import 'screens/auth/walkthrough_screen.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authService = AuthService();
  final userId = await authService.getUserId();
  print("DEBUG: initial userId = $userId");

  runApp(MyApp(initialUserId: userId));
}

class MyApp extends StatelessWidget {
  final String? initialUserId;
  const MyApp({super.key, required this.initialUserId});

  @override
  Widget build(BuildContext context) {
    return ClerkAuth(
      config:  ClerkAuthConfig(
        publishableKey:
            "pk_test_YWN0aXZlLXBhbmdvbGluLTI1LmNsZXJrLmFjY291bnRzLmRldiQ",
      ),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ProductProvider()),
          
          ChangeNotifierProvider(create: (_) => OrderProvider()),
          ChangeNotifierProvider(create: (_) => WishlistProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
          ChangeNotifierProxyProvider<UserProvider, AddressProvider>(
            create: (context) => AddressProvider(
              Provider.of<UserProvider>(context, listen: false),
            ),
            update: (context, userProvider, addressProvider) {
              addressProvider ??= AddressProvider(userProvider);
              addressProvider.updateUserProvider(userProvider);
              return addressProvider;
            },
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.grey,
            primaryColor: Colors.black
          ),
          home: initialUserId != null && initialUserId!.isNotEmpty
              ? const SplashOrHome()
              : const WalkthroughScreen(),
        ),
      ),
    );
  }
}

class SplashOrHome extends StatefulWidget {
  const SplashOrHome({super.key});

  @override
  State<SplashOrHome> createState() => _SplashOrHomeState();
}

class _SplashOrHomeState extends State<SplashOrHome> {
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _decideNavigation();
    });
  }

  Future<void> _decideNavigation() async {
    try {
      final userId = await authService.getUserId();
      print("DEBUG: Splash userId = $userId");

      if (userId == null || userId.isEmpty) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WalkthroughScreen()),
        );
        return;
      }

      final url = "$baseurl/user/ispresent?userId=$userId";
      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 10),
          );
      
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final exists = data['exists'] == true;
        print("DEBUG: user exists = $exists");

        if (exists) {
          Navigator.pushReplacement(
            context,
            // NAVIGATE TO MainScreen INSTEAD OF HomeScren
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => UserFormScreen(userId: userId)),
          );
        }
      } else {
        throw Exception("Failed to check user. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in SplashOrHome: $e");
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WalkthroughScreen()),
      );
    }
  }
@override
Widget build(BuildContext context) {
  return const Scaffold(
    body: Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: Colors.white),
        Center(
          child: Image(
            image: AssetImage('assets/images/Logo.png'),
            width: 500,
            fit: BoxFit.contain,
          ),
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.only(top: 260), 
            child: CircularProgressIndicator(),
          ),
        ),
      ],
    ),
  );
}
}