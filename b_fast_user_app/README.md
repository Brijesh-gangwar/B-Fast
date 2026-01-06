# b_fast_user_app

Flutter client for the B-Fast experience with authentication, product browsing, cart, checkout, and order tracking.

## Features
- Clerk authentication flow with walkthrough, splash routing, and persisted user sessions.
- Product catalogue with cart, wishlist, and order management backed by REST APIs.
- Address capture with geolocation/geocoding support and profile form flow.
- Cashfree payment integration and OTP/PIN flows.
- Cached images, shimmer loading states, and toasts for feedback.
- Local preferences for lightweight persistence and theming via `Provider` state management.

## Folder Structure
```
assets/
	images/
	logo/
lib/
	data/               // shared colors, constants, and assets helpers
	icons/              // custom icon widgets
	models/             // app data models (product, cart, order, address, user)
	providers/          // state management for cart, wishlist, orders, users, addresses
	screens/
		auth/             // walkthrough/auth/login-related UI
		cart_screen.dart
		category_screen.dart
		home_scren.dart
		main_screen.dart
		order_screen.dart
		product_screen.dart
		profile_screen.dart
		wishlist_screen.dart
	services/           // API/auth/payment/address service wrappers
	widgets/            // reusable UI components
	main.dart           // app bootstrap, routing, provider wiring
```

## Key Packages
- `clerk_flutter`, `clerk_auth` for auth
- `provider` for state management
- `http` for REST calls
- `geolocator`, `geocoding` for location and address lookup
- `flutter_cashfree_pg_sdk` for payments
- `cached_network_image`, `shimmer` for media and skeletons
- `shared_preferences` for local storage
- `pinput`, `fluttertoast`, `flutter_launcher_icons` for UI polish

## Getting Started
1) Install Flutter (3.7+ recommended) and run `flutter pub get`.
2) Add any required secrets in `lib/secrets.dart` (API base URLs, keys).
3) Run on a device or emulator: `flutter run`.
4) Build release artifacts: `flutter build apk`.

