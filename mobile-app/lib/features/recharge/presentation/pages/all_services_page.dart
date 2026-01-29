import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AllServicesPage extends StatelessWidget {
  const AllServicesPage({super.key});

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
                      'All Services',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212121),
                      ),
                    ),
                  ),
                  // Bharat Connect Logo
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Center(
                          child: Text(
                            'B',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Bharat Connect',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                    ],
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
                    // Popular Section
                    const Text(
                      'Popular',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _ServiceItem(
                            icon: Icons.phone_android,
                            title: 'Prepaid',
                            onTap: () => context.push('/recharge/mobile'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ServiceItem(
                            icon: Icons.satellite_alt,
                            title: 'DTH',
                            onTap: () => context.push('/recharge/dth'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ServiceItem(
                            icon: Icons.play_circle_outline,
                            title: 'Redeem Code',
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Utility Section
                    const Text(
                      'Utility',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                      children: [
                        _ServiceItem(
                          icon: Icons.local_gas_station,
                          title: 'Fastag',
                          onTap: () => context.push('/recharge/fastag'),
                        ),
                        _ServiceItem(
                          icon: Icons.bolt,
                          title: 'Electricity',
                          onTap: () => context.push('/bills/electricity'),
                        ),
                        _ServiceItem(
                          icon: Icons.phone_android,
                          title: 'Postpaid',
                          onTap: () {},
                        ),
                        _ServiceItem(
                          icon: Icons.phone,
                          title: 'Landline',
                          onTap: () {},
                        ),
                        _ServiceItem(
                          icon: Icons.local_gas_station,
                          title: 'Gas Bill',
                          onTap: () => context.push('/bills/gas'),
                        ),
                        _ServiceItem(
                          icon: Icons.water_drop,
                          title: 'Water Bill',
                          onTap: () => context.push('/bills/water'),
                        ),
                        _ServiceItem(
                          icon: Icons.shield,
                          title: 'Insurance',
                          onTap: () => context.push('/bills/insurance'),
                        ),
                        _ServiceItem(
                          icon: Icons.wifi,
                          title: 'Broadband',
                          onTap: () => context.push('/bills/broadband'),
                        ),
                        _ServiceItem(
                          icon: Icons.local_gas_station,
                          title: 'Piped Gas',
                          onTap: () {},
                        ),
                      ],
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

class _ServiceItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ServiceItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF2196F3),
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF212121),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

