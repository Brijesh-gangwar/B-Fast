
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'package:clerk_flutter/clerk_flutter.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../widgets/snackbar_fxn.dart';

class CustomAuthScreen extends StatefulWidget {
  static void disposeClerkListener() {
    _CustomAuthScreenState._currentInstance?._disposeClerkListenerInternal();
  }

  const CustomAuthScreen({super.key});

  @override
  State<CustomAuthScreen> createState() => _CustomAuthScreenState();
}

class _CustomAuthScreenState extends State<CustomAuthScreen> {
  static _CustomAuthScreenState? _currentInstance;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();

  late final ClerkAuthState _auth;
  clerk.User? _user;

  bool _loading = false;
  bool _isOtpStep = false;
  bool _isLogin = true;
  final bool _rememberMe = false;
  bool _obscure = true; // used only for visual parity on second field
  late final StreamSubscription _errorSub;

  final _authService = AuthService();

  @override
  void initState() {
    _currentInstance = this;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _auth = ClerkAuth.of(context);
      _user = _auth.user;
      _auth.addListener(_updateUser);

      _errorSub = _auth.errorStream.listen((err) {
        if (mounted) {
          showCustomMessage(context, err.message);
        }
      });
    });
  }

  void _updateUser() async {
    if (!mounted) return;
    setState(() => _user = _auth.user);

    if (_user != null && _isOtpStep) {
      await _authService.saveUserId(_user!.id);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SplashOrHome()),
        );
      }
    }
  }

  Future<void> _sendEmailOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      if (_isLogin) {
        await _auth.attemptSignIn(
          strategy: clerk.Strategy.emailCode,
          identifier: _emailController.text.trim(),
        );
      } else {
        await _auth.attemptSignUp(
          strategy: clerk.Strategy.emailCode,
          emailAddress: _emailController.text.trim(),
        );
      }
      showCustomMessage(context,"OTP sent to your email.");
      setState(() => _isOtpStep = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyEmailOtp() async {
    if (_otpController.text.trim().length < 4) {
      showCustomMessage(context,"Enter a valid OTP (6 digits).");
      return;
    }

    setState(() => _loading = true);
    try {
      if (_isLogin) {
        await _auth.attemptSignIn(
          strategy: clerk.Strategy.emailCode,
          code: _otpController.text.trim(),
        );
      } else {
        await _auth.attemptSignUp(
          strategy: clerk.Strategy.emailCode,
          code: _otpController.text.trim(),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      await _auth.ssoSignIn(context, clerk.Strategy.oauthGoogle);

      if (_auth.user != null) {
        await _authService.saveUserId(_auth.user!.id);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SplashOrHome()),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _inputDecoration(String label, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF3F3F3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 1),
      ),
      suffixIcon: suffix,
    );
  }

  Widget _socialButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: icon == Icons.g_mobiledata ? 34 : 26),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _authService.getUserId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final userId = snapshot.data;

        if (userId != null && userId.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SplashOrHome()),
            );
          });
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    const Text(
                      'B FAST',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 36),
                    Text(
                      _isLogin ? 'Welcome Back!' : 'Create Account',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLogin ? 'Please sign in to your account' : 'Your fashion journey starts here',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 28),

                    // Card container
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Email
                          TextFormField(
                            controller: _emailController,
                            enabled: !_isOtpStep,
                            decoration: _inputDecoration('Email Address'),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) return "Email required";
                              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                              if (!emailRegex.hasMatch(value)) return "Enter valid email";
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Second field: Password look for OTP entry
                      _isOtpStep?    TextFormField(
                            controller: _otpController,
                            obscureText: _obscure,
                            keyboardType: _isOtpStep ? TextInputType.number : TextInputType.text,
                            decoration: _inputDecoration(
                              _isOtpStep ? 'Enter OTP' : 'Enter Otp',
                              suffix: IconButton(
                                icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                            ),
                          ):SizedBox(),
                          const SizedBox(height: 16),

                         
                          // Primary button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _loading
                                  ? null
                                  : () {
                                      if (_isOtpStep) {
                                        _verifyEmailOtp();
                                      } else {
                                        _sendEmailOtp();
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                elevation: 0,
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text(_isOtpStep
                                      ? (_isLogin ? 'Verify & Sign In' : 'Verify & Register')
                                      : (_isLogin ? 'Sign In' : 'Sign Up')),
                            ),
                          ),
                          const SizedBox(height: 22),

                          // Divider with label
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text('Or continue with', style: TextStyle(color: Colors.grey[600])),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Social buttons row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // _socialButton(Icons.facebook, onTap: () {
                              //   // TODO: wire Facebook if needed
                              // }),
                              const SizedBox(width: 16),
                              _socialButton(Icons.g_mobiledata, onTap: _signInWithGoogle),
                              const SizedBox(width: 16),
                              // _socialButton(Icons.apple, onTap: () {
                              //   // TODO: wire Apple if needed
                              // }),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Bottom toggle
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                          _isOtpStep = false;
                          _otpController.clear();
                          _obscure = true;
                        });
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.black),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.grey[700], fontSize: 16),
                          children: [
                            TextSpan(
                              text: _isLogin ? "Don't have an account? " : "Already have an account? ",
                            ),
                            const TextSpan(
                              text: 'Sign Up',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _currentInstance = null;
    _emailController.dispose();
    _otpController.dispose();
    try {
      _auth.removeListener(_updateUser);
    } catch (_) {}
    _errorSub.cancel();
    super.dispose();
  }

  static void disposeClerkListener() {
    _currentInstance?._disposeClerkListenerInternal();
  }

  void _disposeClerkListenerInternal() {
    try {
      _auth.removeListener(_updateUser);
    } catch (_) {}
    try {
      _errorSub.cancel();
    } catch (_) {}
  }
}
