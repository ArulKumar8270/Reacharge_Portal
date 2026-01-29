import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BillsPage extends StatelessWidget {
  const BillsPage({super.key});

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
                      'Utility Bills',
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pay Your Bills',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 24),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                      children: [
                        _BillCard(
                          title: 'Electricity',
                          icon: Icons.bolt,
                          color: const Color(0xFFFFC107),
                          onTap: () => context.push('/bills/electricity'),
                        ),
                        _BillCard(
                          title: 'Water',
                          icon: Icons.water_drop,
                          color: const Color(0xFF2196F3),
                          onTap: () => context.push('/bills/water'),
                        ),
                        _BillCard(
                          title: 'Gas',
                          icon: Icons.local_gas_station,
                          color: const Color(0xFFFF9800),
                          onTap: () => context.push('/bills/gas'),
                        ),
                        _BillCard(
                          title: 'Broadband',
                          icon: Icons.wifi,
                          color: const Color(0xFF64B5F6),
                          onTap: () => context.push('/bills/broadband'),
                        ),
                        _BillCard(
                          title: 'Insurance',
                          icon: Icons.shield,
                          color: const Color(0xFF4CAF50),
                          onTap: () => context.push('/bills/insurance'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/wallet'),
                      icon: const Icon(Icons.account_balance_wallet),
                      label: const Text('Go to Wallet'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BillCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _BillCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
