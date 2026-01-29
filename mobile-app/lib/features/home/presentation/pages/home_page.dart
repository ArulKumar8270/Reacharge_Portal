import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/cart_provider.dart';
import '../../../../core/providers/wallet_provider.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/services/api_service.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../profile/presentation/pages/settings_page.dart';
import '../../../ecommerce/data/models/product_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool _showAppLockDialog = true; // Show dialog on first load
  
  @override
  void initState() {
    super.initState();
    // Load wallet balance on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final walletProvider = Provider.of<WalletProvider>(context, listen: false);
      walletProvider.getWalletBalance();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const _HomeTab(),
          const _ReportsTab(),
          const _SupportTab(),
          const _SettingsTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF2196F3),
        unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          elevation: 8,
          backgroundColor: Colors.white,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined),
              activeIcon: Icon(Icons.description),
              label: 'Reports',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.headphones_outlined),
              activeIcon: Icon(Icons.headphones),
              label: 'Support',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  bool _showAppLockDialog = true;
  bool _isRechargeMode = true; // true for Recharge, false for Shopping

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final walletProvider = Provider.of<WalletProvider>(context, listen: false);
      walletProvider.getWalletBalance();
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // Light blue background
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Greeting Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        final userName = auth.user?.name ?? 'User';
                        return Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.grey,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_getGreeting()}, ',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF212121),
                                    ),
                                  ),
                                  Text(
                                    userName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF212121),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2196F3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chat_bubble_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Recharge/Shopping Toggle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isRechargeMode = true;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _isRechargeMode
                                    ? const Color(0xFF2196F3)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  'Recharge',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _isRechargeMode
                                        ? Colors.white
                                        : const Color(0xFF757575),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isRechargeMode = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isRechargeMode
                                    ? const Color(0xFF2196F3)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  'Shopping',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: !_isRechargeMode
                                        ? Colors.white
                                        : const Color(0xFF757575),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Conditional Content based on Toggle
                if (_isRechargeMode) ...[
                ] else ...[
                  // Shopping Mode Content - Products Grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Shop Now',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF212121),
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.push('/products'),
                                child: const Text('View all', style: TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.w600)),
                              ),
                            Consumer<CartProvider>(
                              builder: (context, cart, _) {
                                return Stack(
                                  children: [
          IconButton(
                                      icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => context.push('/cart'),
                                      color: const Color(0xFF2196F3),
                                    ),
                                    if (cart.itemCount > 0)
                                      Positioned(
                                        right: 8,
                                        top: 8,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFEF4444),
                                            shape: BoxShape.circle,
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 16,
                                            minHeight: 16,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${cart.itemCount > 9 ? '9+' : cart.itemCount}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const _ProductsGrid(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Recharge And Bills Section (only show in Recharge mode)
                if (_isRechargeMode)
                  Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recharge And Bills',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212121),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Column(
                          children: [
                            // Row 1
                            Row(
                              children: [
                                Expanded(
                                  child: _ServiceGridItem(
                                    icon: Icons.sim_card,
                                    title: 'Prepaid',
                                    onTap: () => context.push('/recharge/mobile'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _ServiceGridItem(
                                    icon: Icons.satellite_alt,
                                    title: 'DTH',
                                    onTap: () => context.push('/recharge/dth'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _ServiceGridItem(
                                    icon: Icons.qr_code,
                                    title: 'Redeem Code',
                                    onTap: () {},
                                  ),
                                ),
                              ],
                            ),
                            // Red divider
                            Container(
                              height: 10,
                              margin: const EdgeInsets.symmetric(vertical: 2),
                            ),
                            // Row 2
                            Row(
                              children: [
                                Expanded(
                                  child: _ServiceGridItem(
                                    icon: Icons.credit_card,
                                    title: 'FastTag',
                                    onTap: () => context.push('/recharge/fastag'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _ServiceGridItem(
                                    icon: Icons.bolt,
                                    title: 'Electricity',
                                    onTap: () => context.push('/bills/electricity'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _ServiceGridItem(
                                    icon: Icons.phone_android,
                                    title: 'Postpaid',
                                    onTap: () {},
                                  ),
                                ),
                              ],
                            ),
                            // Red divider
                            Container(
                              height: 10,
                              margin: const EdgeInsets.symmetric(vertical: 2),
                            ),
                            // Row 3
                            Row(
                              children: [
                                Expanded(
                                  child: _ServiceGridItem(
                                    icon: Icons.phone,
                                    title: 'Landline',
                                    onTap: () {},
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _ServiceGridItem(
                                    icon: Icons.local_gas_station,
                                    title: 'Gas Bill',
                                    onTap: () => context.push('/bills/gas'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _ServiceGridItem(
                                    icon: Icons.water_drop,
                                    title: 'Water Bill',
                                    onTap: () => context.push('/bills/water'),
                                  ),
                                ),
                              ],
                            ),
                            // Row 4 (if needed)
                            Container(
                              height: 10,
                              margin: const EdgeInsets.symmetric(vertical: 2),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: _ServiceGridItem(
                                    icon: Icons.shield,
                                    title: 'Insurance',
                                    onTap: () => context.push('/bills/insurance'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _ServiceGridItem(
                                    icon: Icons.router,
                                    title: 'Broadband',
                                    onTap: () => context.push('/bills/broadband'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _ServiceGridItem(
                                    icon: Icons.receipt,
                                    title: 'Pay Bills',
                                    onTap: () => context.push('/bills'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () => context.push('/services'),
                          child: const Text(
                            'View All Services',
                            style: TextStyle(
                              color: Color(0xFF2196F3),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // DTH Promotional Banner (only in Recharge mode)
                if (_isRechargeMode) ...[
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.satellite_alt,
                          color: Colors.white,
                          size: 60,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              children: [
                                TextSpan(text: '>>> Recharge Your '),
                                TextSpan(
                                  text: 'DTH',
                                  style: TextStyle(color: Color(0xFFFF9800)),
                                ),
                                TextSpan(text: ' in Seconds Entertainment Never Stops!'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // App Branding
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'Made With ❤️',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF757575),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Powered by Mobirec Pvt Ltd',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF757575),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Mobile Recharge Commission App',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 100), // Space for bottom nav
              ],
            ),
          ),
          
          // App Lock Dialog
          if (_showAppLockDialog)
            Positioned(
              bottom: 80,
              left: 16,
              right: 16,
              child: _AppLockDialog(
                onClose: () => setState(() => _showAppLockDialog = false),
                onMaybeLater: () => setState(() => _showAppLockDialog = false),
                onProceed: () {
                  setState(() => _showAppLockDialog = false);
                  // TODO: Navigate to app lock setup
                },
              ),
          ),
        ],
      ),
    );
  }
}

class _ServiceGridItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ServiceGridItem({
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF1976D2),
                size: 30,
              ),
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF212121),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppLockDialog extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onMaybeLater;
  final VoidCallback onProceed;

  const _AppLockDialog({
    required this.onClose,
    required this.onMaybeLater,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Turn on App Lock',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: onClose,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Add a extra layer of Security',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF757575),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onMaybeLater,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  child: const Text(
                    'Maybe Later',
                    style: TextStyle(
                      color: Color(0xFF212121),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onProceed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Proceed',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportsTab extends StatelessWidget {
  const _ReportsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Reports',
          style: TextStyle(color: Color(0xFF212121)),
        ),
      ),
      body: const Center(
        child: Text('Reports Coming Soon'),
      ),
    );
  }
}

class _SupportTab extends StatelessWidget {
  const _SupportTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Support',
          style: TextStyle(color: Color(0xFF212121)),
        ),
      ),
      body: const Center(
        child: Text('Support Coming Soon'),
      ),
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return const SettingsPage();
  }
}

class _ProductsGrid extends StatefulWidget {
  const _ProductsGrid();

  @override
  State<_ProductsGrid> createState() => _ProductsGridState();
}

class _ProductsGridState extends State<_ProductsGrid> {
  final ApiService _apiService = ApiService();
  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await _apiService.get('/products');
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> productsData = response['data'] is List
            ? response['data']
            : (response['data']['products'] ?? []);
        
        setState(() {
          _products = productsData
              .map((json) => Product.fromJson(json))
              .where((product) => product.isAvailable)
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _products = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(
            color: Color(0xFF2196F3),
          ),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Failed to load products',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loadProducts,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              const Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'No products available',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.push('/products'),
                icon: const Icon(Icons.shopping_bag),
                label: const Text('Browse All Products'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return _ProductCard(product: product);
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: () => context.push('/product/${product.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: product.images.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: Image.network(
                          product.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 40,
                              color: Color(0xFF757575),
                            ),
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 40,
                          color: Color(0xFF757575),
                        ),
                      ),
              ),
            ),
            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212121),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          '₹${product.finalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2196F3),
                          ),
                        ),
                        if (product.hasDiscount) ...[
                          const SizedBox(width: 8),
                          Text(
                            '₹${product.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${product.discountPercentage.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (product.rating != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: Color(0xFFFF9800),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${product.rating!.toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
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
