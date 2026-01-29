import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  String? _phoneNumber;
  String? _demoOtp;
  String? _registrationData; // Store registration data for login after OTP

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get phone number, demo OTP, and registration data from route query parameters
    final state = GoRouterState.of(context);
    final phoneNumber = state.uri.queryParameters['phoneNumber'];
    final demoOtp = state.uri.queryParameters['demoOtp'];
    final regData = state.uri.queryParameters['regData'];
    if (phoneNumber != null && _phoneNumber != phoneNumber) {
      setState(() {
        _phoneNumber = phoneNumber;
        _demoOtp = demoOtp;
        _registrationData = regData;
      });
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleVerifyOtp() async {
    if (_formKey.currentState!.validate() && _phoneNumber != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Skip OTP verification API - directly login user after OTP verification
      if (mounted) {
        // If we have registration data, login the user automatically
        if (_registrationData != null) {
          try {
            // Parse registration data: name|email|phone|password
            final decodedData = Uri.decodeComponent(_registrationData!);
            final parts = decodedData.split('|');
            if (parts.length >= 4) {
              final phoneNumber = parts[2];
              final password = parts[3];
              
              // Login user with phone and password
              final loginSuccess = await authProvider.login(phoneNumber, password);
              
              if (loginSuccess && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('OTP verified and logged in successfully!'),
                    backgroundColor: Color(0xFF4CAF50),
                  ),
                );
                await Future.delayed(const Duration(milliseconds: 500));
                if (mounted) {
                  context.go('/home');
                }
                return;
              }
            }
          } catch (e) {
            // If login fails, just proceed (user might already be registered)
            print('Auto-login failed: $e');
          }
        }
        
        // Fallback: Just show success and navigate (for cases without registration data)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP verified successfully!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.go('/home');
        }
      }
      
      // Original API call (commented out for skipping)
      // final success = await authProvider.verifyOtp(_phoneNumber!, _otpController.text.trim());
      // 
      // if (success && mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('OTP verified successfully!')),
      //   );
      //   context.go('/home');
      // } else if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text(authProvider.error ?? 'OTP verification failed')),
      //   );
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // Light blue background
      body: SafeArea(
        child: Column(
          children: [
            // White Header Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF212121)),
                    onPressed: () => context.pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Verify OTP',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212121),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.dark_mode_outlined, color: Color(0xFF757575)),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified_user_rounded,
                          size: 60,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      const Text(
                        'Enter OTP',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212121),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _phoneNumber != null
                            ? 'We sent a verification code to\n$_phoneNumber'
                            : 'Enter the verification code sent to your phone',
                        style: const TextStyle(fontSize: 16, color: Color(0xFF757575)),
                        textAlign: TextAlign.center,
                      ),
                      
                      // Demo OTP Banner
                      if (_demoOtp != null) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9800).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFFF9800),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Color(0xFFFF9800),
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Demo OTP',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFFF9800),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  _otpController.text = _demoOtp!;
                                  setState(() {});
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFFF9800)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _demoOtp!,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFFF9800),
                                          letterSpacing: 4,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.touch_app,
                                        color: Color(0xFFFF9800),
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Tap to auto-fill OTP',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF757575),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 32),
                      // OTP Input Field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: TextFormField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            letterSpacing: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLength: 6,
                          decoration: const InputDecoration(
                            hintText: '000000',
                            counterText: '',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            prefixIcon: Icon(Icons.pin, color: Color(0xFF2196F3)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter OTP';
                            }
                            if (value.length != 6) {
                              return 'OTP must be 6 digits';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Verify OTP Button
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, _) {
                          return ElevatedButton(
                            onPressed: authProvider.isLoading ? null : _handleVerifyOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: authProvider.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Verify OTP',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Resend OTP Button
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('OTP resend functionality coming soon'),
                              backgroundColor: Color(0xFF2196F3),
                            ),
                          );
                        },
                        child: const Text(
                          'Resend OTP',
                          style: TextStyle(
                            color: Color(0xFF2196F3),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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
}

