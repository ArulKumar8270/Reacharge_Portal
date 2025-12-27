import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BillsPage extends StatelessWidget {
  const BillsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Utility Bills')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pay Your Bills',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                  color: Colors.yellow,
                  onTap: () => context.push('/bills/electricity'),
                ),
                _BillCard(
                  title: 'Water',
                  icon: Icons.water_drop,
                  color: Theme.of(context).colorScheme.primary,
                  onTap: () => context.push('/bills/water'),
                ),
                _BillCard(
                  title: 'Gas',
                  icon: Icons.local_gas_station,
                  color: Colors.orange,
                  onTap: () => context.push('/bills/gas'),
                ),
                _BillCard(
                  title: 'Broadband',
                  icon: Icons.wifi,
                  color: Theme.of(context).colorScheme.secondary,
                  onTap: () => context.push('/bills/broadband'),
                ),
                _BillCard(
                  title: 'Insurance',
                  icon: Icons.shield,
                  color: Colors.green,
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
                minimumSize: const Size(double.infinity, 50),
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
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

