# Football Stats Flutter App

A comprehensive Flutter application for football statistics with real-time data and analytics, built with Riverpod state management and Firebase backend.

## Features

### ✅ Completed Features

#### 🔐 Authentication System
- **Email/Password Authentication** with Firebase Auth
- **Google Sign-In** integration
- **User Profile Management** with editable fields
- **Password Reset** functionality
- **Email Verification** system
- **Account Deletion** option

#### 🏠 Dashboard & Navigation
- **Modern Dashboard** with greeting, quick stats, and favorite teams
- **Bottom Navigation** for mobile with 5 main sections
- **Responsive Design** that adapts to different screen sizes
- **Dark/Light Theme** toggle with system preference support
- **Smooth Animations** and transitions throughout the app

#### ⚽ Leagues & Standings
- **Leagues Overview** with search and filtering capabilities
- **Interactive Standings Table** with sortable columns
- **Tabbed Views** for Overall/Home/Away standings
- **Color-coded Position** indicators (Champions League, Europa League, Relegation)
- **Team Performance** metrics and statistics
- **League Information** cards with season details

#### ⚙️ Settings & Preferences
- **Theme Management** (Light/Dark/System)
- **Profile Settings** with editable user information
- **App Information** and version details
- **Account Management** (Sign out, delete account)
- **Preference Controls** for notifications and data management

#### 🎨 UI/UX Design
- **Material Design 3** implementation
- **Custom Color Scheme** with football-themed colors
- **Consistent Typography** using Inter font family
- **Responsive Layout** for mobile, tablet, and desktop
- **Loading States** and error handling throughout
- **Smooth Animations** and micro-interactions

### 🚧 Planned Features

#### 📊 Advanced Features (In Development)
- **Real-time Match Data** from Football API
- **Detailed Team Profiles** with squad information
- **Fixture Scheduling** and live match updates
- **Advanced Analytics** and performance charts
- **Favorites System** for teams and leagues
- **Push Notifications** for match updates
- **Offline Capability** with local caching

## Technical Architecture

### 🏗️ Project Structure
```
lib/
├── core/                     # Core utilities and shared components
│   ├── constants/           # App constants and configuration
│   ├── config/             # Firebase and app configuration  
│   ├── error/              # Error handling and exceptions
│   ├── network/            # HTTP client and API configuration
│   ├── theme/              # App theming and colors
│   ├── utils/              # Utility functions and validators
│   └── widgets/            # Reusable core widgets
├── features/                # Feature-based modules
│   ├── authentication/     # User authentication system
│   ├── dashboard/          # Home dashboard
│   ├── leagues/            # League management
│   ├── standings/          # League standings
│   ├── settings/           # App settings
│   └── [other features]/   # Additional feature modules
├── shared/                  # Shared components across features
│   ├── data/               # Data models and repositories
│   ├── providers/          # Global Riverpod providers
│   └── widgets/            # Shared UI components
├── navigation/             # App routing and navigation
└── main.dart              # Application entry point
```

### 🔧 State Management
- **Flutter Riverpod** for reactive state management
- **Provider Pattern** for dependency injection
- **StateNotifier** for complex state logic
- **FutureProvider/StreamProvider** for async data
- **Automatic Disposal** and lifecycle management

### 🗄️ Data Layer
- **Firebase Firestore** for cloud database
- **Firebase Auth** for user authentication
- **Hive** for local storage and caching
- **Data Models** with Freezed for immutability
- **Repository Pattern** for data abstraction

### 🛡️ Error Handling
- **Custom Exception Classes** for different error types
- **Failure Objects** for result handling
- **Global Error Handling** with user-friendly messages
- **Network Error** detection and offline handling
- **Validation** with comprehensive form validators

## Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter_riverpod: ^2.4.9        # State management
  firebase_core: ^2.24.2          # Firebase core
  firebase_auth: ^4.15.3          # Authentication
  cloud_firestore: ^4.13.6        # Database
  google_sign_in: ^6.1.6          # Google authentication
  go_router: ^12.1.3              # Navigation
  hive_flutter: ^1.1.0            # Local storage
  dio: ^5.4.0                     # HTTP client
  connectivity_plus: ^5.0.2       # Network status
  cached_network_image: ^3.3.0    # Image caching
  intl: ^0.19.0                   # Internationalization
```

### Development Dependencies
```yaml
dev_dependencies:
  freezed: ^2.4.6                 # Code generation
  json_serializable: ^6.7.1      # JSON serialization
  riverpod_generator: ^2.3.9     # Provider generation
  build_runner: ^2.4.7           # Code generation runner
  flutter_lints: ^3.0.1          # Linting rules
```

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Firebase project setup
- Android Studio / VS Code
- Git for version control

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd football_stats
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Configure Firebase for Flutter
   firebase init
   flutterfire configure
   ```

4. **Generate code files**
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

5. **Run the application**
   ```bash
   flutter run
   ```

### Configuration

1. **Firebase Configuration**
   - Update `lib/core/config/firebase_config.dart` with your Firebase project credentials
   - Ensure Firestore rules are properly configured
   - Enable Authentication providers (Email/Password, Google)

2. **API Configuration**
   - Update `lib/core/constants/app_constants.dart` with your API endpoints
   - Configure API keys and base URLs

## Code Generation Commands

The project uses code generation for models and providers:

```bash
# Generate all files
flutter packages pub run build_runner build --delete-conflicting-outputs

# Watch for changes (development)
flutter packages pub run build_runner watch --delete-conflicting-outputs

# Clean generated files
flutter packages pub run build_runner clean
```

## Firebase Integration

### Authentication
- Email/Password sign-in and registration
- Google Sign-In integration
- Password reset functionality
- Email verification
- User profile management

### Firestore Database
- User profiles and settings
- League and team data
- Favorites and user preferences
- Real-time data synchronization

### Security Rules
- User-based access control
- Data validation rules
- Read/write permissions

## Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run tests with coverage
flutter test --coverage
```

## Building for Production

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## Performance Optimization

- **Lazy Loading** for large datasets
- **Image Caching** with cached_network_image
- **State Management** optimization with Riverpod
- **Build Optimization** with const constructors
- **Bundle Size** optimization

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/new-feature`)
5. Create a Pull Request

## Code Style

- Follow Flutter/Dart style guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Maintain consistent file structure
- Use proper error handling

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support and questions:
- Create an issue in the GitHub repository
- Check the documentation for common solutions
- Review the Firebase setup guide

---

**Version:** 1.0.0  
**Last Updated:** January 2025  
**Flutter Version:** 3.19.0+  
**Dart Version:** 3.3.0+