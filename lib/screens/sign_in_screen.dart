import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/supabase_service.dart';

class SignInScreen extends StatefulWidget {
  final VoidCallback onLogin;

  const SignInScreen({super.key, required this.onLogin});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  String _emailError = '';
  String _passwordError = '';
  String _generalError = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    // Clear previous errors
    setState(() {
      _emailError = '';
      _passwordError = '';
      _generalError = '';
    });

    // Validate inputs
    if (_emailController.text.isEmpty) {
      setState(() {
        _emailError = 'Email is required';
      });
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() {
        _passwordError = 'Password is required';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Sign in with Supabase
      final response = await SupabaseService.signIn(
        _emailController.text,
        _passwordController.text,
      );

      if (response['error'] != null) {
        final errorMessage = response['error'].toString().toLowerCase();
        
        if (errorMessage.contains('email not confirmed') ||
            errorMessage.contains('confirm')) {
          setState(() {
            _emailError = 'Email not yet confirmed. Please check your inbox.';
          });
          return;
        }

        setState(() {
          _generalError = response['error'].toString();
        });
        return;
      }

      // DEBUG: Check authentication
      final currentUser = SupabaseService.getCurrentUser();
      print('✅ Signed in user: ${currentUser?.email}');
      print('✅ User ID: ${currentUser?.id}');

      // Fetch user profile
      final userEmail = response['user']['email'];
      final profileData = await SupabaseService.getProfile(userEmail);

      // Store in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('userName', profileData?['fullname'] ?? 'User');
      await prefs.setString('userEmail', userEmail);
      await prefs.setString(
        'qualification',
        profileData?['qualification'] ?? '',
      );

      // Call onLogin callback
      widget.onLogin();

      // Navigate to dashboard
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (err) {
      setState(() {
        _generalError = 'An unexpected error occurred.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Scaffold(
      backgroundColor: const Color(0xFFEEF0FF),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
          child: Container(
            constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 600),
            padding: EdgeInsets.all(isMobile ? 24.0 : 48.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FF),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFC7CBFF),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: isMobile ? 28 : 36,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF444EE7),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Email Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF444EE7),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          filled: true,
                          fillColor: const Color(0xFFF5F6FF),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFC7CBFF),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _emailError.isNotEmpty
                                  ? Colors.red
                                  : const Color(0xFFC7CBFF),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _emailError.isNotEmpty
                                  ? Colors.red
                                  : const Color(0xFF6B74FF),
                              width: 2,
                            ),
                          ),
                        ),
                        style: const TextStyle(fontSize: 18),
                      ),
                      if (_emailError.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                '!',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _emailError,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Password Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF444EE7),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          filled: true,
                          fillColor: const Color(0xFFF5F6FF),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFC7CBFF),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _passwordError.isNotEmpty
                                  ? Colors.red
                                  : const Color(0xFFC7CBFF),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _passwordError.isNotEmpty
                                  ? Colors.red
                                  : const Color(0xFF6B74FF),
                              width: 2,
                            ),
                          ),
                        ),
                        style: const TextStyle(fontSize: 18),
                      ),
                      if (_passwordError.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                '!',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _passwordError,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // General Error
                  if (_generalError.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        border: Border.all(color: Colors.red[400]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _generalError,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Sign In Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                          backgroundColor: const Color(0xFF444EE7),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 8,
                        ),
                        child: Text(
                          _isLoading ? 'Signing In...' : 'Sign In',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Sign Up Link
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: const Text(
                          'Create an account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF444EE7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}