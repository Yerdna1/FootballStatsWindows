# Football Stats Application

A comprehensive football statistics application featuring a Flutter mobile frontend and Firebase backend with real-time data synchronization, analytics, and modern UI/UX design.

## 🏆 Overview

Football Stats is a complete solution for football enthusiasts providing:
- **Real-time football data** from external APIs
- **Cross-platform Flutter mobile app** (iOS, Android, Web)
- **Scalable Firebase backend** with Cloud Functions
- **Modern UI/UX design** with dark/light theme support
- **User authentication** and personalized experiences
- **Offline capabilities** with local caching
- **Push notifications** for match updates

## 🚀 Quick Start

### Prerequisites

- **Flutter SDK** (>=3.0.0)
- **Node.js** (>=18.0.0)
- **Firebase CLI** (`npm install -g firebase-tools`)
- **Git** for version control
- **Firebase Project** with required services enabled

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd football_stats
   ```

2. **Flutter App Setup**
   ```bash
   # Install Flutter dependencies
   flutter pub get
   
   # Configure Firebase for Flutter
   firebase login
   flutterfire configure
   
   # Generate code files
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

3. **Firebase Backend Setup**
   ```bash
   # Navigate to functions directory
   cd functions
   
   # Install dependencies
   npm install
   
   # Set up environment variables
   cp .env.example .env
   # Edit .env with your configuration
   
   # Deploy to Firebase
   firebase deploy
   ```

4. **Run the Application**
   ```bash
   # Run Flutter app
   flutter run
   
   # For web
   flutter run -d chrome
   
   # For specific device
   flutter devices
   flutter run -d <device-id>
   ```

## 📱 Application Features

### ✅ Implemented Features

#### Authentication & User Management
- Email/Password authentication with Firebase Auth
- Google Sign-In integration
- User profile management and settings
- Password reset and email verification
- Account deletion functionality

#### Core Football Features
- **Dashboard**: Personalized home screen with quick stats
- **Leagues**: Browse and search football leagues
- **Standings**: Interactive league tables with sorting
- **Teams**: Detailed team information and statistics
- **Fixtures**: Match schedules and results
- **Favorites**: Save favorite teams and leagues

#### Technical Features
- **Responsive Design**: Adapts to mobile, tablet, and desktop
- **Dark/Light Themes**: System preference support
- **Offline Support**: Local caching with Hive
- **Real-time Updates**: Firebase Firestore synchronization
- **Error Handling**: Comprehensive error management
- **State Management**: Riverpod for reactive programming

### 🚧 Planned Enhancements
- Live match tracking and scores
- Advanced analytics and predictions
- Social features and user interactions
- Push notifications for match updates
- Multi-language support
- Enhanced offline capabilities

## 🏗️ Technical Architecture

### Frontend (Flutter)
```
lib/
├── core/                   # Core utilities and configuration
│   ├── config/            # Firebase and app configuration
│   ├── constants/         # App constants
│   ├── error/            # Error handling
│   ├── network/          # HTTP client setup
│   ├── theme/            # App theming
│   └── utils/            # Utility functions
├── features/              # Feature-based modules
│   ├── authentication/   # User authentication
│   ├── dashboard/        # Home dashboard
│   ├── leagues/          # League management
│   ├── standings/        # League standings
│   ├── teams/            # Team information
│   ├── fixtures/         # Match fixtures
│   └── settings/         # App settings
├── shared/               # Shared components
│   ├── data/            # Data models and repositories
│   ├── providers/       # Global Riverpod providers
│   └── widgets/         # Reusable UI components
├── navigation/          # App routing
└── main.dart           # Application entry point
```

### Backend (Firebase)
```
functions/
├── src/
│   ├── api/              # HTTP API endpoints
│   │   ├── routes/       # Express route handlers
│   │   └── callable.ts   # Callable functions
│   ├── scheduled/        # Scheduled functions
│   ├── triggers/         # Firestore & Auth triggers
│   ├── services/         # Business logic services
│   ├── utils/            # Utility functions
│   └── types/            # TypeScript definitions
├── package.json          # Dependencies
└── tsconfig.json         # TypeScript configuration
```

### Database Schema (Firestore)
- **users**: User profiles and preferences
- **leagues**: Football leagues information
- **teams**: Team details and statistics
- **fixtures**: Match fixtures and results
- **standings**: League standings data
- **user_favorites**: User's favorite teams/leagues
- **notifications**: Push notifications
- **analytics_cache**: Cached analytics data
- **activity_logs**: User activity tracking

## 🔧 Development

### Flutter Development Commands
```bash
# Install dependencies
flutter pub get

# Generate code files
flutter packages pub run build_runner build --delete-conflicting-outputs

# Run with hot reload
flutter run

# Run tests
flutter test

# Build for production
flutter build apk --release  # Android
flutter build ios --release  # iOS
flutter build web --release  # Web
```

### Firebase Development Commands
```bash
# Install dependencies
cd functions && npm install

# Run local emulators
firebase emulators:start

# Deploy functions
firebase deploy --only functions

# View logs
firebase functions:log

# Run tests
npm test
```

### Code Generation
The project uses code generation for models and providers:
```bash
# Watch for changes (development)
flutter packages pub run build_runner watch --delete-conflicting-outputs

# Clean generated files
flutter packages pub run build_runner clean
```

## 🔒 Security & Authentication

### Firebase Security Rules
- **Authentication-based access control**
- **Role-based permissions** (user, moderator, admin)
- **Resource ownership validation**
- **Data validation rules**
- **Rate limiting at database level**

### User Roles
1. **User**: Basic access to public data and own profile
2. **Moderator**: Can manage leagues, teams, fixtures
3. **Admin**: Full system access including user management

## 📊 Performance & Analytics

### Built-in Features
- **Caching Strategy**: Multi-level caching for optimal performance
- **Rate Limiting**: API protection and fair usage
- **Analytics**: User engagement and system monitoring
- **Error Tracking**: Comprehensive error logging
- **Performance Monitoring**: Real-time performance metrics

### Optimization Features
- **Lazy Loading**: Efficient data loading
- **Image Caching**: Optimized image handling
- **State Management**: Efficient state updates with Riverpod
- **Bundle Optimization**: Minimized app size

## 🌐 Deployment

### Development Environment
```bash
# Deploy to development
firebase use football-stats-dev
firebase deploy

# Deploy Flutter web to development
flutter build web
firebase deploy --only hosting
```

### Production Environment
```bash
# Deploy to production
firebase use football-stats-prod
firebase deploy --only functions,firestore,storage

# Deploy Flutter production builds
flutter build apk --release
flutter build ios --release
flutter build web --release
```

## 📚 Documentation

### Available Documentation
- **[API Documentation](docs/API.md)**: Complete API endpoint reference
- **[Architecture Guide](docs/ARCHITECTURE.md)**: Technical architecture details
- **[Deployment Guide](docs/DEPLOYMENT.md)**: Production deployment instructions
- **[User Manual - English](docs/USER_MANUAL_EN.md)**: End-user guide in English
- **[User Manual - Slovak](docs/USER_MANUAL_SK.md)**: End-user guide in Slovak
- **[Developer Guide](docs/DEVELOPER_GUIDE.md)**: Contributing and development setup
- **[Troubleshooting](docs/TROUBLESHOOTING.md)**: Common issues and solutions

### Quick Links
- **Flutter Documentation**: [README_FLUTTER.md](README_FLUTTER.md)
- **Firebase Documentation**: [README_FIREBASE.md](README_FIREBASE.md)

## 🛠️ Technology Stack

### Frontend
- **Flutter**: Cross-platform UI framework
- **Dart**: Programming language
- **Riverpod**: State management
- **Go Router**: Navigation
- **Hive**: Local storage
- **Firebase SDK**: Backend integration

### Backend
- **Firebase Functions**: Serverless functions
- **TypeScript**: Programming language
- **Express.js**: Web framework
- **Firestore**: NoSQL database
- **Firebase Auth**: Authentication service
- **Firebase Storage**: File storage

### External Services
- **Football API**: Live football data
- **Firebase Analytics**: Usage analytics
- **Firebase Messaging**: Push notifications

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

We welcome contributions! Please see our [Developer Guide](docs/DEVELOPER_GUIDE.md) for detailed information on:
- Development setup
- Code style guidelines
- Pull request process
- Issue reporting

## 📞 Support

For support and questions:
- Create an issue in the GitHub repository
- Check the [Troubleshooting Guide](docs/TROUBLESHOOTING.md)
- Review the documentation for common solutions

## 🎯 Roadmap

### Version 1.1 (Q2 2025)
- Live match tracking
- Enhanced notifications
- Social features

### Version 1.2 (Q3 2025)
- Machine learning predictions
- Advanced analytics
- Multi-language support

### Version 2.0 (Q4 2025)
- Complete redesign
- New features based on user feedback
- Performance optimizations

---

**Version**: 1.0.0  
**Last Updated**: January 2025  
**Flutter Version**: 3.19.0+  
**Node.js Version**: 18+  
**Firebase CLI Version**: Latest

**Built with ❤️ using Flutter, Firebase, and modern development practices.**
