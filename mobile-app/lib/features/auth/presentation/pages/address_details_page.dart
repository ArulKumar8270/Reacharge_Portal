import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddressDetailsPage extends StatefulWidget {
  const AddressDetailsPage({super.key});

  @override
  State<AddressDetailsPage> createState() => _AddressDetailsPageState();
}

class _AddressDetailsPageState extends State<AddressDetailsPage> {
  final _pinCodeController = TextEditingController();
  final List<Map<String, String>> _addressSuggestions = [
    {
      'name': 'Hindi Prachar Sabha',
      'details': 'Hindi Prachar Sabha • Chennai • Tamil Nadu',
    },
    {
      'name': 'Thygarayanagar',
      'details': 'Thygarayanagar • Chennai • Tamil Nadu',
    },
    {
      'name': 'Thygarayanagar North ND',
      'details': 'Thygarayanagar North ND • Chennai • Tamil Nadu',
    },
    {
      'name': 'Thygarayanagar South',
      'details': 'Thygarayanagar South • Chennai • Tamil Nadu',
    },
  ];

  @override
  void dispose() {
    _pinCodeController.dispose();
    super.dispose();
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
                  // Back Button
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF212121)),
                    onPressed: () => context.pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Address Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212121),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Dark Mode Toggle
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Pin Code Input Field
                    Row(
                      children: [
                        Icon(
                          Icons.mail_outline,
                          color: const Color(0xFF2196F3),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Enter Pin Code',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF212121),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: TextFormField(
                        controller: _pinCodeController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: 'Enter Pin Code',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        onChanged: (value) {
                          // Filter addresses based on pin code
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Address Suggestions List
                    const Text(
                      'Select Address',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._addressSuggestions.map((address) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            // Return selected address as result
                            Navigator.of(context).pop(address);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE0E0E0)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: const Color(0xFF2196F3),
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        address['name']!,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF212121),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        address['details']!,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF757575),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Color(0xFF757575),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )),
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

