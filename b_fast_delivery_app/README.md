# B-Fast Delivery App

A Flutter-based delivery application for managing orders, tracking deliveries, and driver operations.

## Features

- **Authentication** - User login and registration system
- **Dashboard** - Main overview and analytics
- **Orders Management** - View, accept, and manage delivery orders
- **Profile** - User profile management
- **Verification** - Driver verification and approval process
- **Real-time Location** - GPS tracking and location services
- **Maps Integration** - OSM (OpenStreetMap) integration for navigation

## Project Structure

```
lib/
├── main.dart                 # Application entry point
├── core/                     # Core functionality and utilities
│   ├── secrets.dart         # API keys and configuration
│   └── helpers/             # Helper functions and utilities
└── features/                # Feature modules
    ├── auth/               # Authentication feature
    ├── dashboard/          # Dashboard feature
    ├── orders/             # Order management feature
    ├── profile/            # User profile feature
    └── waiting_verification/ # Verification feature
```

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- Android SDK (for Android development)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd b_fast_delivery_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Dependencies

Key packages used in this project:
- `flutter_osm_plugin` - OpenStreetMap integration
- `geolocator` - Location services
- `permission_handler` - Handle device permissions
- `package_info_plus` - Package information
- `path_provider` - File system paths
- `shared_preferences` - Local data storage
- `url_launcher` - Launch URLs

## Configuration

Update [core/secrets.dart](lib/core/secrets.dart) with your API keys and configuration before running the app.

## Build

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Version

Current version: 1.0

## Support

For help getting started with Flutter development:
- [Flutter Documentation](https://docs.flutter.dev/)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
- [Dart Documentation](https://dart.dev/guides)
