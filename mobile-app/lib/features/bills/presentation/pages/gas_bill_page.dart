import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GasBillPage extends StatelessWidget {
  const GasBillPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gas Bill')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_gas_station, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Gas Bill Payment',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Coming Soon'),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.push('/wallet'),
              icon: const Icon(Icons.account_balance_wallet),
              label: const Text('Go to Wallet'),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Bills'),
            ),
          ],
        ),
      ),
    );
  }
}

