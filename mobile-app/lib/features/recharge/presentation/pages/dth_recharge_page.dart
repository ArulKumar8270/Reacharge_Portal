import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DthRechargePage extends StatefulWidget {
  const DthRechargePage({super.key});

  @override
  State<DthRechargePage> createState() => _DthRechargePageState();
}

class _DthRechargePageState extends State<DthRechargePage> {
  String? _selectedProvider;
  String? _customerId;
  String? _amount;

  @override
  Widget build(BuildContext context) {
    // If no provider selected, show provider selection
    if (_selectedProvider == null) {
      return const _SelectProviderPage();
    }
    
    // If provider selected but no customer ID, show enter details
    if (_customerId == null) {
      return _EnterDetailsPage(
        provider: _selectedProvider!,
        onDetailsEntered: (customerId) {
          setState(() {
            _customerId = customerId;
          });
        },
      );
    }
    
    // Show recharge page
    return _DthRechargeScreen(
      provider: _selectedProvider!,
      customerId: _customerId!,
      onAmountEntered: (amount) {
        setState(() {
          _amount = amount;
        });
      },
    );
  }
}

class _SelectProviderPage extends StatelessWidget {
  const _SelectProviderPage();

  @override
  Widget build(BuildContext context) {
    final providers = [
      {'name': 'Airtel TV', 'logo': 'A', 'color': Colors.red},
      {'name': 'Dish TV', 'logo': 'D', 'color': Colors.orange},
      {'name': 'Sun Direct TV', 'logo': 'S', 'color': Colors.orange},
      {'name': 'Tata Sky', 'logo': 'T', 'color': Colors.pink},
      {'name': 'Videocon D2H', 'logo': 'V', 'color': Colors.purple},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
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
                      'Select Provider',
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
            
            // Provider List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: providers.length,
                itemBuilder: (context, index) {
                  final provider = providers[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => _EnterDetailsPage(
                              provider: provider['name'] as String,
                              onDetailsEntered: (customerId) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => _DthRechargeScreen(
                                      provider: provider['name'] as String,
                                      customerId: customerId,
                                      onAmountEntered: (_) {},
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
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
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: (provider['color'] as Color).withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  provider['logo'] as String,
                                  style: TextStyle(
                                    color: provider['color'] as Color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                provider['name'] as String,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF212121),
                                ),
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnterDetailsPage extends StatefulWidget {
  final String provider;
  final Function(String) onDetailsEntered;

  const _EnterDetailsPage({
    required this.provider,
    required this.onDetailsEntered,
  });

  @override
  State<_EnterDetailsPage> createState() => _EnterDetailsPageState();
}

class _EnterDetailsPageState extends State<_EnterDetailsPage> {
  final _customerIdController = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _customerIdController.addListener(() {
      setState(() {
        _isButtonEnabled = _customerIdController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _customerIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
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
                      'Enter Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212121),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
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
                    // Service Selection Card
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
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  'D',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Dish TV',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF212121),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.pop(),
                              child: const Text(
                                'Change',
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
                    const SizedBox(height: 24),
                    
                    // Customer ID Input
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _customerIdController,
                        decoration: const InputDecoration(
                          hintText: 'Customer ID',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Color(0xFF757575)),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF212121),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Confirm Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isButtonEnabled
                            ? () {
                                widget.onDetailsEntered(_customerIdController.text);
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => _DthRechargeScreen(
                                      provider: widget.provider,
                                      customerId: _customerIdController.text,
                                      onAmountEntered: (_) {},
                                    ),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isButtonEnabled
                              ? const Color(0xFF2196F3)
                              : Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Confirm',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

class _DthRechargeScreen extends StatefulWidget {
  final String provider;
  final String customerId;
  final Function(String) onAmountEntered;

  const _DthRechargeScreen({
    required this.provider,
    required this.customerId,
    required this.onAmountEntered,
  });

  @override
  State<_DthRechargeScreen> createState() => _DthRechargeScreenState();
}

class _DthRechargeScreenState extends State<_DthRechargeScreen> {
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
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
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'D',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.customerId,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212121),
                          ),
                        ),
                        const Text(
                          'Dish TV',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
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
                    // Amount Input Card
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Enter Amount',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF757575),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                prefixText: '₹ ',
                                prefixStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF212121),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF212121),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'DTH Info:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF212121),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text(
                                  'id: ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF757575),
                                  ),
                                ),
                                Text(
                                  widget.customerId,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF212121),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Proceed to Pay Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Handle payment
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B7280),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Proceed to Pay',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Important Alert
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFF9800).withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFFFF9800),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Important Alert!',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF212121),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Please check your number and amount carefully before proceeding. Once the transaction is successful, it cannot be reversed and refund.',
                            style: TextStyle(
                              fontSize: 12,
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
          ],
        ),
      ),
    );
  }
}
