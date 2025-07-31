# Football Stats Deployment Guide

This comprehensive guide covers all aspects of deploying the Football Stats application to production, including Firebase backend, Flutter frontend, and CI/CD pipeline setup.

## 🎯 Overview

The Football Stats application consists of:
- **Flutter Frontend**: Cross-platform mobile app (iOS, Android, Web)
- **Firebase Backend**: Cloud Functions, Firestore, Authentication, Storage
- **External APIs**: Football data integration
- **CI/CD Pipeline**: Automated testing and deployment

## 📋 Prerequisites

### Required Software
- **Node.js** (v18 or higher)
- **Flutter SDK** (v3.19.0 or higher)
- **Firebase CLI** (latest version)
- **Git** for version control
- **Docker** (optional, for containerized deployments)

### Required Accounts
- **Firebase Console** account
- **Google Cloud Platform** account (with billing enabled)
- **Football API** account (api-sports.io)
- **GitHub** account (for CI/CD)
- **Apple Developer** account (for iOS deployment)
- **Google Play Console** account (for Android deployment)

### Installation Commands
```bash
# Install Node.js (via nvm)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 18
nvm use 18

# Install Flutter
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Install Firebase CLI
npm install -g firebase-tools

# Verify installations
node --version        # Should show v18.x.x
flutter --version     # Should show 3.19.0+
firebase --version    # Should show latest
```

## 🔥 Firebase Project Setup

### 1. Create Firebase Projects

Create separate projects for each environment:

```bash
# Login to Firebase
firebase login

# Create projects (via Firebase Console or CLI)
# - football-stats-dev (Development)
# - football-stats-staging (Staging)  
# - football-stats-prod (Production)
```

### 2. Enable Required Services

For each Firebase project, enable:

**Authentication**
```bash
# Enable Authentication providers
# - Email/Password
# - Google Sign-In
# - (Optional) Facebook, Twitter, etc.
```

**Firestore Database**
```bash
# Create Firestore database in production mode
# Choose region (us-central1 recommended)
```

**Cloud Functions**
```bash
# Enable Cloud Functions
# Upgrade to Blaze plan (pay-as-you-go)
```

**Cloud Storage**
```bash
# Enable Cloud Storage
# Create default bucket
```

**Cloud Messaging**
```bash
# Enable FCM for push notifications
# Generate server key
```

### 3. Configure Service Accounts

Create service accounts for external API access:

```bash
# Create service account
gcloud iam service-accounts create football-stats-api \
    --display-name="Football Stats API Service Account"

# Download service account key
gcloud iam service-accounts keys create ./service-account-key.json \
    --iam-account=football-stats-api@your-project-id.iam.gserviceaccount.com

# Grant necessary permissions
gcloud projects add-iam-policy-binding your-project-id \
    --member="serviceAccount:football-stats-api@your-project-id.iam.gserviceaccount.com" \
    --role="roles/datastore.user"
```

## 🚀 Backend Deployment

### 1. Environment Configuration

Create environment files for each environment:

**functions/.env.development**
```env
# Development Environment
NODE_ENV=development
FOOTBALL_API_KEY=your-dev-api-key
FOOTBALL_API_BASE_URL=https://v3.football.api-sports.io
FIREBASE_PROJECT_ID=football-stats-dev
CACHE_ENABLED=true
RATE_LIMIT_ENABLED=false
FCM_ENABLED=false
LOG_LEVEL=debug
```

**functions/.env.staging**
```env
# Staging Environment
NODE_ENV=staging
FOOTBALL_API_KEY=your-staging-api-key
FOOTBALL_API_BASE_URL=https://v3.football.api-sports.io
FIREBASE_PROJECT_ID=football-stats-staging
CACHE_ENABLED=true
RATE_LIMIT_ENABLED=true
FCM_ENABLED=true
LOG_LEVEL=info
```

**functions/.env.production**
```env
# Production Environment
NODE_ENV=production
FOOTBALL_API_KEY=your-production-api-key
FOOTBALL_API_BASE_URL=https://v3.football.api-sports.io
FIREBASE_PROJECT_ID=football-stats-prod
CACHE_ENABLED=true
RATE_LIMIT_ENABLED=true
FCM_ENABLED=true
LOG_LEVEL=warn
SENTRY_DSN=your-sentry-dsn
```

### 2. Deploy Cloud Functions

```bash
# Navigate to functions directory
cd functions

# Install dependencies
npm install

# Build TypeScript
npm run build

# Deploy to development
firebase use football-stats-dev
firebase deploy --only functions

# Deploy to staging
firebase use football-stats-staging
firebase deploy --only functions

# Deploy to production
firebase use football-stats-prod
firebase deploy --only functions
```

### 3. Deploy Firestore Rules and Indexes

```bash
# Deploy security rules
firebase deploy --only firestore:rules

# Deploy indexes
firebase deploy --only firestore:indexes

# Deploy storage rules
firebase deploy --only storage
```

### 4. Set Function Configuration

```bash
# Set environment variables for Cloud Functions
firebase functions:config:set \
  football.api_key="your-api-key" \
  football.base_url="https://v3.football.api-sports.io"

# Set multiple environment variables
firebase functions:config:set \
  app.environment="production" \
  features.cache_enabled="true" \
  features.rate_limit_enabled="true"

# Deploy with new config
firebase deploy --only functions
```

### 5. Initialize Database

Run initial data setup:

```bash
# Create admin user (run once)
node scripts/create-admin-user.js

# Import initial data
node scripts/import-leagues.js
node scripts/import-teams.js

# Set up demo data (development only)
node scripts/setup-demo-data.js
```

## 📱 Frontend Deployment

### 1. Flutter Configuration

Configure Firebase for Flutter:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase projects
flutterfire configure --project=football-stats-dev
flutterfire configure --project=football-stats-staging  
flutterfire configure --project=football-stats-prod
```

This creates environment-specific configuration files:
- `lib/firebase_options_dev.dart`
- `lib/firebase_options_staging.dart`
- `lib/firebase_options_prod.dart`

### 2. Environment-Specific Builds

**Development Build**
```bash
flutter build apk --debug --dart-define=ENVIRONMENT=development
flutter build ios --debug --dart-define=ENVIRONMENT=development
```

**Staging Build**
```bash
flutter build apk --release --dart-define=ENVIRONMENT=staging
flutter build ios --release --dart-define=ENVIRONMENT=staging
```

**Production Build**
```bash
flutter build apk --release --dart-define=ENVIRONMENT=production
flutter build ios --release --dart-define=ENVIRONMENT=production
flutter build web --release --dart-define=ENVIRONMENT=production
```

### 3. Android Deployment

**Setup Signing**

Create `android/key.properties`:
```properties
storePassword=your-store-password
keyPassword=your-key-password
keyAlias=your-key-alias
storeFile=path/to/your/keystore.jks
```

Update `android/app/build.gradle`:
```gradle
android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            useProguard true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

**Build and Deploy**
```bash
# Build release APK
flutter build apk --release --dart-define=ENVIRONMENT=production

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release --dart-define=ENVIRONMENT=production

# Upload to Google Play Console
# Use Google Play Console web interface or fastlane
```

### 4. iOS Deployment

**Setup Signing**

1. Open `ios/Runner.xcworkspace` in Xcode
2. Configure signing certificates and provisioning profiles
3. Set bundle identifier and version
4. Configure app capabilities (Push Notifications, etc.)

**Build and Deploy**
```bash
# Build iOS release
flutter build ios --release --dart-define=ENVIRONMENT=production

# Archive and upload via Xcode
# Or use fastlane for automation
```

**Fastlane Setup (Optional)**
```ruby
# ios/fastlane/Fastfile
default_platform(:ios)

platform :ios do
  desc "Push a new release build to the App Store"
  lane :release do
    build_app(scheme: "Runner")
    upload_to_app_store
  end
end
```

### 5. Web Deployment

**Firebase Hosting**
```bash
# Build web version
flutter build web --release --dart-define=ENVIRONMENT=production

# Copy build to Firebase hosting public directory
cp -r build/web/* public/

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

**Custom Domain Setup**
```bash
# Add custom domain in Firebase Console
# Configure DNS records:
# A record: @ -> 151.101.1.195, 151.101.65.195
# CNAME record: www -> your-project-id.web.app
```

## 🔄 CI/CD Pipeline Setup

### 1. GitHub Actions Configuration

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy Football Stats

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  FLUTTER_VERSION: '3.19.0'
  NODE_VERSION: '18'

jobs:
  test:
    name: Run Tests
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
      
      - name: Flutter Dependencies
        run: flutter pub get
      
      - name: Flutter Code Generation
        run: flutter packages pub run build_runner build --delete-conflicting-outputs
      
      - name: Flutter Tests
        run: flutter test
      
      - name: Flutter Analyze
        run: flutter analyze
      
      - name: Functions Dependencies
        run: cd functions && npm ci
      
      - name: Functions Tests
        run: cd functions && npm test
      
      - name: Functions Lint
        run: cd functions && npm run lint
      
      - name: Functions Build
        run: cd functions && npm run build

  deploy-staging:
    name: Deploy to Staging
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop' && github.event_name == 'push'
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
      
      - name: Install Firebase CLI
        run: npm install -g firebase-tools
      
      - name: Flutter Dependencies
        run: flutter pub get
      
      - name: Flutter Code Generation
        run: flutter packages pub run build_runner build --delete-conflicting-outputs
      
      - name: Build Flutter Web
        run: flutter build web --release --dart-define=ENVIRONMENT=staging
      
      - name: Functions Dependencies
        run: cd functions && npm ci
      
      - name: Functions Build
        run: cd functions && npm run build
      
      - name: Deploy to Firebase Staging
        run: |
          firebase use football-stats-staging --token ${{ secrets.FIREBASE_TOKEN }}
          firebase deploy --token ${{ secrets.FIREBASE_TOKEN }}
        env:
          FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}

  deploy-production:
    name: Deploy to Production
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
      
      - name: Install Firebase CLI
        run: npm install -g firebase-tools
      
      - name: Flutter Dependencies
        run: flutter pub get
      
      - name: Flutter Code Generation
        run: flutter packages pub run build_runner build --delete-conflicting-outputs
      
      - name: Build Flutter Web
        run: flutter build web --release --dart-define=ENVIRONMENT=production
      
      - name: Functions Dependencies
        run: cd functions && npm ci
      
      - name: Functions Build
        run: cd functions && npm run build
      
      - name: Deploy to Firebase Production
        run: |
          firebase use football-stats-prod --token ${{ secrets.FIREBASE_TOKEN }}
          firebase deploy --token ${{ secrets.FIREBASE_TOKEN }}
        env:
          FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
      
      - name: Build Android Release
        run: flutter build appbundle --release --dart-define=ENVIRONMENT=production
      
      - name: Upload to Google Play
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.GOOGLE_PLAY_SERVICE_ACCOUNT }}
          packageName: com.footballstats.app
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: production
```

### 2. GitHub Secrets Configuration

Add the following secrets to your GitHub repository:

```bash
# Firebase deployment token
FIREBASE_TOKEN=your-firebase-ci-token

# Google Play service account JSON
GOOGLE_PLAY_SERVICE_ACCOUNT={"type":"service_account",...}

# App Store Connect API key (for iOS)
APP_STORE_CONNECT_API_KEY=...
APP_STORE_CONNECT_ISSUER_ID=...
APP_STORE_CONNECT_KEY_ID=...

# Environment-specific secrets
FOOTBALL_API_KEY_DEV=...
FOOTBALL_API_KEY_STAGING=...
FOOTBALL_API_KEY_PROD=...
```

### 3. Advanced CI/CD Features

**Branch Protection Rules**
```bash
# Require pull request reviews
# Require status checks to pass
# Require branches to be up to date
# Restrict pushes to matching branches
```

**Deployment Gates**
```yaml
environment:
  name: production
  url: https://your-app.web.app
  protection_rules:
    required_reviewers:
      - team:admin
    wait_timer: 5  # minutes
```

**Rollback Strategy**
```yaml
rollback:
  name: Rollback Production
  runs-on: ubuntu-latest
  if: github.event_name == 'workflow_dispatch'
  
  steps:
    - name: Rollback Firebase Functions
      run: |
        firebase functions:rollback functionName --token ${{ secrets.FIREBASE_TOKEN }}
    
    - name: Rollback Firestore Rules
      run: |
        git checkout HEAD~1 -- firestore.rules
        firebase deploy --only firestore:rules --token ${{ secrets.FIREBASE_TOKEN }}
```

## 📊 Monitoring and Analytics

### 1. Firebase Performance Monitoring

**Enable Performance Monitoring**
```dart
// In main.dart
import 'package:firebase_performance/firebase_performance.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Enable performance monitoring
  FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
  
  runApp(MyApp());
}
```

**Custom Traces**
```dart
// Track custom performance metrics
final trace = FirebasePerformance.instance.newTrace('team_load_time');
await trace.start();

// Your code here
await loadTeamData();

await trace.stop();
```

### 2. Error Tracking with Sentry

**Setup Sentry**
```yaml
# pubspec.yaml
dependencies:
  sentry_flutter: ^7.0.0
```

```dart
// main.dart
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'your-sentry-dsn';
      options.environment = 'production';
    },
    appRunner: () => runApp(MyApp()),
  );
}
```

### 3. Custom Analytics

**Track User Events**
```dart
// analytics_service.dart
class AnalyticsService {
  static Future<void> logUserAction(String action, {
    Map<String, Object>? parameters,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'user_action',
      parameters: {
        'action': action,
        'timestamp': DateTime.now().toIso8601String(),
        ...?parameters,
      },
    );
  }
}
```

## 🔒 Security Configuration

### 1. Firestore Security Rules

Deploy comprehensive security rules:

```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User data access
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Public read, authenticated write for favorites
    match /user_favorites/{favoriteId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
                       request.auth.uid == request.resource.data.user_id;
      allow update, delete: if request.auth != null && 
                              request.auth.uid == resource.data.user_id;
    }
    
    // Rate limiting
    match /rate_limits/{limitId} {
      allow read, write: if false; // Only Cloud Functions
    }
  }
}
```

### 2. Cloud Functions Security

**Authentication Middleware**
```typescript
// auth.ts
export const authenticateMiddleware = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const token = req.headers.authorization?.split('Bearer ')[1];
    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }
    
    const decodedToken = await admin.auth().verifyIdToken(token);
    (req as any).user = decodedToken;
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid token' });
  }
};
```

### 3. API Security

**Rate Limiting**
```typescript
// rate-limiter.ts
export class RateLimiter {
  async checkLimit(
    key: string,
    maxRequests: number,
    windowMs: number,
    identifier: string
  ): Promise<{ allowed: boolean; resetTime: Date }> {
    const now = Date.now();
    const windowStart = now - windowMs;
    
    // Check current usage
    const usage = await this.getUsage(key, identifier, windowStart);
    
    if (usage >= maxRequests) {
      return {
        allowed: false,
        resetTime: new Date(now + windowMs),
      };
    }
    
    // Increment usage
    await this.incrementUsage(key, identifier);
    
    return {
      allowed: true,
      resetTime: new Date(now + windowMs),
    };
  }
}
```

## 🌍 Internationalization Setup

### 1. Flutter i18n Configuration

**Setup Localization**
```yaml
# pubspec.yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: any

dev_dependencies:
  intl_utils: ^2.8.0
```

**Configure l10n.yaml**
```yaml
# l10n.yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

**Generate Translations**
```bash
flutter gen-l10n
```

### 2. Multi-language Support

Create translation files:
- `lib/l10n/app_en.arb` (English)
- `lib/l10n/app_sk.arb` (Slovak)

```json
// app_en.arb
{
  "appTitle": "Football Stats",
  "login": "Login",
  "logout": "Logout",
  "teams": "Teams",
  "leagues": "Leagues"
}
```

```json
// app_sk.arb
{
  "appTitle": "Futbalové Štatistiky",
  "login": "Prihlásiť sa",
  "logout": "Odhlásiť sa",
  "teams": "Tímy",
  "leagues": "Ligy"
}
```

## 🚨 Disaster Recovery

### 1. Backup Strategy

**Firestore Backups**
```bash
# Schedule regular backups
gcloud firestore export gs://your-backup-bucket/$(date +%Y-%m-%d)

# Automated backup script
#!/bin/bash
DATE=$(date +%Y-%m-%d)
gcloud firestore export gs://football-stats-backups/$DATE
echo "Backup completed: $DATE"
```

**Cloud Functions Backup**
```bash
# Export Cloud Functions source code
firebase functions:log > functions-logs-$(date +%Y-%m-%d).txt
git archive --format=tar.gz --output=functions-backup-$(date +%Y-%m-%d).tar.gz HEAD functions/
```

### 2. Recovery Procedures

**Firestore Recovery**
```bash
# Restore from backup
gcloud firestore import gs://your-backup-bucket/2025-01-31
```

**Functions Recovery**
```bash
# Rollback to previous version
firebase functions:rollback --token $FIREBASE_TOKEN

# Or redeploy from backup
tar -xzf functions-backup-2025-01-31.tar.gz
cd functions
firebase deploy --only functions
```

### 3. Incident Response Plan

1. **Detection**: Monitor alerts and user reports
2. **Assessment**: Evaluate impact and severity
3. **Communication**: Notify stakeholders
4. **Mitigation**: Implement immediate fixes
5. **Recovery**: Restore full functionality
6. **Post-mortem**: Document and prevent recurrence

## 📈 Performance Optimization

### 1. Flutter Performance

**Build Optimizations**
```bash
# Enable R8 obfuscation (Android)
flutter build apk --release --obfuscate --split-debug-info=build/debug-info/

# Enable tree shaking (Web)
flutter build web --release --tree-shake-icons
```

**Runtime Optimizations**
```dart
// Use const constructors
const TeamCard(team: team);

// Implement lazy loading
ListView.builder(
  itemCount: teams.length,
  itemBuilder: (context, index) => TeamItem(teams[index]),
);

// Cache expensive operations
@override
Widget build(BuildContext context) {
  return Consumer(
    builder: (context, ref, child) {
      final teams = ref.watch(teamsProvider);
      return teams.when(
        data: (data) => TeamsList(teams: data),
        loading: () => const LoadingSpinner(),
        error: (error, stack) => ErrorWidget(error),
      );
    },
  );
}
```

### 2. Firebase Performance

**Function Optimizations**
```typescript
// Use connection pooling
const pool = new Pool({
  create: () => createConnection(),
  destroy: (connection) => connection.close(),
  max: 10,
  min: 2,
});

// Implement caching
const cache = new Map();
export const cachedFunction = functions.https.onCall(async (data) => {
  const cacheKey = JSON.stringify(data);
  
  if (cache.has(cacheKey)) {
    return cache.get(cacheKey);
  }
  
  const result = await expensiveOperation(data);
  cache.set(cacheKey, result);
  
  return result;
});

// Use batch operations
const batch = db.batch();
teams.forEach(team => {
  const ref = db.collection('teams').doc();
  batch.set(ref, team);
});
await batch.commit();
```

## 🔍 Testing in Production

### 1. A/B Testing Setup

```dart
// remote_config_service.dart
class RemoteConfigService {
  static final _instance = FirebaseRemoteConfig.instance;
  
  static Future<void> initialize() async {
    await _instance.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    
    await _instance.setDefaults({
      'show_new_feature': false,
      'api_endpoint_version': 'v1',
    });
    
    await _instance.fetchAndActivate();
  }
  
  static bool get showNewFeature => _instance.getBool('show_new_feature');
  static String get apiVersion => _instance.getString('api_endpoint_version');
}
```

### 2. Feature Flags

```dart
// feature_flags.dart
class FeatureFlags {
  static bool get enableDarkMode => RemoteConfigService.getBool('enable_dark_mode');
  static bool get enablePushNotifications => RemoteConfigService.getBool('enable_push_notifications');
  static int get maxTeamsPerUser => RemoteConfigService.getInt('max_teams_per_user');
}

// Usage in widgets
Widget build(BuildContext context) {
  if (FeatureFlags.enableDarkMode) {
    return DarkModeToggle();
  }
  return Container();
}
```

## 📞 Support and Maintenance

### 1. Monitoring Setup

**Health Checks**
```typescript
// health-check.ts
export const healthCheck = functions.https.onRequest(async (req, res) => {
  const checks = {
    timestamp: new Date().toISOString(),
    status: 'healthy',
    version: process.env.npm_package_version,
    checks: {
      database: await checkDatabase(),
      externalApi: await checkExternalApi(),
      cache: await checkCache(),
    },
  };
  
  const overallHealth = Object.values(checks.checks).every(check => check === 'healthy');
  
  res.status(overallHealth ? 200 : 503).json(checks);
});
```

**Alerting Rules**
```yaml
# monitoring/alerts.yml
groups:
  - name: football-stats-alerts
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: High error rate detected
          
      - alert: DatabaseConnectionIssues
        expr: up{job="firestore"} == 0
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: Database connection issues
```

### 2. Maintenance Procedures

**Weekly Maintenance**
```bash
#!/bin/bash
# weekly-maintenance.sh

# Check and clean logs
firebase functions:log --only="error" | wc -l

# Update dependencies
cd functions && npm audit && npm update

# Run security scans
npm audit --audit-level high

# Check performance metrics
firebase performance --project=football-stats-prod

# Validate backups
gsutil ls gs://football-stats-backups/ | tail -7
```

**Monthly Reviews**
- Review Firebase usage and costs
- Update dependencies to latest versions
- Review and update security rules
- Performance optimization review
- User feedback analysis
- Plan capacity scaling

---

## 🎉 Go-Live Checklist

### Pre-Launch (T-1 week)
- [ ] All tests passing in CI/CD pipeline
- [ ] Production environment configured and tested
- [ ] Security rules reviewed and approved
- [ ] Performance benchmarks met
- [ ] Backup and recovery procedures tested
- [ ] Monitoring and alerting configured
- [ ] Documentation complete and reviewed
- [ ] Support procedures established

### Launch Day (T-0)
- [ ] Final deployment to production
- [ ] Smoke tests passed
- [ ] Monitoring dashboards active
- [ ] Support team notified and ready
- [ ] Rollback plan confirmed
- [ ] Success metrics baseline established

### Post-Launch (T+1 week)
- [ ] Monitor key metrics and performance
- [ ] Address any immediate issues
- [ ] Collect user feedback
- [ ] Review and optimize based on real usage
- [ ] Plan next iteration features

---

**Deployment Guide Version**: 1.0.0  
**Last Updated**: January 31, 2025  
**Next Review**: March 31, 2025

For additional support, refer to:
- [API Documentation](API.md)
- [Architecture Guide](ARCHITECTURE.md)
- [Troubleshooting Guide](TROUBLESHOOTING.md)
- [Developer Guide](DEVELOPER_GUIDE.md)