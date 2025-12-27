# Nexus Mobile App

Flutter mobile application for Nexus E-commerce + Wallet + Recharge + Utility Bill Payments.

## Features

- ✅ Project structure setup
- ✅ Authentication flow
- ✅ Navigation setup
- ✅ State management (Provider)
- 🚧 E-commerce module (In Progress)
- 🚧 Wallet module (In Progress)
- 🚧 Recharge services (In Progress)
- 🚧 Utility bill payments (In Progress)

## Tech Stack

- **Framework**: Flutter
- **State Management**: Provider
- **Navigation**: go_router
- **HTTP Client**: Dio
- **Local Storage**: Hive, SharedPreferences
- **Payment**: Razorpay Flutter

## Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Android Studio / Xcode
- Android SDK / iOS SDK

### Installation

```bash
# Get dependencies
flutter pub get

# Run the app
flutter run
```

### For iOS

```bash
cd ios
pod install
cd ..
flutter run
```

## Project Structure

```
lib/
├── core/
│   ├── config/         # App configuration
│   ├── routes/          # Navigation routes
│   ├── theme/           # App theme
│   ├── providers/       # Global providers
│   └── services/        # Core services
├── features/
│   ├── auth/            # Authentication
│   ├── home/            # Home screen
│   ├── ecommerce/       # E-commerce module
│   ├── wallet/          # Wallet module
│   ├── recharge/        # Recharge services
│   ├── bills/           # Utility bills
│   ├── orders/          # Order management
│   └── profile/         # User profile
└── main.dart            # Entry point
```

## Configuration

Update API base URL in `lib/core/config/app_config.dart`:

```dart
static const String baseUrl = 'http://your-api-url.com/api';
```

Update Razorpay key in `lib/core/config/app_config.dart`:

```dart
static const String razorpayKeyId = 'YOUR_RAZORPAY_KEY_ID';
```

## Features Overview

### Authentication
- Login/Register
- OTP Verification
- Password Reset

### E-Commerce
- Product listing
- Product details
- Shopping cart
- Checkout
- Order management

### Wallet
- View balance
- Add money
- Transaction history
- Internal transfers

### Recharge
- Mobile recharge
- DTH recharge
- FASTag recharge

### Utility Bills
- Electricity bill
- Water bill
- Gas bill
- Broadband bill
- Insurance premium

## State Management

The app uses Provider for state management:

- `AuthProvider` - Authentication state
- `CartProvider` - Shopping cart state
- `WalletProvider` - Wallet state

## API Integration

API calls are made through:
- `ApiService` - Core HTTP service
- Feature-specific repositories (e.g., `AuthRepository`, `WalletRepository`)

## Building for Production

### Android

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## Testing

```bash
flutter test
```

## License

Proprietary - All rights reserved

