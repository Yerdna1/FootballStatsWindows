# Football Stats Firebase Backend

A comprehensive Firebase backend solution for a football statistics mobile application, built with TypeScript and Firebase Cloud Functions.

## 🏗️ Architecture Overview

This backend provides:
- **RESTful API** endpoints for football data
- **Real-time data synchronization** with Firestore
- **External API integration** with Football API (api-sports.io)
- **Authentication & authorization** with Firebase Auth
- **Push notifications** system
- **Analytics & insights** generation
- **Rate limiting** and caching
- **Scheduled data updates**

## 📁 Project Structure

```
football_stats/
├── functions/                    # Cloud Functions source code
│   ├── src/
│   │   ├── api/                 # HTTP API endpoints
│   │   │   ├── routes/          # Express route handlers
│   │   │   ├── callable.ts      # Callable functions
│   │   │   └── index.ts         # Express app configuration
│   │   ├── scheduled/           # Scheduled functions
│   │   ├── triggers/            # Firestore & Auth triggers
│   │   ├── services/            # Business logic services
│   │   │   ├── football-api.ts  # External API integration
│   │   │   ├── notification.ts  # Push notifications
│   │   │   └── analytics.ts     # Analytics computation
│   │   ├── utils/               # Utility functions
│   │   │   ├── auth.ts          # Authentication helpers
│   │   │   ├── cache.ts         # Caching system
│   │   │   ├── validation.ts    # Input validation
│   │   │   ├── rate-limiter.ts  # Rate limiting
│   │   │   └── error-handler.ts # Error handling
│   │   ├── types/               # TypeScript type definitions
│   │   └── index.ts             # Function exports
│   ├── package.json             # Dependencies
│   └── tsconfig.json            # TypeScript configuration
├── firebase.json                # Firebase configuration
├── .firebaserc                  # Project aliases
├── firestore.rules              # Security rules
├── firestore.indexes.json       # Database indexes
├── storage.rules                # Storage security rules
├── deploy.sh                    # Unix deployment script
├── deploy.bat                   # Windows deployment script
└── README_FIREBASE.md           # This file
```

## 🚀 Quick Start

### Prerequisites

1. **Node.js** (v18 or higher)
2. **Firebase CLI**: `npm install -g firebase-tools`
3. **Firebase Project** with the following services enabled:
   - Authentication
   - Firestore Database
   - Cloud Functions
   - Cloud Storage
   - Cloud Messaging (for push notifications)

### Setup

1. **Clone and install dependencies:**
   ```bash
   cd functions
   npm install
   ```

2. **Configure environment variables:**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. **Login to Firebase:**
   ```bash
   firebase login
   ```

4. **Set your Firebase project:**
   ```bash
   firebase use your-project-id
   ```

5. **Deploy to Firebase:**
   ```bash
   # Unix/Linux/macOS
   ./deploy.sh your-project-id development
   
   # Windows
   deploy.bat your-project-id development
   ```

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the `functions/` directory:

```env
# Football API Configuration
FOOTBALL_API_KEY=2061b15078fc8e299dd268fb5a066f34
FOOTBALL_API_BASE_URL=https://v3.football.api-sports.io

# Firebase Configuration
FIREBASE_PROJECT_ID=your-project-id

# Feature Flags
CACHE_ENABLED=true
RATE_LIMIT_ENABLED=true
FCM_ENABLED=true
```

### Firebase Functions Config (Alternative)

You can also use Firebase Functions config:

```bash
firebase functions:config:set football.api_key="your-api-key"
firebase functions:config:set football.base_url="https://v3.football.api-sports.io"
```

## 📊 Database Schema

### Collections Overview

- **users**: User profiles and preferences
- **user_permissions**: Role-based access control
- **leagues**: Football leagues information
- **teams**: Team details and statistics
- **fixtures**: Match fixtures and results
- **standings**: League standings
- **team_statistics**: Detailed team performance data
- **user_favorites**: User's favorite teams/leagues
- **notifications**: Push notifications
- **analytics_cache**: Cached analytics data
- **activity_logs**: User activity and audit trail
- **api_cache**: External API response cache
- **rate_limits**: Rate limiting data

### Security Rules

The Firestore security rules implement:
- **Authentication-based access** control
- **Role-based permissions** (user, moderator, admin)
- **Resource ownership** validation
- **Data validation** rules
- **Rate limiting** at database level

## 🔗 API Endpoints

### Public Endpoints

- `GET /api/v1/health` - Health check
- `GET /api/v1/leagues` - Get leagues
- `GET /api/v1/teams` - Get teams
- `GET /api/v1/fixtures` - Get fixtures
- `GET /api/v1/standings` - Get standings

### Authenticated Endpoints

- `GET /api/v1/users/profile` - Get user profile
- `POST /api/v1/favorites` - Add favorite team/league
- `GET /api/v1/notifications` - Get user notifications
- `POST /api/v1/analytics/refresh` - Refresh user data

### Admin Endpoints

- `POST /api/v1/admin/leagues/sync` - Sync leagues from API
- `GET /api/v1/admin/analytics` - System analytics
- `POST /api/v1/admin/users/permissions` - Manage permissions

### Callable Functions

- `getUserStats(userId)` - Get user statistics
- `getTeamAnalytics(teamId, season)` - Get team insights
- `getLeagueInsights(leagueId, season)` - Get league analytics
- `refreshUserData()` - Refresh user's favorite teams data

## ⏰ Scheduled Functions

- **refreshFootballData**: Updates league data every 6 hours
- **cleanupExpiredCache**: Cleans cache daily at 2 AM UTC
- **generateAnalytics**: Computes analytics daily at 4 AM UTC
- **sendNotifications**: Processes notifications every 30 minutes

## 🔐 Authentication & Authorization

### User Roles

1. **User**: Basic access to public data and own profile
2. **Moderator**: Can manage leagues, teams, fixtures
3. **Admin**: Full system access including user management

### Permission System

```typescript
// Example permission check
authService.requireRole(userContext, UserRole.MODERATOR);
authService.requirePermission(userContext, Permission.MANAGE_LEAGUES);
```

## 📈 Analytics & Monitoring

### Built-in Analytics

- **User engagement** metrics
- **Content popularity** tracking
- **System performance** monitoring
- **Error tracking** and alerting

### Caching Strategy

- **API responses**: 1 hour default TTL
- **Analytics data**: 2 hours TTL
- **User statistics**: 30 minutes TTL
- **Automatic cleanup** of expired cache

### Rate Limiting

- **API endpoints**: 60 requests/minute
- **Intensive operations**: 10 requests/minute
- **Authentication**: 5 requests/15 minutes
- **Per-user and IP-based** limiting

## 🔔 Notifications

### Notification Types

- **Team updates**: Match results, statistics
- **League updates**: Standings changes
- **System alerts**: Maintenance, errors
- **User activities**: Welcome, profile changes

### Push Notification Setup

1. **Enable FCM** in Firebase Console
2. **Configure service account** for server key
3. **Set FCM_ENABLED=true** in environment
4. **Update client** to send FCM tokens

## 🚀 Deployment

### Development Deployment

```bash
# Unix/Linux/macOS
./deploy.sh football-stats-dev development

# Windows
deploy.bat football-stats-dev development
```

### Production Deployment

```bash
# Unix/Linux/macOS
./deploy.sh football-stats-prod production

# Windows
deploy.bat football-stats-prod production
```

### CI/CD Integration

The deployment scripts can be integrated with CI/CD pipelines:

```yaml
# GitHub Actions example
- name: Deploy to Firebase
  run: ./deploy.sh ${{ secrets.FIREBASE_PROJECT_ID }} production
  env:
    FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
```

## 🧪 Testing

### Run Tests

```bash
cd functions
npm test
```

### Test Coverage

```bash
npm run test:coverage
```

### Integration Testing

Use Firebase Emulators for local testing:

```bash
firebase emulators:start
```

## 📝 Logging & Debugging

### View Logs

```bash
# All functions
firebase functions:log

# Specific function
firebase functions:log --only api

# Follow logs in real-time
firebase functions:log --follow
```

### Debug Mode

Set `LOG_LEVEL=debug` in environment for detailed logging.

## 🔧 Maintenance

### Database Maintenance

- **Index optimization**: Monitor query performance
- **Data cleanup**: Remove old logs and cache
- **Backup strategy**: Automated Firestore backups

### Performance Monitoring

- **Function execution times**
- **Database read/write operations**
- **External API usage**
- **Error rates and types**

## 📞 Support & Troubleshooting

### Common Issues

1. **Function timeout**: Increase timeout in firebase.json
2. **Memory limits**: Adjust memory allocation
3. **API rate limits**: Implement exponential backoff
4. **Cold starts**: Use minimum instances for critical functions

### Monitoring Tools

- **Firebase Console**: Function metrics and logs
- **Error Reporting**: Automatic error tracking
- **Performance Monitoring**: Client-side performance
- **Custom Analytics**: Built-in analytics dashboard

## 📚 Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [Football API Documentation](https://www.api-football.com/documentation-v3)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Express.js Guide](https://expressjs.com/en/guide/)

## ✨ Features

### ✅ Implemented

- Complete API integration with Football API
- User authentication and authorization
- Real-time data synchronization
- Push notifications system
- Analytics and insights
- Rate limiting and caching
- Scheduled data updates
- Error handling and logging
- Security rules and validation
- Deployment automation

### 🚧 Future Enhancements

- Machine learning predictions
- Real-time match updates
- Social features (comments, ratings)
- Advanced analytics dashboards
- Multi-language support
- Offline data synchronization

---

**Built with ❤️ using Firebase, TypeScript, and modern development practices.**