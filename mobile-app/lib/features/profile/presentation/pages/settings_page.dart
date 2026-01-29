import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // Light blue background
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.user;
          final isAuthenticated = authProvider.isAuthenticated;
          
          if (!isAuthenticated) {
            return const Center(
              child: Text('Please login to access settings'),
            );
          }
          
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
                        'Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF212121),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance space
                  ],
                ),
              ),
              
              // Settings Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Profile Card
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
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user?.name ?? 'User',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF212121),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user?.phoneNumber ?? 'N/A',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF757575),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      user?.email ?? 'N/A',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF757575),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // General Settings Section
                      const Text(
                        'GENERAL SETTINGS',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1976D2),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      _SettingsItem(
                        icon: Icons.person_outline,
                        title: 'Profile Settings',
                        subtitle: 'Name, Email Id',
                        onTap: () => context.push('/profile'),
                      ),
                     
                      // Review & Policy Section
                      // const Text(
                      //   'REVIEW & POLICY',
                      //   style: TextStyle(
                      //     fontSize: 14,
                      //     fontWeight: FontWeight.bold,
                      //     color: Color(0xFF1976D2),
                      //     letterSpacing: 0.5,
                      //   ),
                      // ),
                      // const SizedBox(height: 12),
                      
                      // _SettingsItem(
                      //   icon: Icons.star_outline,
                      //   title: 'Rate Us',
                      //   subtitle: 'Share your feedback',
                      //   onTap: () {},
                      // ),
                      // _SettingsItem(
                      //   icon: Icons.privacy_tip_outlined,
                      //   title: 'Privacy Policy',
                      //   subtitle: 'How we protect your data',
                      //   onTap: () {},
                      // ),
                      // _SettingsItem(
                      //   icon: Icons.description_outlined,
                      //   title: 'Terms & Conditions',
                      //   subtitle: 'Terms of service',
                      //   onTap: () {},
                      // ),
                      
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

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF2196F3),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF757575),
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
    );
  }
}

