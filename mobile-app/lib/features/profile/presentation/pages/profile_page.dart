import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/auth_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Load user details when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated && authProvider.user == null) {
        authProvider.getUserDetails();
      }
    });
  }

  void _showEditProfileSheet(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user == null) return;
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.phoneNumber);
    final addressLine1Controller = TextEditingController(text: user.addressLine1 ?? '');
    final addressLine2Controller = TextEditingController(text: user.addressLine2 ?? '');
    final cityController = TextEditingController(text: user.city ?? '');
    final stateController = TextEditingController(text: user.state ?? '');
    final pincodeController = TextEditingController(text: user.pincode ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.85),
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Edit profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close, color: Color(0xFF757575))),
                ],
              ),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF2196F3)),
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF2196F3)),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF2196F3)),
                        ),
                        keyboardType: TextInputType.phone,
                        autocorrect: false,
                      ),
                      const SizedBox(height: 20),
                      const Text('Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF212121))),
                      const SizedBox(height: 8),
                      TextField(
                        controller: addressLine1Controller,
                        decoration: InputDecoration(
                          labelText: 'Address line 1',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.home_outlined, color: Color(0xFF2196F3)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: addressLine2Controller,
                        decoration: InputDecoration(
                          labelText: 'Address line 2 (optional)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: cityController,
                              decoration: InputDecoration(
                                labelText: 'City',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: stateController,
                              decoration: InputDecoration(
                                labelText: 'State',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: pincodeController,
                        decoration: InputDecoration(
                          labelText: 'Pincode',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.pin_drop_outlined, color: Color(0xFF2196F3)),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: auth.isLoading
                          ? null
                          : () async {
                              final name = nameController.text.trim();
                              final email = emailController.text.trim();
                              final phone = phoneController.text.trim();
                              if (name.isEmpty || email.isEmpty) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  const SnackBar(content: Text('Name and email are required'), behavior: SnackBarBehavior.floating),
                                );
                                return;
                              }
                              if (phone.isEmpty) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  const SnackBar(content: Text('Phone number is required'), behavior: SnackBarBehavior.floating),
                                );
                                return;
                              }
                              final ok = await auth.updateProfile({
                                'name': name,
                                'email': email,
                                'phoneNumber': phone,
                                'addressLine1': addressLine1Controller.text.trim().isEmpty ? null : addressLine1Controller.text.trim(),
                                'addressLine2': addressLine2Controller.text.trim().isEmpty ? null : addressLine2Controller.text.trim(),
                                'city': cityController.text.trim().isEmpty ? null : cityController.text.trim(),
                                'state': stateController.text.trim().isEmpty ? null : stateController.text.trim(),
                                'pincode': pincodeController.text.trim().isEmpty ? null : pincodeController.text.trim(),
                              });
                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);
                              if (ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Profile updated'), backgroundColor: Color(0xFF4CAF50), behavior: SnackBarBehavior.floating),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(auth.error ?? 'Update failed'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: auth.isLoading ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Save'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // Light blue background
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.user;
          final isAuthenticated = authProvider.isAuthenticated;
          
          // Show login option if not authenticated
          if (!isAuthenticated) {
            return const _LoginPrompt();
          }
          
          // Show user profile if authenticated
          return Column(
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
                        'Profile',
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
              
              // Profile Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Icon
                      Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Complete KYC Card
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2196F3),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Complete KYC',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF212121),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Unlock Unlimited Recharges',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF757575),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Used ₹0.00',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF757575),
                                          ),
                                        ),
                                        const Text(
                                          'of ₹10,000.00',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF757575),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: 0.0,
                                        backgroundColor: Colors.grey[200],
                                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                                        minHeight: 6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Color(0xFF757575),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Personal Info Section
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Personal Info',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF212121),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => _showEditProfileSheet(context),
                                    child: const Text(
                                      'Edit',
                                      style: TextStyle(
                                        color: Color(0xFF2196F3),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _InfoRow(
                                icon: Icons.person_outline,
                                label: 'Name',
                                value: user?.name ?? 'N/A',
                              ),
                              const Divider(height: 24),
                              _InfoRow(
                                icon: Icons.phone_outlined,
                                label: 'Phone Number',
                                value: user?.phoneNumber ?? 'N/A',
                              ),
                              const Divider(height: 24),
                              _InfoRow(
                                icon: Icons.email_outlined,
                                label: 'E-Mail',
                                value: user?.email ?? 'N/A',
                              ),
                              const Divider(height: 24),
                              _InfoRow(
                                icon: Icons.home_outlined,
                                label: 'Address',
                                value: user?.formattedAddress ?? 'N/A',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Account Info Section
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Account Info',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF212121),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _InfoRow(
                                icon: Icons.alternate_email,
                                label: 'Referral Id',
                                value: user?.referralCode ?? 'N/A',
                              ),
                              const Divider(height: 24),
                              _InfoRow(
                                icon: Icons.phone_outlined,
                                label: 'Phone Verification',
                                value: 'Verified',
                                valueColor: const Color(0xFF4CAF50),
                              ),
                              const Divider(height: 24),
                              _InfoRow(
                                icon: Icons.email_outlined,
                                label: 'E-Mail Verification',
                                value: 'Pending',
                                valueColor: const Color(0xFFFF9800),
                              ),
                              const Divider(height: 24),
                              _InfoRow(
                                icon: Icons.fingerprint_outlined,
                                label: 'E-KYC',
                                value: 'Pending',
                                valueColor: const Color(0xFFFF9800),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF2196F3),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF757575),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? const Color(0xFF212121),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE3F2FD), // Light blue background
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Welcome to Nexus',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Login to access your profile and manage your account',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/login'),
                  icon: const Icon(Icons.login_rounded),
                  label: const Text('Login'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.push('/register'),
                child: const Text("Don't have an account? Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
