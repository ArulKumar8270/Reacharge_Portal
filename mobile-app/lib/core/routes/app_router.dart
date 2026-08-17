import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/config/app_config.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/address_details_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/ecommerce/presentation/pages/product_list_page.dart';
import '../../features/ecommerce/presentation/pages/product_detail_page.dart';
import '../../features/ecommerce/presentation/pages/cart_page.dart';
import '../../features/ecommerce/presentation/pages/checkout_page.dart';
import '../../features/wallet/presentation/pages/wallet_page.dart';
import '../../features/wallet/presentation/pages/add_money_page.dart';
import '../../features/wallet/presentation/pages/transaction_history_page.dart';
import '../../features/recharge/presentation/pages/recharge_page.dart';
import '../../features/recharge/presentation/pages/mobile_recharge_page.dart';
import '../../features/recharge/presentation/pages/dth_recharge_page.dart';
import '../../features/recharge/presentation/pages/fastag_recharge_page.dart';
import '../../features/recharge/presentation/pages/all_services_page.dart';
import '../../features/bills/presentation/pages/bills_page.dart';
import '../../features/bills/presentation/pages/electricity_bill_page.dart';
import '../../features/bills/presentation/pages/water_bill_page.dart';
import '../../features/bills/presentation/pages/gas_bill_page.dart';
import '../../features/bills/presentation/pages/broadband_bill_page.dart';
import '../../features/bills/presentation/pages/insurance_bill_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/orders/presentation/pages/order_detail_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        final isLoggedIn = authProvider.isAuthenticated;
        final location = state.matchedLocation;
        final isGoingToAuth = location == '/login' || 
                              location == '/register' ||
                              location == '/forgot-password' ||
                              location == '/reset-password' ||
                              location == '/otp-verification' ||
                              location == '/address-details';
        final isGoingToProfile = location == '/profile';
        
        // Hide recharge/bills flow — redirect to shop
        if (!AppConfig.enableRechargeFlow &&
            (location.startsWith('/recharge') ||
                location.startsWith('/bills') ||
                location == '/services')) {
          return '/products';
        }
        
        // Allow profile page and address details to be accessed without login
        if (!isLoggedIn && !isGoingToAuth && !isGoingToProfile) {
          return '/login';
        }
        
        // If logged in and trying to access auth pages (except OTP), redirect to home
        if (isLoggedIn && isGoingToAuth && location != '/otp-verification') {
          return '/home';
        }
        
        return null;
      },
      refreshListenable: authProvider,
      routes: [
      // Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/otp-verification',
        builder: (context, state) => const OtpVerificationPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordPage(),
      ),
      GoRoute(
        path: '/address-details',
        builder: (context, state) => const AddressDetailsPage(),
      ),
      
      // Home
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      
      // E-commerce Routes
      GoRoute(
        path: '/products',
        builder: (context, state) => const ProductListPage(),
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProductDetailPage(productId: id);
        },
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutPage(),
      ),
      
      // Wallet Routes
      GoRoute(
        path: '/wallet',
        builder: (context, state) => const WalletPage(),
      ),
      GoRoute(
        path: '/wallet/add-money',
        builder: (context, state) => const AddMoneyPage(),
      ),
      GoRoute(
        path: '/wallet/transactions',
        builder: (context, state) => const TransactionHistoryPage(),
      ),
      
      // Recharge Routes
      GoRoute(
        path: '/recharge',
        builder: (context, state) => const RechargePage(),
      ),
      GoRoute(
        path: '/recharge/mobile',
        builder: (context, state) => const MobileRechargePage(),
      ),
      GoRoute(
        path: '/recharge/dth',
        builder: (context, state) => const DthRechargePage(),
      ),
      GoRoute(
        path: '/recharge/fastag',
        builder: (context, state) => const FastagRechargePage(),
      ),
      GoRoute(
        path: '/services',
        builder: (context, state) => const AllServicesPage(),
      ),
      
      // Bills Routes
      GoRoute(
        path: '/bills',
        builder: (context, state) => const BillsPage(),
      ),
      GoRoute(
        path: '/bills/electricity',
        builder: (context, state) => const ElectricityBillPage(),
      ),
      GoRoute(
        path: '/bills/water',
        builder: (context, state) => const WaterBillPage(),
      ),
      GoRoute(
        path: '/bills/gas',
        builder: (context, state) => const GasBillPage(),
      ),
      GoRoute(
        path: '/bills/broadband',
        builder: (context, state) => const BroadbandBillPage(),
      ),
      GoRoute(
        path: '/bills/insurance',
        builder: (context, state) => const InsuranceBillPage(),
      ),
      
      // Orders Routes
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersPage(),
      ),
      GoRoute(
        path: '/order/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return OrderDetailPage(orderId: id);
        },
      ),
      
      // Profile
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      ],
    );
  }
}

