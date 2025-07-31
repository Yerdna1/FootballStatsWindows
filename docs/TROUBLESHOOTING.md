# Football Stats - Troubleshooting Guide

This comprehensive troubleshooting guide helps resolve common issues encountered in the Football Stats application, covering both user-facing problems and development challenges.

## 🚨 Quick Solutions

### Most Common Issues

| Issue | Quick Fix | Full Solution |
|-------|-----------|---------------|
| App won't start | Restart app and device | [App Launch Issues](#app-launch-issues) |
| Login fails | Check internet, verify credentials | [Authentication Issues](#authentication-issues) |
| Data not loading | Pull to refresh, check connection | [Data Loading Issues](#data-loading-issues) |
| Notifications not working | Check app permissions | [Notification Issues](#notification-issues) |
| Slow performance | Close other apps, restart device | [Performance Issues](#performance-issues) |

## 📱 User Issues

### App Launch Issues

**Problem**: App crashes on startup or shows blank screen

**Symptoms:**
- App closes immediately after opening
- White/black screen appears and stays
- Loading spinner never disappears
- "App not responding" dialog

**Solutions:**

**Step 1: Basic Troubleshooting**
```bash
1. Force close the app completely
2. Restart the app
3. If still failing, restart your device
4. Check for app updates in store
```

**Step 2: Clear App Cache (Android)**
```bash
1. Go to Settings → Apps → Football Stats
2. Tap "Storage"
3. Tap "Clear Cache" (not Clear Data)
4. Restart the app
```

**Step 3: Check Device Compatibility**
- **iOS**: Requires iOS 12.0 or later
- **Android**: Requires Android 6.0 (API level 23) or later
- **RAM**: At least 2GB recommended
- **Storage**: 500MB free space needed

**Step 4: Reinstall Application**
```bash
1. Uninstall the app completely
2. Restart your device
3. Reinstall from app store
4. Sign in with your existing account
```

**Advanced Solutions:**
```bash
# Check system logs (Android - requires developer options)
adb logcat | grep "com.footballstats.app"

# Check crash reports in Firebase Console (for developers)
# Navigate to Crashlytics in Firebase Console
```

### Authentication Issues

**Problem**: Cannot sign in or authentication fails

**Common Error Messages:**
- "Invalid email or password"
- "Network error occurred"
- "Account not found"
- "Too many failed attempts"

**Solutions by Error Type:**

**Invalid Credentials:**
```bash
1. Double-check email address for typos
2. Verify password (check caps lock)
3. Try copying and pasting credentials
4. Use "Forgot Password" if uncertain
```

**Network-Related Issues:**
```bash
1. Check internet connection (try opening a webpage)
2. Switch between WiFi and mobile data
3. Disable VPN if active
4. Try again in a few minutes
```

**Account Issues:**
```bash
1. Verify email verification (check spam folder)
2. Try social login (Google) if available
3. Contact support if account was disabled
4. Create new account if previous was deleted
```

**Rate Limiting (Too Many Attempts):**
```bash
1. Wait 15 minutes before trying again
2. Ensure you're using correct credentials
3. Use password reset instead of guessing
4. Contact support if lockout persists
```

**Two-Factor Authentication Issues:**
```bash
1. Check device time is correct
2. Ensure authenticator app is synchronized
3. Try backup codes if available
4. Contact support for 2FA reset
```

### Data Loading Issues

**Problem**: Content doesn't load or shows old data

**Symptoms:**
- Empty lists or "No data available"
- Loading spinners that never complete
- Outdated scores or standings
- Images not displaying

**Diagnostic Steps:**
```bash
1. Check internet connection strength
2. Try pulling down to refresh manually
3. Check if issue affects all content or specific sections
4. Test on different network (WiFi vs mobile)
```

**Solutions by Content Type:**

**Team/League Data:**
```bash
1. Pull down to refresh the list
2. Clear app cache (Android: Settings → Apps → Storage → Clear Cache)
3. Check if data exists by searching
4. Try viewing in web browser to confirm API status
```

**Live Scores:**
```bash
1. Verify matches are actually live
2. Check timezone settings on device
3. Refresh the fixtures page
4. Confirm league is supported for live updates
```

**Images Not Loading:**
```bash
1. Check internet connection stability
2. Try switching networks
3. Clear image cache: Settings → Data & Storage → Clear Image Cache
4. Restart app to reload images
```

**Offline Data Issues:**
```bash
1. Ensure you've browsed content while online
2. Check storage permissions
3. Verify offline storage isn't full
4. Re-sync data while online
```

### Notification Issues

**Problem**: Not receiving notifications or getting too many

**Types of Notification Issues:**

**No Notifications Received:**
```bash
# Check App Permissions
Android:
1. Settings → Apps → Football Stats → Permissions
2. Enable "Notifications"
3. Check "Battery Optimization" settings

iOS:
1. Settings → Notifications → Football Stats
2. Enable "Allow Notifications"
3. Choose notification style and sounds
```

```bash
# Check App Settings
1. Open Football Stats → Settings → Notifications
2. Verify desired notifications are enabled
3. Check quiet hours settings
4. Confirm favorites are set up correctly
```

```bash
# Device-Level Issues
1. Check Do Not Disturb is disabled
2. Verify notification channels aren't blocked
3. Check Focus/Sleep modes (iOS)
4. Restart notification services
```

**Too Many Notifications:**
```bash
1. Go to Settings → Notifications
2. Disable unwanted categories:
   - Match starts (if too frequent)
   - Goal alerts (for all teams)
   - League updates (for followed leagues only)
3. Set up quiet hours
4. Reduce favorite teams if overwhelming
```

**Delayed Notifications:**
```bash
1. Check power saving mode isn't aggressive
2. Disable battery optimization for Football Stats
3. Ensure background app refresh is enabled
4. Check if notifications work on WiFi vs mobile data
```

### Performance Issues

**Problem**: App is slow, freezes, or crashes frequently

**Symptoms:**
- Slow navigation between screens
- UI lag when scrolling
- App freezes for several seconds
- Random crashes during use

**Immediate Solutions:**
```bash
1. Close all other apps running in background
2. Restart the Football Stats app
3. Restart your device
4. Check available storage (need 1GB+ free)
```

**Memory-Related Issues:**
```bash
# Android Memory Management
1. Settings → Device Care → Memory
2. Clean up running apps
3. Clear system cache
4. Remove unused apps

# iOS Memory Management
1. Double-tap home button and swipe up on apps
2. Restart device by holding power + volume
3. Check storage: Settings → General → iPhone Storage
```

**Network Performance:**
```bash
1. Test on different networks (WiFi vs cellular)
2. Move closer to WiFi router
3. Disable other devices using bandwidth
4. Contact ISP if consistently slow
```

**App-Specific Optimizations:**
```bash
1. Reduce favorites to only essential teams/leagues
2. Disable live updates if not needed
3. Use low data mode in app settings
4. Clear app cache regularly
```

### Settings and Preferences Issues

**Problem**: Settings not saving or not working as expected

**Common Issues:**

**Theme Not Changing:**
```bash
1. Force close app completely
2. Reopen app
3. Check system theme settings (if using "System" theme)
4. Try switching to specific theme (Light/Dark)
5. Update app if theme issues persist
```

**Language Not Switching:**
```bash
1. Ensure desired language is downloaded
2. Restart app after language change
3. Check device system language
4. Clear app cache if mixed languages appear
```

**Notification Settings Resetting:**
```bash
1. Check if signed in to same account
2. Verify cloud sync is enabled
3. Don't switch accounts while changing settings
4. Wait a few seconds after changing settings before closing
```

## 🔧 Development Issues

### Environment Setup Problems

**Problem**: Cannot set up development environment

**Flutter Installation Issues:**
```bash
# Flutter Doctor Issues
flutter doctor

# Common fixes:
# 1. Android SDK path
export ANDROID_HOME=/path/to/android/sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

# 2. iOS development (macOS only)
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch

# 3. Flutter channel issues
flutter channel stable
flutter upgrade
```

**Firebase Setup Issues:**
```bash
# Firebase CLI login issues
firebase logout
firebase login --reauth

# Project selection issues
firebase use --add
firebase list

# Permission issues
firebase projects:list
# Ensure you have access to the project
```

**Node.js/npm Issues:**
```bash
# Version conflicts
nvm install 18
nvm use 18

# Permission issues (macOS/Linux)
sudo chown -R $(whoami) ~/.npm

# Package installation issues
rm -rf node_modules package-lock.json
npm install
```

### Build Issues

**Problem**: Build fails or generates errors

**Flutter Build Issues:**

**Code Generation Issues:**
```bash
# Clean and regenerate
flutter packages pub run build_runner clean
flutter packages pub run build_runner build --delete-conflicting-outputs

# If still failing:
flutter clean
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
```

**Dependency Conflicts:**
```bash
# Check for version conflicts
flutter pub deps
flutter pub upgrade

# Resolve conflicts manually in pubspec.yaml
# Use dependency_overrides if necessary
dependency_overrides:
  package_name: ^version
```

**Platform-Specific Build Issues:**

**Android Build Problems:**
```bash
# Gradle issues
cd android
./gradlew clean
cd ..
flutter clean
flutter build apk

# SDK version issues
# Update android/app/build.gradle:
compileSdkVersion 34
targetSdkVersion 34
minSdkVersion 23
```

**iOS Build Problems:**
```bash
# Pod installation issues
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..

# Xcode issues
flutter clean
flutter build ios
# Open ios/Runner.xcworkspace in Xcode
# Check signing and capabilities
```

**Firebase Functions Build Issues:**
```bash
# TypeScript compilation errors
cd functions
npm run build

# Dependency issues
rm -rf node_modules package-lock.json
npm install

# Runtime issues
firebase emulators:start --only functions
# Check function logs for errors
```

### Testing Issues

**Problem**: Tests fail or cannot run tests

**Unit Test Issues:**
```bash
# Test dependencies
flutter packages pub run build_runner build --delete-conflicting-outputs

# Run specific test
flutter test test/features/auth/auth_service_test.dart

# Mock generation issues
flutter packages pub run build_runner build --delete-conflicting-outputs
```

**Integration Test Issues:**
```bash
# Device connection
flutter devices

# Run on specific device
flutter test integration_test/ -d <device_id>

# Firebase emulator for tests
firebase emulators:start --only auth,firestore
flutter test integration_test/
```

**Widget Test Issues:**
```bash
# Pump and settle issues
await tester.pumpAndSettle();

# Provider override issues
testWidgets('test description', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        // Override providers for testing
      ],
      child: MaterialApp(home: TestWidget()),
    ),
  );
});
```

### Firebase Issues

**Problem**: Firebase services not working properly

**Authentication Issues:**
```bash
# Check Firebase project configuration
firebase projects:list
firebase use <project-id>

# Verify API keys
# Check google-services.json (Android)
# Check GoogleService-Info.plist (iOS)

# Debug authentication
firebase auth:export users.json --project <project-id>
```

**Firestore Issues:**
```bash
# Security rules testing
firebase firestore:rules:test --project <project-id>

# Index issues
firebase firestore:indexes --project <project-id>

# Connection issues
// Enable offline persistence
FirebaseFirestore.instance.enablePersistence();
```

**Cloud Functions Issues:**
```bash
# Deploy issues
firebase deploy --only functions --project <project-id>

# Runtime errors
firebase functions:log --project <project-id>

# Local testing
firebase emulators:start --only functions
# Test endpoints with curl or Postman
```

### API Integration Issues

**Problem**: External API calls failing

**Football API Issues:**
```bash
# Check API key validity
curl -H "X-RapidAPI-Key: YOUR_KEY" \
     "https://v3.football.api-sports.io/status"

# Rate limiting
# Check API quota and usage
# Implement exponential backoff

# Data transformation issues
# Log raw API responses
console.log('API Response:', JSON.stringify(response.data));
```

**HTTP Client Issues:**
```dart
// Dio configuration issues
final dio = Dio();
dio.interceptors.add(LogInterceptor(
  requestBody: true,
  responseBody: true,
));

// Timeout configuration
dio.options.connectTimeout = Duration(seconds: 10);
dio.options.receiveTimeout = Duration(seconds: 10);
```

## 🔍 Debugging Techniques

### Flutter Debugging

**Debug Tools:**
```bash
# Flutter DevTools
flutter pub global activate devtools
flutter pub global run devtools

# Run app with debugging
flutter run --debug

# Hot reload during development
# Press 'r' in terminal or use IDE hot reload
```

**Logging and Inspection:**
```dart
// Debug prints
debugPrint('Debug message: $variable');

// Logger package
import 'package:logger/logger.dart';
final logger = Logger();
logger.d('Debug message');
logger.e('Error message', error, stackTrace);

// Widget inspection
debugDumpApp(); // Prints widget tree
debugDumpRenderTree(); // Prints render tree
```

**Performance Debugging:**
```dart
// Performance overlay
MaterialApp(
  debugShowCheckedModeBanner: false,
  showPerformanceOverlay: true, // Shows FPS
  child: MyApp(),
);

// Memory debugging
import 'package:flutter/services.dart';
SystemChannels.lifecycle.setMessageHandler((message) {
  debugPrint('Lifecycle: $message');
  return Future.value();
});
```

### Firebase Debugging

**Emulator Debugging:**
```bash
# Start with debugging
firebase emulators:start --inspect-functions

# View emulator UI
# http://localhost:4000

# Function debugging (Node.js)
# Use Chrome DevTools
# chrome://inspect
```

**Production Debugging:**
```bash
# View function logs
firebase functions:log --only functionName

# Real-time logs
firebase functions:log --follow

# Error tracking
# Check Firebase Console → Crashlytics
```

### Network Debugging

**HTTP Request Debugging:**
```dart
// Dio logging interceptor
dio.interceptors.add(LogInterceptor(
  request: true,
  requestHeader: true,
  requestBody: true,
  responseHeader: true,
  responseBody: true,
  error: true,
));

// Custom interceptor for debugging
class DebugInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('REQUEST[${options.method}] => PATH: ${options.path}');
    debugPrint('Headers: ${options.headers}');
    debugPrint('Data: ${options.data}');
    super.onRequest(options, handler);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    debugPrint('Data: ${response.data}');
    super.onResponse(response, handler);
  }
}
```

**Charles Proxy/Packet Capture:**
```bash
# Configure proxy for mobile testing
# iOS: Settings → WiFi → HTTP Proxy
# Android: WiFi Settings → Advanced → Proxy

# Common proxy settings:
# Host: 192.168.1.xxx (your computer IP)
# Port: 8888 (Charles default)
```

## 📊 Performance Optimization

### Flutter Performance

**Common Performance Issues:**

**Slow List Rendering:**
```dart
// Use ListView.builder instead of ListView
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
);

// Use const constructors
const ItemWidget({Key? key, required this.item}) : super(key: key);

// Implement AutomaticKeepAliveClientMixin for tab views
class MyTabView extends StatefulWidget {
  @override
  _MyTabViewState createState() => _MyTabViewState();
}

class _MyTabViewState extends State<MyTabView> 
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  
  @override
  Widget build(BuildContext context) {
    super.build(context); // Must call super.build
    return YourWidget();
  }
}
```

**Memory Leaks:**
```dart
// Dispose controllers and subscriptions
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late StreamSubscription subscription;
  late AnimationController controller;
  
  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this);
    subscription = stream.listen((data) {
      // Handle data
    });
  }
  
  @override
  void dispose() {
    controller.dispose();
    subscription.cancel();
    super.dispose();
  }
}
```

**Unnecessary Rebuilds:**
```dart
// Use Consumer instead of ref.watch in build method
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Only rebuild this part when data changes
        Consumer(
          builder: (context, ref, _) {
            final data = ref.watch(dataProvider);
            return Text(data.toString());
          },
        ),
        // This part won't rebuild unnecessarily
        const StaticWidget(),
      ],
    );
  }
}
```

### Backend Performance

**Cloud Functions Optimization:**
```typescript
// Connection pooling
import { Pool } from 'generic-pool';

const pool = new Pool({
  create: () => createDatabaseConnection(),
  destroy: (connection) => connection.close(),
  max: 10,
  min: 2,
});

// Use connection from pool
export const optimizedFunction = functions.https.onRequest(async (req, res) => {
  const connection = await pool.acquire();
  try {
    const result = await queryDatabase(connection, req.body);
    res.json(result);
  } finally {
    await pool.release(connection);
  }
});

// Cache frequently accessed data
const cache = new Map();
export const cachedFunction = functions.https.onCall(async (data) => {
  const cacheKey = JSON.stringify(data);
  
  if (cache.has(cacheKey)) {
    return cache.get(cacheKey);
  }
  
  const result = await expensiveOperation(data);
  cache.set(cacheKey, result);
  
  // Set TTL
  setTimeout(() => cache.delete(cacheKey), 300000); // 5 minutes
  
  return result;
});
```

**Firestore Optimization:**
```dart
// Use pagination for large datasets
Query query = FirebaseFirestore.instance
    .collection('teams')
    .orderBy('name')
    .limit(20);

// Implement proper indexing
// Create composite indexes for complex queries
// Example query requiring index:
FirebaseFirestore.instance
    .collection('fixtures')
    .where('league_id', isEqualTo: leagueId)
    .where('season', isEqualTo: season)
    .orderBy('date')
    .limit(50);

// Use offline persistence
FirebaseFirestore.instance.enablePersistence();
```

## 🔒 Security Troubleshooting

### Authentication Security

**Token Issues:**
```dart
// Check token expiration
final user = FirebaseAuth.instance.currentUser;
if (user != null) {
  final idTokenResult = await user.getIdTokenResult();
  final expirationTime = idTokenResult.expirationTime;
  
  if (expirationTime != null && 
      DateTime.now().isAfter(expirationTime)) {
    // Token expired, refresh it
    await user.getIdToken(true);
  }
}
```

**Firestore Security Rules Issues:**
```javascript
// Debug security rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Add logging for debugging
    match /users/{userId} {
      allow read, write: if request.auth != null && 
                            request.auth.uid == userId &&
                            debug(request.auth.uid); // Debug function
    }
  }
}
```

### Data Validation Issues

**Input Sanitization:**
```dart
// Validate user inputs
class InputValidator {
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) return 'Email required';
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) return 'Invalid email format';
    
    return null;
  }
  
  static String sanitizeInput(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll(RegExp(r'[^\w\s@.-]'), ''); // Keep only safe characters
  }
}
```

## 📞 Getting Additional Help

### When to Contact Support

**User Support Scenarios:**
- Account recovery issues
- Billing/subscription problems
- Data loss or corruption
- Persistent app crashes
- Feature requests

**Developer Support Scenarios:**
- API integration problems
- Build/deployment issues
- Performance optimization needs
- Architecture guidance
- Security concerns

### Support Channels

**User Support:**
- **Email**: support@footballstats.com
- **In-App Chat**: Available 9 AM - 5 PM UTC
- **FAQ**: Built into app settings
- **Community Forum**: [community.footballstats.com]

**Developer Support:**
- **Email**: dev@footballstats.com
- **GitHub Issues**: Technical bugs and features
- **Discord**: #football-stats-dev channel
- **Stack Overflow**: Tag with `football-stats-app`

### Information to Include in Support Requests

**For User Issues:**
```
1. Device information (iOS/Android version)
2. App version (found in Settings → About)
3. Account email (for account-related issues)
4. Steps to reproduce the issue
5. Screenshots or screen recordings
6. Error messages (exact text)
7. When the issue started occurring
```

**For Developer Issues:**
```
1. Development environment details
2. Flutter/Node.js versions
3. Code samples (minimal reproducible example)
4. Error logs and stack traces
5. Configuration files (sanitized)
6. Steps taken to debug
7. Expected vs actual behavior
```

### Emergency Contacts

**Critical Production Issues:**
- **Phone**: +1-XXX-XXX-XXXX (24/7 for production outages)
- **Email**: emergency@footballstats.com
- **Slack**: #incidents channel (internal team)

**Security Issues:**
- **Email**: security@footballstats.com
- **Encrypted**: Use PGP key from website
- **Response Time**: Within 4 hours for critical issues

---

## 📚 Additional Resources

### Documentation
- [API Documentation](API.md) - Complete API reference
- [Architecture Guide](ARCHITECTURE.md) - Technical architecture details
- [Developer Guide](DEVELOPER_GUIDE.md) - Development setup and guidelines
- [Deployment Guide](DEPLOYMENT.md) - Production deployment instructions

### External Resources
- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Dart Language Guide](https://dart.dev/guides)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)

### Community
- [GitHub Repository](https://github.com/your-org/football_stats)
- [Discord Server](https://discord.gg/footballstats)
- [Reddit Community](https://reddit.com/r/footballstats)
- [Twitter Updates](https://twitter.com/footballstatsapp)

---

**Troubleshooting Guide Version**: 1.0.0  
**Last Updated**: January 31, 2025  
**Next Review**: April 30, 2025

This guide is continuously updated based on user feedback and common issues. If you encounter a problem not covered here, please let us know so we can improve this resource for everyone.