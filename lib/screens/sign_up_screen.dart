import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/supabase_service.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback onSignup;

  const SignUpScreen({super.key, required this.onSignup});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String _nameError = '';
  String _emailError = '';
  String _passwordError = '';
  String _generalError = '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleChange(String field, String value) {
    setState(() {
      if (field == 'name') _nameError = '';
      if (field == 'email') _emailError = '';
      if (field == 'password') _passwordError = '';
    });
  }

  Future<void> _handleSubmit() async {
    // Clear previous errors
    setState(() {
      _nameError = '';
      _emailError = '';
      _passwordError = '';
      _generalError = '';
    });

    // Validate inputs
    if (_nameController.text.isEmpty) {
      setState(() {
        _nameError = 'Full name is required';
      });
      return;
    }

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
      // Check if user already exists
      final existingProfile = await SupabaseService.getProfile(
        _emailController.text,
      );

      if (existingProfile != null) {
        setState(() {
          _generalError = 'User already exists. Please sign in.';
          _isLoading = false;
        });
        return;
      }

      // Sign up with Supabase
      final signUpResponse = await SupabaseService.signUp(
        _emailController.text,
        _passwordController.text,
      );

      if (signUpResponse['error'] != null) {
        setState(() {
          _generalError = signUpResponse['error'].toString();
          _isLoading = false;
        });
        
        // Clear SharedPreferences on error
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        return;
      }

      // Store authentication state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('signUpEmail', _emailController.text);

      // Create profile
      final profileResponse = await SupabaseService.createProfile({
        'fullname': _nameController.text,
        'email': _emailController.text,
      });

      if (profileResponse['error'] != null) {
        setState(() {
          _generalError = 'Error creating profile. Try again.';
          _isLoading = false;
        });
        return;
      }

      // Call onSignup callback
      widget.onSignup();

      // Navigate to profile setup
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/profile-setup-basic');
      }
    } catch (err) {
      setState(() {
        _generalError = 'Something went wrong. Try again.';
        _isLoading = false;
      });
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
                    'Sign Up',
                    style: TextStyle(
                      fontSize: isMobile ? 28 : 36,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF444EE7),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Full Name Field
                  _buildTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    error: _nameError,
                    onChanged: (value) => _handleChange('name', value),
                  ),
                  const SizedBox(height: 32),

                  // Email Field
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    error: _emailError,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) => _handleChange('email', value),
                  ),
                  const SizedBox(height: 32),

                  // Password Field
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Password',
                    error: _passwordError,
                    obscureText: true,
                    onChanged: (value) => _handleChange('password', value),
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
                      // Sign Up Button
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
                          disabledBackgroundColor: const Color(0xFF444EE7).withOpacity(0.6),
                        ),
                        child: Text(
                          _isLoading ? 'Signing Up...' : 'Sign Up',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Sign In Link
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signin');
                        },
                        child: const Text(
                          'Already have an account?',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String error,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF444EE7),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
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
                color: error.isNotEmpty
                    ? Colors.red
                    : const Color(0xFFC7CBFF),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: error.isNotEmpty
                    ? Colors.red
                    : const Color(0xFF6B74FF),
                width: 2,
              ),
            ),
          ),
          style: const TextStyle(fontSize: 18),
        ),
        if (error.isNotEmpty)
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
                    error,
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
    );
  }
}