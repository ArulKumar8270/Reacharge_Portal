import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/config/app_config.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  final _referCodeController = TextEditingController();
  
  String? _emailError;
  String? _phoneError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _referCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    // 1. Initial client-side validation
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Clear previous API errors before new attempt
    setState(() {
      _emailError = null;
      _phoneError = null;
    });
    
    final success = await authProvider.register({
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'password': _passwordController.text,
      if (_referCodeController.text.isNotEmpty)
        'referCode': _referCodeController.text.trim(),
    });

    if (success && mounted) {
      final phoneNumber = _phoneController.text.trim();
      const demoOtp = '123456';
      final registrationData = Uri.encodeComponent(
        '${_nameController.text.trim()}|${_emailController.text.trim()}|${_phoneController.text.trim()}|${_passwordController.text}'
      );
      context.push('/otp-verification?phoneNumber=$phoneNumber&demoOtp=$demoOtp&regData=$registrationData');
    } else if (mounted) {
      final errorMessage = authProvider.error ?? 'Registration failed';
      final lowerError = errorMessage.toLowerCase();

      setState(() {
        if (lowerError.contains('email') && lowerError.contains('phone')) {
          _emailError = 'Email and phone already in use';
          _phoneError = 'Email and phone already in use';
        } else if (lowerError.contains('email')) {
          _emailError = 'This email is already registered';
        } else if (lowerError.contains('phone')) {
          _phoneError = 'This phone number is already registered';
        } else if (lowerError.contains('already exists') || lowerError.contains('already registered')) {
          _emailError = 'User already exists with these credentials';
          _phoneError = 'User already exists with these credentials';
        }
      });

      // Trigger validation again to display the newly set _emailError/_phoneError
      _formKey.currentState!.validate();

      // If it's a generic error not related to email/phone, show SnackBar
      if (_emailError == null && _phoneError == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      _buildLabel(Icons.person_outline, 'Full Name'),
                      _buildTextField(
                        controller: _nameController,
                        hint: 'Enter your full name',
                        validator: (v) => (v == null || v.isEmpty) ? 'Name is required' : null,
                      ),
                      
                      const SizedBox(height: 20),
                      _buildLabel(Icons.alternate_email, 'Email'),
                      _buildTextField(
                        controller: _emailController,
                        hint: 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                        errorText: _emailError,
                        onChanged: (v) {
                          if (_emailError != null) {
                            setState(() => _emailError = null);
                            _formKey.currentState!.validate();
                          }
                        },
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Email is required';
                          if (_emailError != null) return _emailError; // Show API error
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return 'Invalid email format';
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),
                      _buildLabel(Icons.phone_outlined, 'Phone Number'),
                      _buildTextField(
                        controller: _phoneController,
                        hint: 'Enter 10-digit number',
                        keyboardType: TextInputType.phone,
                        errorText: _phoneError,
                        onChanged: (v) {
                          if (_phoneError != null) {
                            setState(() => _phoneError = null);
                            _formKey.currentState!.validate();
                          }
                        },
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Phone number is required';
                          if (_phoneError != null) return _phoneError; // Show API error
                          if (v.length != 10) return 'Enter a valid 10-digit number';
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),
                      _buildLabel(Icons.lock_outline, 'Password'),
                      _buildTextField(
                        controller: _passwordController,
                        hint: 'Enter your password',
                        obscureText: true,
                        validator: (v) => (v == null || v.length < 6) ? 'Password must be 6+ characters' : null,
                      ),

                      const SizedBox(height: 20),
                      _buildLabel(Icons.location_on_outlined, 'Location'),
                      _buildLocationSelector(),

                      const SizedBox(height: 20),
                      _buildLabel(Icons.card_giftcard_outlined, 'Refer Code (Optional)'),
                      _buildTextField(controller: _referCodeController, hint: 'Enter code'),

                      const SizedBox(height: 40),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI Helper Methods ---

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF2196F3),
            radius: 20,
            child: Text(AppConfig.currencySymbol, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          const Text("Let's Get Started!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          const Icon(Icons.dark_mode_outlined, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildLabel(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2196F3), size: 20),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? errorText,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          errorStyle: const TextStyle(height: 0.8), // Tighter error text
        ),
      ),
    );
  }

  Widget _buildLocationSelector() {
    return InkWell(
      onTap: () async {
        final result = await context.push<Map<String, String>>('/address-details');
        if (result != null && mounted) {
          setState(() => _addressController.text = result['name'] ?? result['details'] ?? '');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _addressController.text.isEmpty ? 'Select your location' : _addressController.text,
                style: TextStyle(color: _addressController.text.isEmpty ? Colors.grey : Colors.black),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return ElevatedButton(
          onPressed: auth.isLoading ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: auth.isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Submit', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
        );
      },
    );
  }
}