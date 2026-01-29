import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/api_service.dart';

class MobileRechargePage extends StatefulWidget {
  const MobileRechargePage({super.key});

  @override
  State<MobileRechargePage> createState() => _MobileRechargePageState();
}

class _MobileRechargePageState extends State<MobileRechargePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  String _phoneNumber = '';
  String _circle = '';
  String _operator = '';
  String _operatorCode = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    // Show dialog on first load if no phone number
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_phoneNumber.isEmpty) {
        _showMobileNumberDialog();
      }
    });
  }

  Color _getOperatorColor() {
    switch (_operatorCode.toUpperCase()) {
      case 'VI':
      case 'VODAFONE':
      case 'IDEA':
        return Colors.red;
      case 'AIRTEL':
        return Colors.red;
      case 'JIO':
        return Colors.blue;
      case 'BSNL':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _fetchMobileDetails(String phoneNumber) async {
    if (phoneNumber.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit mobile number')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Call API to get operator and circle details
      final response = await _apiService.get('/recharge/mobile-details', queryParameters: {
        'phone': phoneNumber,
      });

      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _phoneNumber = phoneNumber;
          _operator = response['data']['operator'] ?? '';
          _operatorCode = response['data']['operatorCode'] ?? '';
          _circle = response['data']['circle'] ?? '';
          _isLoading = false;
        });
      } else {
        // Fallback: Try to detect operator from first 4 digits
        _detectOperatorFromNumber(phoneNumber);
      }
    } catch (e) {
      // Fallback: Try to detect operator from first 4 digits
      _detectOperatorFromNumber(phoneNumber);
    }
  }

  void _detectOperatorFromNumber(String phoneNumber) {
    // Simple operator detection based on first 3 digits
    String firstThree = phoneNumber.length >= 3 ? phoneNumber.substring(0, 3) : '';
    String operator = 'Unknown';
    String operatorCode = 'UNK';
    
    // Common operator prefixes (simplified detection)
    if (firstThree.startsWith('9')) {
      operator = 'Vodafone Idea';
      operatorCode = 'VI';
    } else if (firstThree.startsWith('8')) {
      operator = 'Airtel';
      operatorCode = 'AIRTEL';
    } else if (firstThree.startsWith('7')) {
      // Can be Jio or Airtel
      operator = 'Jio';
      operatorCode = 'JIO';
    } else if (firstThree.startsWith('6')) {
      operator = 'Jio';
      operatorCode = 'JIO';
    }

    setState(() {
      _phoneNumber = phoneNumber;
      _operator = operator;
      _operatorCode = operatorCode;
      _circle = 'Tamil Nadu'; // Default circle, should be fetched from API
      _isLoading = false;
    });
  }

  void _showMobileNumberDialog() {
    _phoneController.text = _phoneNumber;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Mobile Number'),
        content: TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          decoration: const InputDecoration(
            labelText: 'Mobile Number',
            hintText: 'Enter 10-digit mobile number',
            prefixText: '+91 ',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (_phoneController.text.length == 10) {
                _fetchMobileDetails(_phoneController.text);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid 10-digit mobile number')),
                );
              }
            },
            child: const Text('Get Details'),
          ),
        ],
      ),
    );
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
                  if (_isLoading)
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getOperatorColor().withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _operatorCode.isNotEmpty ? _operatorCode.substring(0, 2) : '?',
                          style: TextStyle(
                            color: _getOperatorColor(),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
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
                          _phoneNumber.isEmpty ? 'Enter Mobile Number' : _phoneNumber,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212121),
                          ),
                        ),
                        Text(
                          _circle.isEmpty ? 'Tap edit to enter number' : _circle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Color(0xFF757575)),
                    onPressed: _showMobileNumberDialog,
                  ),
                ],
              ),
            ),
            
            // Amount Input and Recharge Button
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixText: '₹ ',
                      prefixStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212121),
                      ),
                      hintText: 'Enter Plan Amount',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Handle recharge
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Recharge',
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
            
            // Tabs
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF1976D2),
                unselectedLabelColor: const Color(0xFF757575),
                indicatorColor: const Color(0xFF1976D2),
                tabs: const [
                  Tab(text: 'R-Offers'),
                  Tab(text: 'Unlimited'),
                  Tab(text: 'Data'),
                  Tab(text: 'Talktime'),
                  Tab(text: 'Combo'),
                ],
              ),
            ),
            
            // Plans List
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _PlansList(plans: _getROffersPlans()),
                  _PlansList(plans: _getUnlimitedPlans()),
                  _PlansList(plans: _getDataPlans()),
                  _PlansList(plans: _getTalktimePlans()),
                  _PlansList(plans: _getComboPlans()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getROffersPlans() {
    return [
      {
        'price': 139,
        'validity': '28 Days',
        'data': 'NA',
        'sms': 'NA',
        'perDay': 4.96,
        'description': 'Add-On Data pack for ULD users: Unlimited Data, valid for 28 days or ULD pack expiry whichever is earlier. No SV| | UL Data,28D* No SVI',
      },
      {
        'price': 26,
        'validity': '1 Days',
        'data': '1.5GB',
        'sms': 'NA',
        'perDay': 26.00,
        'description': 'Get 1.5 GB Data for 1 day (Expires at 11-59 PM). No service validity. Comm:m0% | 1.5GB Data, ID|Comm:m0%',
      },
      {
        'price': 101,
        'validity': '30 Days',
        'data': '5GB',
        'sms': 'NA',
        'perDay': 3.37,
        'description': 'Get 5GB with 1 month of JioHotstar mobile subscription. Validity:30D. No Service Validity|Comm:m0% | 5GB+JioHOTSTAR IM,30D.NO SV/Comm:m0%',
      },
      {
        'price': 23,
        'validity': '1 Days',
        'data': '1GB',
        'sms': 'NA',
        'perDay': 23.00,
        'description': 'Add-On Data pack: Get 1GB for 1 day (till 11:59 PM). No Service Validity. No Outgoing SMS|Comm:m0% | 1GB for 1Day*, NO SV|Comm:m0%',
      },
      {
        'price': 33,
        'validity': '2 Days',
        'data': '2GB',
        'sms': 'NA',
        'perDay': 16.50,
        'description': 'Add-On Data pack: Get 2GB Data valid for 2 Days. No Service Validity. Comm:m0% | 2GB for 2Days, No SV*|Comm:m0%',
      },
    ];
  }

  List<Map<String, dynamic>> _getUnlimitedPlans() {
    return [];
  }

  List<Map<String, dynamic>> _getDataPlans() {
    return [];
  }

  List<Map<String, dynamic>> _getTalktimePlans() {
    return [];
  }

  List<Map<String, dynamic>> _getComboPlans() {
    return [];
  }
}

class _PlansList extends StatelessWidget {
  final List<Map<String, dynamic>> plans;

  const _PlansList({required this.plans});

  @override
  Widget build(BuildContext context) {
    if (plans.isEmpty) {
      return const Center(
        child: Text('No plans available'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.withOpacity(0.1)),
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
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1976D2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '₹ ${plan['price']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        // TODO: Select plan
                      },
                      child: const Text(
                        'select',
                        style: TextStyle(
                          color: Color(0xFF2196F3),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _PlanInfo(label: 'Validity', value: plan['validity']),
                    const SizedBox(width: 16),
                    _PlanInfo(
                      label: 'Data',
                      value: plan['data'],
                      icon: Icons.wifi,
                    ),
                    const SizedBox(width: 16),
                    _PlanInfo(
                      label: 'SMS',
                      value: plan['sms'],
                      icon: Icons.email,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Per Day Cost: ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '₹ ${plan['perDay'].toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  plan['description'],
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PlanInfo extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const _PlanInfo({
    required this.label,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: const Color(0xFF757575)),
          const SizedBox(width: 4),
        ],
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212121),
          ),
        ),
      ],
    );
  }
}
