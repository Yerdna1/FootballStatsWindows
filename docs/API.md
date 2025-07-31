# Football Stats API Documentation

This document provides comprehensive documentation for the Football Stats application backend API, built with Firebase Cloud Functions and TypeScript.

## 🏗️ API Overview

The Football Stats API provides access to:
- **Football leagues and teams data**
- **Match fixtures and results**
- **League standings and statistics**
- **User authentication and profile management**
- **Favorites and notification system**
- **Analytics and insights**

### Base URL
```
https://us-central1-[project-id].cloudfunctions.net/api
```

### API Version
Current version: `v1`

All endpoints are prefixed with `/api/v1/`

## 🔐 Authentication

### Authentication Methods
The API supports multiple authentication methods:

1. **Firebase ID Token** (Recommended)
   ```http
   Authorization: Bearer <firebase-id-token>
   ```

2. **API Key** (For server-to-server communication)
   ```http
   X-API-Key: <api-key>
   ```

### User Roles
- **User**: Basic access to public data and own profile
- **Moderator**: Can manage leagues, teams, fixtures  
- **Admin**: Full system access including user management

## 🌐 HTTP Endpoints

### Health Check

#### GET /health
Check API health status.

**Response**
```json
{
  "status": "healthy",
  "timestamp": "2025-01-31T10:00:00.000Z",
  "version": "1.0.0"
}
```

---

## ⚽ Leagues

### GET /api/v1/leagues
Get all active leagues with optional filtering.

**Query Parameters**
| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `country` | string | Filter by country name | - |
| `season` | number | Filter by season year | - |
| `page` | number | Page number for pagination | 1 |
| `limit` | number | Number of items per page | 20 |

**Example Request**
```http
GET /api/v1/leagues?country=England&season=2025&page=1&limit=10
```

**Response**
```json
{
  "data": [
    {
      "id": "league-doc-id",
      "api_league_id": 39,
      "name": "Premier League",
      "country": "England",
      "logo": "https://media.api-sports.io/football/leagues/39.png",
      "flag": "https://media.api-sports.io/flags/gb.svg",
      "season": 2025,
      "is_active": true,
      "created_at": "2025-01-01T00:00:00.000Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 50,
    "pages": 5
  }
}
```

### GET /api/v1/leagues/:id
Get specific league by ID.

**Parameters**
| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | string | League document ID |

**Response**
```json
{
  "data": {
    "id": "league-doc-id",
    "api_league_id": 39,
    "name": "Premier League",
    "country": "England",
    "logo": "https://media.api-sports.io/football/leagues/39.png",
    "flag": "https://media.api-sports.io/flags/gb.svg",
    "season": 2025,
    "is_active": true,
    "created_at": "2025-01-01T00:00:00.000Z"
  }
}
```

### POST /api/v1/leagues
Create new league (Admin only).

**Authentication**: Required (Admin role)

**Request Body**
```json
{
  "api_league_id": 39,
  "name": "Premier League",
  "country": "England",
  "logo": "https://media.api-sports.io/football/leagues/39.png",
  "flag": "https://media.api-sports.io/flags/gb.svg",
  "season": 2025
}
```

**Response**
```json
{
  "data": {
    "id": "new-league-doc-id",
    "api_league_id": 39,
    "name": "Premier League",
    "country": "England",
    "logo": "https://media.api-sports.io/football/leagues/39.png",
    "flag": "https://media.api-sports.io/flags/gb.svg",
    "season": 2025,
    "is_active": true,
    "created_at": "2025-01-31T10:00:00.000Z"
  }
}
```

### PUT /api/v1/leagues/:id
Update league (Moderator+ role required).

**Authentication**: Required (Moderator or Admin role)

**Request Body**
```json
{
  "name": "Updated League Name",
  "season": 2025
}
```

### DELETE /api/v1/leagues/:id
Soft delete league (Admin only).

**Authentication**: Required (Admin role)

**Response**: `204 No Content`

### POST /api/v1/leagues/sync
Sync leagues from Football API (Admin only).

**Authentication**: Required (Admin role)

**Response**
```json
{
  "message": "League sync completed",
  "stats": {
    "total": 100,
    "created": 20,
    "updated": 80,
    "errors": 0
  }
}
```

---

## 👥 Teams

### GET /api/v1/teams
Get teams with optional filtering.

**Query Parameters**
| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `league_id` | string | Filter by league ID | - |
| `country` | string | Filter by country | - |
| `search` | string | Search by team name | - |
| `page` | number | Page number | 1 |
| `limit` | number | Items per page | 20 |

**Response**
```json
{
  "data": [
    {
      "id": "team-doc-id",
      "api_team_id": 33,
      "name": "Manchester United",
      "code": "MUN",
      "country": "England",
      "founded": 1878,
      "logo": "https://media.api-sports.io/football/teams/33.png",
      "venue": {
        "name": "Old Trafford",
        "city": "Manchester",
        "capacity": 76000
      },
      "league_id": "league-doc-id"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "pages": 5
  }
}
```

### GET /api/v1/teams/:id
Get specific team by ID.

### POST /api/v1/teams
Create new team (Moderator+ required).

### PUT /api/v1/teams/:id
Update team (Moderator+ required).

### DELETE /api/v1/teams/:id
Soft delete team (Admin only).

---

## 📅 Fixtures

### GET /api/v1/fixtures
Get match fixtures.

**Query Parameters**
| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `league_id` | string | Filter by league | - |
| `team_id` | string | Filter by team | - |
| `season` | number | Filter by season | Current year |
| `status` | string | Filter by status (NS, LIVE, FT) | - |
| `date_from` | string | Start date (YYYY-MM-DD) | - |
| `date_to` | string | End date (YYYY-MM-DD) | - |
| `page` | number | Page number | 1 |
| `limit` | number | Items per page | 20 |

**Response**
```json
{
  "data": [
    {
      "id": "fixture-doc-id",
      "api_fixture_id": 868005,
      "league_id": "league-doc-id",
      "season": 2025,
      "date": "2025-02-01T15:00:00.000Z",
      "status": {
        "long": "Match Finished",
        "short": "FT",
        "elapsed": 90
      },
      "home_team": {
        "id": "team-doc-id-1",
        "name": "Manchester United",
        "logo": "https://media.api-sports.io/football/teams/33.png"
      },
      "away_team": {
        "id": "team-doc-id-2", 
        "name": "Liverpool",
        "logo": "https://media.api-sports.io/football/teams/40.png"
      },
      "goals": {
        "home": 2,
        "away": 1
      },
      "score": {
        "halftime": {
          "home": 1,
          "away": 0
        },
        "fulltime": {
          "home": 2,
          "away": 1
        }
      }
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 380,
    "pages": 19
  }
}
```

### GET /api/v1/fixtures/:id
Get specific fixture by ID.

### GET /api/v1/fixtures/live
Get live fixtures.

---

## 🏆 Standings

### GET /api/v1/standings
Get league standings.

**Query Parameters**
| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `league_id` | string | League ID (required) | - |
| `season` | number | Season year | Current year |

**Response**
```json
{
  "data": [
    {
      "position": 1,
      "team_id": "team-doc-id",
      "team": {
        "name": "Manchester City",
        "logo": "https://media.api-sports.io/football/teams/50.png"
      },
      "points": 65,
      "games_played": 25,
      "wins": 20,
      "draws": 5,
      "losses": 0,
      "goals_for": 58,
      "goals_against": 15,
      "goals_diff": 43,
      "form": "WWWDW"
    }
  ]
}
```

---

## 👤 Users

### GET /api/v1/users/profile
Get current user profile.

**Authentication**: Required

**Response**
```json
{
  "data": {
    "id": "user-id",
    "email": "user@example.com",
    "display_name": "John Doe",
    "preferences": {
      "theme": "dark",
      "language": "en",
      "notifications": true
    },
    "created_at": "2025-01-01T00:00:00.000Z",
    "last_login": "2025-01-31T10:00:00.000Z"
  }
}
```

### PUT /api/v1/users/profile
Update user profile.

**Authentication**: Required

**Request Body**
```json
{
  "display_name": "Updated Name",
  "preferences": {
    "theme": "light",
    "language": "sk",
    "notifications": false
  }
}
```

---

## ⭐ Favorites

### GET /api/v1/favorites
Get user's favorites.

**Authentication**: Required

**Query Parameters**
| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `type` | string | Filter by type (team, league) | - |

**Response**
```json
{
  "data": [
    {
      "id": "favorite-doc-id",
      "type": "team",
      "entity_id": "team-id",
      "entity_data": {
        "name": "Manchester United",
        "logo": "https://media.api-sports.io/football/teams/33.png"
      },
      "created_at": "2025-01-01T00:00:00.000Z"
    }
  ]
}
```

### POST /api/v1/favorites
Add item to favorites.

**Authentication**: Required

**Request Body**
```json
{
  "type": "team",
  "entity_id": "team-id"
}
```

### DELETE /api/v1/favorites/:id
Remove item from favorites.

**Authentication**: Required

---

## 🔔 Notifications

### GET /api/v1/notifications
Get user notifications.

**Authentication**: Required

**Query Parameters**
| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `read` | boolean | Filter by read status | - |
| `type` | string | Filter by notification type | - |
| `page` | number | Page number | 1 |
| `limit` | number | Items per page | 20 |

**Response**
```json
{
  "data": [
    {
      "id": "notification-doc-id",
      "title": "Match Result",
      "message": "Manchester United won 2-1 against Liverpool",
      "type": "match_result",
      "data": {
        "fixture_id": "fixture-id",
        "team_id": "team-id"
      },
      "read": false,
      "created_at": "2025-01-31T17:00:00.000Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 15,
    "pages": 1
  }
}
```

### PUT /api/v1/notifications/:id/read
Mark notification as read.

**Authentication**: Required

### DELETE /api/v1/notifications/:id
Delete notification.

**Authentication**: Required

---

## 📊 Analytics

### GET /api/v1/analytics/dashboard
Get dashboard analytics for authenticated user.

**Authentication**: Required

**Response**
```json
{
  "data": {
    "favorite_teams_count": 5,
    "favorite_leagues_count": 3,
    "notifications_count": 15,
    "unread_notifications": 3,
    "recent_activity": [
      {
        "type": "favorite_added",
        "entity": "Manchester United",
        "timestamp": "2025-01-31T10:00:00.000Z"
      }
    ]
  }
}
```

### POST /api/v1/analytics/refresh
Refresh user's cached analytics data.

**Authentication**: Required

---

## 🔧 Admin Endpoints

### GET /api/v1/admin/stats
Get system statistics (Admin only).

**Authentication**: Required (Admin role)

**Response**
```json
{
  "data": {
    "users_count": 1500,
    "leagues_count": 100,
    "teams_count": 2000,
    "fixtures_count": 50000,
    "api_requests_today": 25000,
    "cache_hit_rate": 0.85
  }
}
```

### GET /api/v1/admin/users
Get all users (Admin only).

### POST /api/v1/admin/users/:id/role
Update user role (Admin only).

---

## 🎯 Callable Functions

Firebase Callable Functions provide a more integrated experience with the Firebase SDK.

### getUserStats(userId?)
Get user statistics and analytics.

**Parameters**
```typescript
{
  userId?: string // Optional, defaults to current user
}
```

**Response**
```typescript
{
  user_id: string;
  favorites: {
    total: number;
    teams: number;
    leagues: number;
  };
  notifications: {
    total: number;
    unread: number;
  };
  recent_activity: Array<{
    id: string;
    type: string;
    timestamp: string;
  }>;
  generated_at: string;
}
```

**Usage Example (Flutter)**
```dart
final functions = FirebaseFunctions.instance;
final result = await functions
    .httpsCallable('getUserStats')
    .call({'userId': 'optional-user-id'});
final stats = result.data;
```

### getTeamAnalytics(teamId, season?)
Get comprehensive team analytics.

**Parameters**
```typescript
{
  teamId: string; // Required
  season?: number; // Optional, defaults to current year
}
```

**Response**
```typescript
{
  team: {
    id: string;
    name: string;
    country: string;
    logo: string;
  };
  season: number;
  statistics: TeamStatistics | null;
  standings: StandingPosition | null;
  performance: {
    total_fixtures: number;
    completed_fixtures: number;
    upcoming_fixtures: number;
    home_fixtures: number;
    away_fixtures: number;
    home_wins: number;
    away_wins: number;
    total_wins: number;
  };
  popularity: {
    followers: number;
  };
  generated_at: string;
}
```

### getLeagueInsights(leagueId, season?)
Get league insights and statistics.

**Parameters**
```typescript
{
  leagueId: string; // Required
  season?: number; // Optional, defaults to current year
}
```

**Response**
```typescript
{
  league: {
    id: string;
    name: string;
    country: string;
    logo: string;
  };
  season: number;
  statistics: {
    total_teams: number;
    total_fixtures: number;
    completed_fixtures: number;
    upcoming_fixtures: number;
    total_goals: number;
    average_goals_per_match: number;
  };
  standings: {
    total_positions: number;
    leader: {
      team_id: string;
      position: number;
      points: number;
      goals_diff: number;
    } | null;
  };
  popularity: {
    followers: number;
  };
  generated_at: string;
}
```

### refreshUserData()
Refresh user's favorite teams data from external API.

**Parameters**
```typescript
// No parameters required
```

**Response**
```typescript
{
  message: string;
  refreshed_teams: number;
  total_teams: number;
  errors?: string[];
}
```

---

## 🚨 Error Handling

### Error Response Format
All errors follow a consistent format:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable error message",
    "details": {
      "field": "Additional error details"
    },
    "timestamp": "2025-01-31T10:00:00.000Z"
  }
}
```

### Common Error Codes

| HTTP Status | Error Code | Description |
|-------------|------------|-------------|
| 400 | `INVALID_REQUEST` | Invalid request format or parameters |
| 401 | `UNAUTHORIZED` | Authentication required or invalid |
| 403 | `FORBIDDEN` | Insufficient permissions |
| 404 | `NOT_FOUND` | Resource not found |
| 429 | `RATE_LIMIT_EXCEEDED` | Too many requests |
| 500 | `INTERNAL_ERROR` | Server error |

### Validation Errors
Field validation errors provide specific details:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": {
      "email": "Invalid email format",
      "age": "Must be a positive number"
    },
    "timestamp": "2025-01-31T10:00:00.000Z"
  }
}
```

---

## 🔒 Rate Limiting

### Rate Limit Headers
API responses include rate limiting information:

```http
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1643634000
```

### Rate Limit Configurations

| Endpoint Type | Requests | Time Window | Scope |
|---------------|----------|-------------|-------|
| General API | 60 | 1 minute | Per user/IP |
| Authentication | 5 | 15 minutes | Per user/IP |
| Intensive Operations | 10 | 1 minute | Per user |
| Admin Operations | 100 | 1 minute | Per user |

### Rate Limit Response
When rate limit is exceeded:

```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests",
    "resetTime": "2025-01-31T10:01:00.000Z"
  }
}
```

---

## 💾 Caching

### Cache Headers
API responses include caching information:

```http
Cache-Control: public, max-age=3600
ETag: "abc123"
Last-Modified: Fri, 31 Jan 2025 10:00:00 GMT
```

### Cache Strategy

| Data Type | TTL | Strategy |
|-----------|-----|----------|
| Leagues | 24 hours | Cache-first |
| Teams | 12 hours | Cache-first |
| Fixtures (completed) | 6 hours | Cache-first |
| Fixtures (upcoming) | 30 minutes | Network-first |
| Standings | 1 hour | Network-first |
| User data | 15 minutes | Network-first |

---

## 🔍 Filtering and Sorting

### Query Operators
Most list endpoints support advanced filtering:

| Operator | Description | Example |
|----------|-------------|---------|
| `eq` | Equals | `country=England` |
| `ne` | Not equals | `status=ne:FT` |
| `gt` | Greater than | `points=gt:50` |
| `gte` | Greater than or equal | `date=gte:2025-01-01` |
| `lt` | Less than | `position=lt:5` |
| `lte` | Less than or equal | `date=lte:2025-12-31` |
| `in` | In array | `status=in:NS,LIVE` |
| `contains` | Contains text | `name=contains:United` |

### Sorting
Use the `sort` parameter for ordering:

```http
GET /api/v1/standings?league_id=abc&sort=position:asc
GET /api/v1/fixtures?sort=date:desc,home_team:asc
```

---

## 📡 Real-time Updates

### WebSocket Connection
Connect to real-time updates:

```javascript
const socket = io('wss://us-central1-[project-id].cloudfunctions.net/api');

// Subscribe to live fixtures
socket.emit('subscribe', { type: 'fixtures', league_id: 'abc123' });

// Listen for updates
socket.on('fixture_update', (data) => {
  console.log('Fixture updated:', data);
});
```

### Firestore Real-time
For Flutter apps, use Firestore listeners:

```dart
FirebaseFirestore.instance
    .collection('fixtures')
    .where('status.short', isEqualTo: 'LIVE')
    .snapshots()
    .listen((snapshot) {
      // Handle live fixture updates
    });
```

---

## 🧪 Testing

### Test Environment
```
Base URL: https://us-central1-[project-id]-test.cloudfunctions.net/api
```

### Health Check
Always start with the health check endpoint:

```bash
curl https://us-central1-[project-id].cloudfunctions.net/api/health
```

### Authentication Testing
Test with a Firebase ID token:

```bash
curl -H "Authorization: Bearer <firebase-id-token>" \
     https://us-central1-[project-id].cloudfunctions.net/api/v1/users/profile
```

---

## 📚 SDKs and Libraries

### Official Firebase SDKs
- **Flutter**: `firebase_functions: ^4.7.10`
- **JavaScript**: `firebase/functions`
- **iOS**: `Firebase/Functions`
- **Android**: `firebase-functions`

### HTTP Clients
- **Flutter**: `dio: ^5.4.0`
- **JavaScript**: `axios`
- **Python**: `requests`
- **Java**: `OkHttp`

---

## 📝 Changelog

### Version 1.0.0 (Current)
- Initial API release
- Complete CRUD operations for all entities
- User authentication and authorization
- Rate limiting and caching
- Real-time capabilities
- Comprehensive error handling

### Upcoming Features
- GraphQL endpoint
- Advanced analytics
- Machine learning predictions
- Enhanced real-time features

---

## 📞 Support

### Documentation
- **Architecture**: [ARCHITECTURE.md](ARCHITECTURE.md)
- **Deployment**: [DEPLOYMENT.md](DEPLOYMENT.md)
- **Troubleshooting**: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

### Contact
- **Issues**: Create GitHub issue
- **Email**: support@footballstats.com
- **Discord**: [Football Stats Community](https://discord.gg/footballstats)

---

**Last Updated**: January 31, 2025  
**API Version**: 1.0.0  
**Firebase Functions**: 4.8.0