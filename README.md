# B-Fast

<div align="center">
  <img src="b_fast_user_app/assets/logo/app_logo.png" alt="B-Fast Logo" width="200">
</div>

B-Fast is a comprehensive fast-delivery application platform consisting of three main components:

## Project Structure

### `b_fast_backend/`
The backend built with Convex, a Backend-as-a-Service platform. Handles all business logic, API endpoints, and database operations using Convex queries, mutations, and HTTP endpoints.

**Key Components:**
- `convex/` - Convex functions, queries, mutations, and schema definitions
- `package.json` - Backend dependencies and scripts

### `b_fast_delivery_app/`
A Flutter-based mobile application for delivery agents. Enables delivery personnel to manage and track deliveries in real-time.

**Key Components:**
- `lib/` - Flutter application source code
- `android/` - Android-specific configuration and build files
- `assets/` - Images, logos, and other media files
- `pubspec.yaml` - Flutter dependencies and project configuration

### `b_fast_user_app/`
A Flutter-based mobile application for end users. Provides a complete e-commerce and fast-delivery experience for customers.

**Key Components:**
- `lib/` - Flutter application source code with models, screens, services, and widgets
- `android/` - Android-specific configuration and build files
- `assets/` - Images, logos, and other media files
- `pubspec.yaml` - Flutter dependencies and project configuration

## Technology Stack

- **Backend:** Convex (Backend-as-a-Service) with queries, mutations, and HTTP endpoints
- **Authentication:** Clerk for user authentication and management
- **Frontend (Apps):** Flutter
- **Maps:** OpenStreetMap (OSM) for location and delivery tracking
- **Platform:** Android (with potential for iOS)
- **Payments:** Cashfree PG SDK integration
- **Geolocation:** Geolocator and Geocoding services
- **Storage:** SQLite, Shared Preferences

## Getting Started

Each folder contains its own README.md with specific setup instructions and requirements for that component.