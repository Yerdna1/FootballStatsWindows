# Football Stats - Developer Guide

Welcome to the Football Stats development team! This comprehensive guide will help you set up your development environment, understand our coding standards, and contribute effectively to the project.

## 🚀 Quick Start

### Prerequisites

**Required Software:**
- **Node.js** (v18 or higher) - [Download](https://nodejs.org/)
- **Flutter SDK** (v3.19.0 or higher) - [Install Guide](https://flutter.dev/docs/get-started/install)
- **Firebase CLI** (latest) - `npm install -g firebase-tools`
- **Git** - [Download](https://git-scm.com/)
- **IDE**: VS Code (recommended) or Android Studio

**Recommended Tools:**
- **Postman** or **Insomnia** for API testing
- **Firebase Emulator Suite** for local development
- **Flutter DevTools** for debugging
- **GitHub CLI** for streamlined Git operations

### Development Environment Setup

**1. Clone the Repository**
```bash
git clone https://github.com/your-org/football_stats.git
cd football_stats
```

**2. Setup Flutter Environment**
```bash
# Install Flutter dependencies
flutter pub get

# Enable Flutter web (if needed)
flutter config --enable-web

# Check Flutter doctor
flutter doctor

# Generate code files
flutter packages pub run build_runner build --delete-conflicting-outputs
```

**3. Setup Firebase Environment**
```bash
# Login to Firebase
firebase login

# Install Functions dependencies
cd functions
npm install

# Return to root directory
cd ..

# Setup Firebase project
firebase use --add  # Select your development project

# Start Firebase emulators
firebase emulators:start
```

**4. Environment Configuration**

Create `.env` files for different environments:

**functions/.env.development**
```env
NODE_ENV=development
FOOTBALL_API_KEY=your-dev-api-key
FOOTBALL_API_BASE_URL=https://v3.football.api-sports.io
FIREBASE_PROJECT_ID=football-stats-dev
CACHE_ENABLED=true
RATE_LIMIT_ENABLED=false
LOG_LEVEL=debug
```

**5. IDE Configuration**

**VS Code Extensions (Recommended):**
```json
{
  "recommendations": [
    "Dart-Code.dart-code",
    "Dart-Code.flutter",
    "ms-vscode.vscode-typescript-next",
    "bradlc.vscode-tailwindcss",
    "esbenp.prettier-vscode",
    "ms-vscode.vscode-json",
    "firebase.vscode-firebase-explorer",
    "GitHub.copilot"
  ]
}
```

**VS Code Settings (.vscode/settings.json):**
```json
{
  "dart.flutterSdkPath": "path/to/flutter",
  "dart.previewFlutterUiGuides": true,
  "dart.previewFlutterUiGuidesCustomTracking": true,
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true,
    "source.organizeImports": true
  },
  "[dart]": {
    "editor.defaultFormatter": "Dart-Code.dart-code",
    "editor.selectionHighlight": false,
    "editor.suggest.snippetsPreventQuickSuggestions": false,
    "editor.suggestSelection": "first",
    "editor.tabCompletion": "onlySnippets",
    "editor.wordBasedSuggestions": false
  },
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  }
}
```

## 🏗️ Project Architecture

### Repository Structure

```
football_stats/
├── .github/                    # GitHub workflows and templates
│   ├── workflows/              # CI/CD pipeline definitions
│   ├── ISSUE_TEMPLATE/        # Issue templates
│   └── PULL_REQUEST_TEMPLATE/ # PR templates
├── docs/                      # Project documentation
│   ├── API.md                 # API documentation
│   ├── ARCHITECTURE.md        # Technical architecture
│   ├── DEPLOYMENT.md          # Deployment guide
│   └── DEVELOPER_GUIDE.md     # This file
├── functions/                 # Firebase Cloud Functions
│   ├── src/                   # TypeScript source code
│   ├── lib/                   # Compiled JavaScript (auto-generated)
│   ├── package.json           # Node.js dependencies
│   └── tsconfig.json          # TypeScript configuration
├── lib/                       # Flutter application source
│   ├── core/                  # Core utilities and configuration
│   ├── features/              # Feature-based modules
│   ├── shared/                # Shared components
│   ├── navigation/            # App routing
│   └── main.dart              # Application entry point
├── test/                      # Flutter tests
├── integration_test/          # Integration tests
├── web/                       # Web-specific assets
├── android/                   # Android-specific configuration
├── ios/                       # iOS-specific configuration
├── firebase.json              # Firebase configuration
├── firestore.rules            # Firestore security rules
├── pubspec.yaml               # Flutter dependencies
└── README.md                  # Project overview
```

### Development Workflow

**1. Feature Development Process**
```bash
# Create feature branch
git checkout -b feature/user-authentication

# Make your changes with commits following conventional commits
git commit -m "feat(auth): add Google Sign-In integration"

# Push to remote branch
git push origin feature/user-authentication

# Create pull request via GitHub CLI or web interface
gh pr create --title "Add Google Sign-In Authentication" --body "Implements Google Sign-In with Firebase Auth integration"
```

**2. Code Generation Workflow**
```bash
# Watch for changes during development
flutter packages pub run build_runner watch --delete-conflicting-outputs

# Build once after changes
flutter packages pub run build_runner build --delete-conflicting-outputs

# Clean generated files if needed
flutter packages pub run build_runner clean
```

## 📝 Coding Standards

### Flutter/Dart Guidelines

**1. File Organization**
```dart
// File header comment
/// Authentication service for Firebase Auth integration
/// 
/// Provides methods for user sign-in, sign-out, and profile management

// Imports organized in groups
// 1. Dart imports
import 'dart:async';
import 'dart:convert';

// 2. Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Package imports (alphabetical)
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 4. Local imports (alphabetical)
import '../core/error/exceptions.dart';
import '../core/network/network_info.dart';
```

**2. Naming Conventions**
```dart
// Classes: PascalCase
class UserAuthenticationService {}

// Methods and variables: camelCase
void signInWithGoogle() {}
final String userName = 'John Doe';

// Constants: SCREAMING_SNAKE_CASE
static const String API_BASE_URL = 'https://api.example.com';

// Files: snake_case
// user_authentication_service.dart
// team_details_page.dart
```

**3. Widget Structure**
```dart
class TeamCard extends ConsumerWidget {
  const TeamCard({
    super.key,
    required this.team,
    this.onTap,
  });

  final Team team;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Widget implementation
            ],
          ),
        ),
      ),
    );
  }
}
```

**4. Error Handling**
```dart
// Use Either<Failure, Success> pattern for error handling
Future<Either<Failure, List<Team>>> getTeams() async {
  try {
    final teams = await remoteDataSource.getTeams();
    return Right(teams);
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  } on CacheException catch (e) {
    return Left(CacheFailure(e.message));
  }
}

// Custom exception classes
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
}
```

### TypeScript Guidelines

**1. File Structure**
```typescript
// File header comment
/**
 * User authentication service
 * Handles Firebase Auth operations and user profile management
 */

// Imports organized by type
import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

// Local imports
import { logger } from '../utils/logger';
import { ErrorHandler } from '../utils/error-handler';
import { UserRole, Permission } from '../types';

// Type definitions at the top
interface AuthServiceOptions {
  enableLogging?: boolean;
  rateLimitEnabled?: boolean;
}

// Implementation
export class AuthService {
  // Class implementation
}
```

**2. Function Documentation**
```typescript
/**
 * Authenticates a user and returns user context
 * @param context - Firebase callable context
 * @param requiredRole - Minimum required user role
 * @returns Promise<UserContext> - Authenticated user context
 * @throws HttpsError - When authentication fails
 */
export async function authenticateUser(
  context: functions.https.CallableContext,
  requiredRole?: UserRole
): Promise<UserContext> {
  // Implementation
}
```

**3. Error Handling**
```typescript
// Use custom error classes
export class AuthenticationError extends Error {
  constructor(
    message: string,
    public readonly code: string = 'AUTHENTICATION_FAILED'
  ) {
    super(message);
    this.name = 'AuthenticationError';
  }
}

// Error wrapper for Cloud Functions
export const ErrorHandler = {
  wrapAsyncHandler: (handler: Function) => {
    return async (req: Request, res: Response) => {
      try {
        await handler(req, res);
      } catch (error) {
        logger.error('Request failed', error as Error);
        res.status(500).json({
          error: {
            code: 'INTERNAL_ERROR',
            message: 'An internal error occurred'
          }
        });
      }
    };
  }
};
```

### Code Style Guidelines

**1. General Principles**
- **Consistency**: Follow established patterns throughout the codebase
- **Readability**: Write self-documenting code with clear variable names
- **Performance**: Consider performance implications of your choices
- **Security**: Always validate inputs and sanitize outputs

**2. Comments and Documentation**
```dart
/// A comprehensive service for managing user authentication
/// 
/// This service provides methods for:
/// - User sign-in with email/password and social providers
/// - User profile management and updates
/// - Session management and automatic refresh
/// 
/// Example usage:
/// ```dart
/// final authService = ref.read(authServiceProvider);
/// final result = await authService.signInWithEmail(
///   email: 'user@example.com',
///   password: 'password123',
/// );
/// ```
class AuthenticationService {
  /// Signs in a user with email and password
  /// 
  /// Returns [Either] with [AuthFailure] on error or [User] on success
  Future<Either<AuthFailure, User>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    // Implementation
  }
}
```

**3. Testing Standards**
```dart
// Test file structure
void main() {
  group('AuthenticationService', () {
    late AuthenticationService authService;
    late MockFirebaseAuth mockFirebaseAuth;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      authService = AuthenticationService(mockFirebaseAuth);
    });

    group('signInWithEmail', () {
      test('should return User when sign-in is successful', () async {
        // Arrange
        const tUser = User(id: '123', email: 'test@example.com');
        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => MockUserCredential(tUser));

        // Act
        final result = await authService.signInWithEmail(
          email: 'test@example.com',
          password: 'password123',
        );

        // Assert
        expect(result, equals(const Right(tUser)));
        verify(() => mockFirebaseAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        )).called(1);
      });
    });
  });
}
```

## 🧪 Testing Guidelines

### Testing Strategy

**1. Test Pyramid**
```
    /\
   /  \     E2E Tests (Few)
  /____\    
 /      \   Integration Tests (Some)
/__________\ Unit Tests (Many)
```

**2. Testing Types**

**Unit Tests (lib/test/)**
- Test individual functions and classes
- Mock external dependencies
- Fast execution
- High coverage

**Widget Tests**
- Test UI components in isolation
- Verify widget behavior and rendering
- Test user interactions

**Integration Tests (integration_test/)**
- Test complete user flows
- Test Firebase integration
- Test API communication

### Testing Commands

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/auth/auth_service_test.dart

# Run integration tests
flutter test integration_test/

# Run Firebase Functions tests
cd functions && npm test

# Run tests in watch mode
flutter test --reporter=github
```

### Writing Tests

**1. Unit Test Example**
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Generate mocks
@GenerateMocks([FirebaseAuth, UserCredential])
import 'auth_service_test.mocks.dart';

void main() {
  group('AuthService', () {
    late AuthService authService;
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      authService = AuthService(mockAuth);
    });

    test('should sign in user successfully', () async {
      // Arrange
      final mockCredential = MockUserCredential();
      when(mockAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockCredential);

      // Act
      final result = await authService.signIn(
        'test@example.com',
        'password',
      );

      // Assert
      expect(result.isRight(), true);
      verify(mockAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password',
      )).called(1);
    });
  });
}
```

**2. Widget Test Example**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('LoginPage Widget Tests', () {
    testWidgets('should display login form', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: LoginPage(),
          ),
        ),
      );

      // Assert
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should show error when login fails', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(
              MockAuthService()..setupFailure(),
            ),
          ],
          child: MaterialApp(home: LoginPage()),
        ),
      );

      // Act
      await tester.enterText(find.byKey(Key('email')), 'test@example.com');
      await tester.enterText(find.byKey(Key('password')), 'wrong_password');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Invalid credentials'), findsOneWidget);
    });
  });
}
```

**3. Integration Test Example**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:football_stats/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow', () {
    testWidgets('complete sign-in flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to login
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Enter credentials
      await tester.enterText(
        find.byKey(Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(Key('password_field')),
        'password123',
      );

      // Submit form
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify navigation to dashboard
      expect(find.text('Dashboard'), findsOneWidget);
    });
  });
}
```

## 🔄 Development Workflow

### Git Workflow

**1. Branch Naming Convention**
```bash
# Feature branches
feature/user-authentication
feature/team-details-page
feature/push-notifications

# Bug fix branches  
bugfix/login-validation-error
bugfix/standings-table-sorting

# Hotfix branches
hotfix/critical-security-update

# Release branches
release/v1.1.0
```

**2. Commit Message Convention**

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```bash
# Format: <type>[optional scope]: <description>

# Examples
feat(auth): add Google Sign-In integration
fix(standings): resolve table sorting issue
docs(api): update endpoint documentation
style(ui): improve team card design
refactor(core): extract common utilities
test(auth): add unit tests for login flow
chore(deps): update Flutter to 3.19.0
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks, dependency updates

**3. Pull Request Process**

**Creating a Pull Request:**
```bash
# Ensure your branch is up to date
git checkout main
git pull origin main
git checkout feature/your-feature
git rebase main

# Push your branch
git push origin feature/your-feature

# Create PR via GitHub CLI
gh pr create \
  --title "Add user authentication system" \
  --body "Implements email/password and Google Sign-In authentication with Firebase Auth integration" \
  --assignee @me \
  --label "feature" \
  --milestone "v1.1.0"
```

**PR Template (.github/pull_request_template.md):**
```markdown
## Description
Brief description of changes made.

## Changes Made
- [ ] Feature 1
- [ ] Feature 2
- [ ] Bug fix

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Screenshots (if applicable)
Add screenshots here

## Breaking Changes
List any breaking changes

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests added/updated
```

### Development Environment

**1. Firebase Emulator Suite**
```bash
# Start all emulators
firebase emulators:start

# Start specific emulators
firebase emulators:start --only firestore,functions

# Import/export data
firebase emulators:export ./firebase-data
firebase emulators:start --import ./firebase-data
```

**2. Flutter Hot Reload Development**
```bash
# Run with hot reload
flutter run

# Run on specific device
flutter run -d chrome  # Web
flutter run -d <device_id>  # Specific device

# Run with different flavors
flutter run --flavor development -t lib/main_development.dart
```

**3. Debugging**

**Flutter DevTools:**
```bash
# Launch DevTools
flutter pub global run devtools

# Run app with debugging
flutter run --debug
```

**VS Code Debug Configuration (.vscode/launch.json):**
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter (Development)",
      "request": "launch",
      "type": "dart",
      "args": [
        "--flavor",
        "development",
        "--target",
        "lib/main_development.dart"
      ]
    },
    {
      "name": "Flutter (Production)",
      "request": "launch",
      "type": "dart",
      "args": [
        "--flavor",
        "production",
        "--target",
        "lib/main_production.dart"
      ]
    }
  ]
}
```

## 🏭 Build and Deployment

### Local Development Builds

**Flutter Development Builds:**
```bash
# Debug build for development
flutter build apk --debug --flavor development

# Profile build for performance testing
flutter build apk --profile --flavor development

# Release build for testing
flutter build apk --release --flavor staging
```

**Firebase Functions Development:**
```bash
# Build TypeScript
cd functions && npm run build

# Deploy to development environment
firebase use development
firebase deploy --only functions

# Test functions locally
firebase functions:shell
```

### CI/CD Pipeline

**GitHub Actions Workflow (.github/workflows/ci.yml):**
```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Generate code
        run: flutter packages pub run build_runner build --delete-conflicting-outputs
      
      - name: Run tests
        run: flutter test --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info

  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Analyze code
        run: flutter analyze
      
      - name: Check formatting
        run: dart format --output=none --set-exit-if-changed .

  deploy-staging:
    needs: [test, lint]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop'
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy to staging
        run: |
          # Deployment commands here
```

### Environment Management

**1. Environment-Specific Configurations**

**lib/core/config/env_config.dart:**
```dart
enum Environment {
  development,
  staging,
  production,
}

class EnvConfig {
  static const Environment _environment = Environment.development;
  
  static Environment get environment => _environment;
  
  static String get apiBaseUrl {
    switch (_environment) {
      case Environment.development:
        return 'http://localhost:5001/football-stats-dev/us-central1/api';
      case Environment.staging:
        return 'https://us-central1-football-stats-staging.cloudfunctions.net/api';
      case Environment.production:
        return 'https://us-central1-football-stats-prod.cloudfunctions.net/api';
    }
  }
  
  static String get firebaseProjectId {
    switch (_environment) {
      case Environment.development:
        return 'football-stats-dev';
      case Environment.staging:
        return 'football-stats-staging';
      case Environment.production:
        return 'football-stats-prod';
    }
  }
}
```

**2. Build Flavors**

**android/app/build.gradle:**
```gradle
android {
    flavorDimensions "default"
    productFlavors {
        development {
            dimension "default"
            applicationIdSuffix ".dev"
            versionNameSuffix "-dev"
            resValue "string", "app_name", "Football Stats Dev"
        }
        staging {
            dimension "default"
            applicationIdSuffix ".staging"
            versionNameSuffix "-staging"
            resValue "string", "app_name", "Football Stats Staging"
        }
        production {
            dimension "default"
            resValue "string", "app_name", "Football Stats"
        }
    }
}
```

## 📊 Monitoring and Analytics

### Development Monitoring

**1. Logging Standards**
```dart
// Use structured logging
import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
  ),
);

// Usage examples
logger.d('Debug message with context', {
  'userId': user.id,
  'action': 'login_attempt',
});

logger.e('Error occurred', error, stackTrace);
```

**2. Performance Monitoring**
```dart
// Firebase Performance Monitoring
import 'package:firebase_performance/firebase_performance.dart';

// Custom traces
final trace = FirebasePerformance.instance.newTrace('api_call_teams');
await trace.start();

try {
  final teams = await apiClient.getTeams();
  trace.putAttribute('teams_count', teams.length.toString());
  return teams;
} catch (error) {
  trace.putAttribute('error', error.toString());
  rethrow;
} finally {
  await trace.stop();
}

// HTTP request monitoring
final httpMetric = FirebasePerformance.instance
    .newHttpMetric('https://api.football.com/teams', HttpMethod.Get);

await httpMetric.start();
final response = await dio.get('https://api.football.com/teams');
httpMetric.responseContentType = response.headers['content-type'];
httpMetric.httpResponseCode = response.statusCode;
httpMetric.requestPayloadSize = request.data?.length ?? 0;
httpMetric.responsePayloadSize = response.data?.length ?? 0;
await httpMetric.stop();
```

### Error Tracking

**1. Crash Reporting**
```dart
// Firebase Crashlytics
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// Record errors
FirebaseCrashlytics.instance.recordError(
  error,
  stackTrace,
  reason: 'User authentication failed',
  information: [
    'User attempted to login with email: ${user.email}',
    'Authentication method: email_password',
  ],
  printDetails: true,
);

// Set user context
FirebaseCrashlytics.instance.setUserIdentifier(user.id);
FirebaseCrashlytics.instance.setCustomKey('user_role', user.role);

// Log events
FirebaseCrashlytics.instance.log('User navigated to team details');
```

**2. Custom Error Handling**
```dart
// Global error handler
class GlobalErrorHandler {
  static void handleError(Object error, StackTrace stackTrace) {
    // Log to console in debug mode
    if (kDebugMode) {
      debugPrint('Error: $error');
      debugPrint('Stack trace: $stackTrace');
    }
    
    // Report to Crashlytics in release mode
    if (kReleaseMode) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        fatal: false,
      );
    }
    
    // Send to analytics
    FirebaseAnalytics.instance.logEvent(
      name: 'error_occurred',
      parameters: {
        'error_type': error.runtimeType.toString(),
        'error_message': error.toString(),
      },
    );
  }
}

// Widget error boundary
class ErrorBoundary extends StatelessWidget {
  final Widget child;
  final Widget Function(Object error)? errorBuilder;
  
  const ErrorBoundary({
    Key? key,
    required this.child,
    this.errorBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return ref.watch(errorProvider).when(
          data: (_) => child,
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) {
            GlobalErrorHandler.handleError(error, stack);
            return errorBuilder?.call(error) ?? 
                   ErrorWidget('Something went wrong');
          },
        );
      },
    );
  }
}
```

## 🔒 Security Best Practices

### Code Security

**1. Input Validation**
```dart
// Validate all user inputs
class InputValidator {
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(password)) {
      return 'Password must contain uppercase, lowercase, and numbers';
    }
    
    return null;
  }
}
```

**2. Secure Storage**
```dart
// Use flutter_secure_storage for sensitive data
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: IOSAccessibility.first_unlock_this_device,
    ),
  );
  
  static Future<void> storeToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }
  
  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
  
  static Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }
}
```

**3. API Security**
```typescript
// Firebase Functions security
import { RateLimiterMemory } from 'rate-limiter-flexible';

const rateLimiter = new RateLimiterMemory({
  points: 10, // Number of requests
  duration: 60, // Per 60 seconds
});

export const secureApiHandler = functions.https.onRequest(async (req, res) => {
  try {
    // Rate limiting
    const clientIp = req.ip;
    await rateLimiter.consume(clientIp);
    
    // Authentication
    const idToken = req.headers.authorization?.split('Bearer ')[1];
    if (!idToken) {
      return res.status(401).json({ error: 'Unauthorized' });
    }
    
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    
    // Input validation
    const { error, value } = requestSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details });
    }
    
    // Process request
    const result = await processRequest(value, decodedToken);
    res.json(result);
    
  } catch (error) {
    if (error.remainingPoints !== undefined) {
      // Rate limit exceeded
      return res.status(429).json({ error: 'Too many requests' });
    }
    
    logger.error('API request failed', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});
```

### Data Protection

**1. Firestore Security Rules**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User data protection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Input validation
    match /teams/{teamId} {
      allow create: if request.auth != null 
                    && request.resource.data.name is string
                    && request.resource.data.name.size() > 0
                    && request.resource.data.name.size() <= 100;
    }
    
    // Rate limiting at database level
    match /rate_limits/{userId} {
      allow read, write: if false; // Only functions can access
    }
  }
}
```

## 📚 Documentation Standards

### Code Documentation

**1. Dart Documentation**
```dart
/// A service for managing user authentication with Firebase Auth.
/// 
/// This service provides methods for user sign-in, sign-out, and profile
/// management. It handles both email/password and social authentication.
/// 
/// Example usage:
/// ```dart
/// final authService = AuthService();
/// final result = await authService.signInWithEmail(
///   email: 'user@example.com',
///   password: 'password123',
/// );
/// 
/// result.fold(
///   (failure) => print('Sign-in failed: ${failure.message}'),
///   (user) => print('Welcome ${user.displayName}!'),
/// );
/// ```
class AuthService {
  /// Signs in a user with email and password.
  /// 
  /// Parameters:
  /// - [email]: The user's email address
  /// - [password]: The user's password
  /// 
  /// Returns a [Future<Either<AuthFailure, User>>] that completes with:
  /// - [Left(AuthFailure)]: If authentication fails
  /// - [Right(User)]: If authentication succeeds
  /// 
  /// Throws:
  /// - [NetworkException]: If network connectivity is unavailable
  /// - [ServerException]: If the authentication server is unavailable
  Future<Either<AuthFailure, User>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    // Implementation
  }
}
```

**2. TypeScript Documentation**
```typescript
/**
 * Authentication service for Firebase Cloud Functions
 * 
 * Provides middleware and utilities for authenticating requests,
 * managing user sessions, and enforcing authorization policies.
 * 
 * @example
 * ```typescript
 * // Authenticate a callable function
 * const userContext = await authService.authenticateCallable(context);
 * 
 * // Check user permissions
 * authService.requirePermission(userContext, Permission.MANAGE_TEAMS);
 * ```
 */
export class AuthService {
  /**
   * Authenticates a Firebase callable function context
   * 
   * @param context - The Firebase callable context
   * @returns Promise resolving to authenticated user context
   * @throws HttpsError with 'unauthenticated' code if token is invalid
   * @throws HttpsError with 'permission-denied' code if user lacks permissions
   */
  async authenticateCallable(
    context: functions.https.CallableContext
  ): Promise<UserContext> {
    // Implementation
  }
}
```

### API Documentation

**1. Endpoint Documentation Template**
```markdown
## POST /api/v1/teams

Creates a new team in the system.

### Authentication
- **Required**: Yes
- **Roles**: Moderator, Admin

### Request

**Headers:**
```http
Authorization: Bearer <firebase-id-token>
Content-Type: application/json
```

**Body:**
```json
{
  "name": "Manchester United",
  "country": "England",
  "league_id": "league-123",
  "founded": 1878,
  "logo": "https://example.com/logo.png"
}
```

### Response

**Success (201 Created):**
```json
{
  "data": {
    "id": "team-456",
    "name": "Manchester United",
    "country": "England",
    "league_id": "league-123",
    "founded": 1878,
    "logo": "https://example.com/logo.png",
    "created_at": "2025-01-31T10:00:00Z"
  }
}
```

**Error (400 Bad Request):**
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": {
      "name": "Team name is required",
      "country": "Invalid country code"
    }
  }
}
```

### Rate Limiting
- **Limit**: 10 requests per minute
- **Scope**: Per authenticated user

### Examples

**cURL:**
```bash
curl -X POST \
  https://api.footballstats.com/v1/teams \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Manchester United",
    "country": "England",
    "league_id": "league-123"
  }'
```

**JavaScript:**
```javascript
const response = await fetch('/api/v1/teams', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    name: 'Manchester United',
    country: 'England',
    league_id: 'league-123',
  }),
});
```
```

## 🤝 Contributing Guidelines

### Getting Started

**1. First-Time Contributors**
1. Fork the repository
2. Clone your fork locally
3. Set up the development environment
4. Create a new branch for your feature
5. Make your changes
6. Write tests for your changes
7. Ensure all tests pass
8. Submit a pull request

**2. Contribution Types**
- **Bug Fixes**: Address existing issues
- **New Features**: Add new functionality
- **Documentation**: Improve or add documentation
- **Performance**: Optimize existing code
- **Refactoring**: Improve code structure without changing behavior

### Pull Request Guidelines

**1. PR Requirements**
- [ ] Clear description of changes
- [ ] Tests added or updated
- [ ] Documentation updated
- [ ] Code follows style guidelines
- [ ] All CI checks pass
- [ ] Self-review completed

**2. Review Process**
1. **Automated Checks**: CI pipeline must pass
2. **Code Review**: At least one reviewer approval required
3. **Manual Testing**: Feature tested in development environment
4. **Final Review**: Lead developer final approval for main branch

### Issue Guidelines

**1. Bug Reports**
Use the bug report template and include:
- Clear description of the bug
- Steps to reproduce
- Expected vs actual behavior
- Environment information (device, OS, app version)
- Screenshots or logs if applicable

**2. Feature Requests**
Use the feature request template and include:
- Clear description of the proposed feature
- Use case and business justification
- Acceptance criteria
- Mockups or wireframes if applicable

### Code Review Guidelines

**1. As a Reviewer**
- Be constructive and helpful
- Focus on code quality, not personal preferences
- Suggest improvements with explanations
- Approve when code meets standards
- Request changes when necessary

**2. As an Author**
- Respond to all feedback
- Make requested changes promptly
- Ask for clarification if needed
- Update tests and documentation as required

### Community Guidelines

**1. Code of Conduct**
- Be respectful and inclusive
- Help create a welcoming environment
- Focus on what's best for the community
- Show empathy towards others

**2. Communication**
- Use clear, concise language
- Provide context for your contributions
- Ask questions when uncertain
- Share knowledge and learnings

## 📞 Getting Help

### Development Support

**1. Documentation Resources**
- [API Documentation](API.md)
- [Architecture Guide](ARCHITECTURE.md)
- [Deployment Guide](DEPLOYMENT.md)
- [Troubleshooting Guide](TROUBLESHOOTING.md)

**2. Community Support**
- **Discord**: [Developer Channel](https://discord.gg/footballstats-dev)
- **GitHub Discussions**: Technical questions and feature discussions
- **Stack Overflow**: Tag questions with `football-stats-app`

**3. Direct Support**
- **Email**: dev@footballstats.com
- **Internal Chat**: #football-stats-dev Slack channel
- **Office Hours**: Tuesdays 3-4 PM UTC (Lead Developer available)

### Useful Resources

**Flutter Development:**
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Riverpod Documentation](https://riverpod.dev/)

**Firebase Development:**
- [Firebase Documentation](https://firebase.google.com/docs)
- [Cloud Functions Guide](https://firebase.google.com/docs/functions)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)

**TypeScript Development:**
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Node.js Documentation](https://nodejs.org/en/docs/)

---

## 🎯 Next Steps

Now that you've completed the developer setup:

1. **Start with a small contribution** - Fix a bug or improve documentation
2. **Join the community** - Participate in discussions and code reviews
3. **Learn the codebase** - Explore different features and understand the architecture
4. **Share your expertise** - Help other developers and contribute your skills

Welcome to the Football Stats development team! We're excited to have you contribute to building the best football statistics application.

---

**Developer Guide Version**: 1.0.0  
**Last Updated**: January 31, 2025  
**Maintainer**: Football Stats Development Team

For questions about this guide, please create an issue or contact the development team.