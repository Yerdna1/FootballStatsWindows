# Football Stats Application Architecture

This document provides detailed technical architecture and design decisions for the Football Stats application, covering both the Flutter frontend and Firebase backend implementation.

## 🏗️ System Overview

The Football Stats application follows a modern, scalable architecture pattern with clear separation of concerns:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │  Firebase       │    │  External APIs  │
│   (Frontend)    │◄──►│  Backend        │◄──►│  (Football      │
│                 │    │                 │    │   Data)         │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Key Architectural Principles

1. **Clean Architecture**: Separation of concerns with clear boundaries
2. **Domain-Driven Design**: Business logic organized around domain entities
3. **Reactive Programming**: State management with streams and providers
4. **Microservices Pattern**: Modular Firebase Cloud Functions
5. **Event-Driven Architecture**: Real-time updates through Firestore
6. **CQRS Pattern**: Separate read and write operations for optimization

## 📱 Frontend Architecture (Flutter)

### Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────────────┐
│                        Presentation Layer                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │    Pages    │  │   Widgets   │  │      Providers          │  │
│  │             │  │             │  │   (State Management)    │  │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────────┐
│                        Domain Layer                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │  Entities   │  │ Use Cases   │  │     Repositories        │  │
│  │             │  │             │  │     (Interfaces)        │  │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────────┐
│                         Data Layer                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │    Models   │  │ Data Sources│  │    Repositories         │  │
│  │             │  │             │  │   (Implementation)      │  │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### Project Structure Detail

```
lib/
├── core/                           # Core application utilities
│   ├── config/                     # Configuration files
│   │   ├── firebase_config.dart    # Firebase configuration
│   │   └── app_config.dart         # App-wide configuration
│   ├── constants/                  # Application constants
│   │   ├── app_constants.dart      # General app constants
│   │   ├── api_constants.dart      # API endpoints and keys
│   │   └── storage_constants.dart  # Local storage keys
│   ├── error/                      # Error handling system
│   │   ├── exceptions.dart         # Custom exception classes
│   │   ├── failures.dart           # Failure objects for error handling
│   │   └── error_handler.dart      # Global error handler
│   ├── network/                    # Network layer
│   │   ├── api_client.dart         # HTTP client configuration
│   │   ├── network_info.dart       # Network connectivity checker
│   │   └── interceptors.dart       # HTTP interceptors
│   ├── theme/                      # Application theming
│   │   ├── app_theme.dart          # Main theme configuration
│   │   ├── app_colors.dart         # Color palette
│   │   └── app_design_system.dart  # Design tokens
│   ├── utils/                      # Utility functions
│   │   ├── date_formatter.dart     # Date formatting utilities
│   │   ├── validators.dart         # Input validation
│   │   └── extensions.dart         # Dart extensions
│   ├── usecases/                   # Base use case classes
│   │   └── usecase.dart            # Abstract use case interface
│   └── widgets/                    # Core reusable widgets
│       ├── loading_button.dart     # Custom loading button
│       ├── custom_text_field.dart  # Custom input field
│       └── splash_screen.dart      # Application splash screen
├── features/                       # Feature-based modules
│   ├── authentication/             # User authentication feature
│   │   ├── data/                   # Data layer implementation
│   │   │   ├── datasources/        # Data sources (remote/local)
│   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   └── auth_local_datasource.dart
│   │   │   ├── models/             # Data models
│   │   │   │   ├── user_model.dart
│   │   │   │   └── auth_response_model.dart
│   │   │   └── repositories/       # Repository implementations
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/                 # Domain layer
│   │   │   ├── entities/           # Domain entities
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/       # Repository interfaces
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/           # Business logic use cases
│   │   │       ├── login_usecase.dart
│   │   │       ├── register_usecase.dart
│   │   │       ├── logout_usecase.dart
│   │   │       └── get_current_user_usecase.dart
│   │   └── presentation/           # Presentation layer
│   │       ├── pages/              # UI pages
│   │       │   ├── login_page.dart
│   │       │   ├── register_page.dart
│   │       │   └── profile_page.dart
│   │       ├── providers/          # State management providers
│   │       │   ├── auth_provider.dart
│   │       │   └── auth_state_provider.dart
│   │       └── widgets/            # Feature-specific widgets
│   │           ├── auth_header.dart
│   │           ├── login_form.dart
│   │           └── social_login_buttons.dart
│   ├── dashboard/                  # Dashboard feature
│   ├── leagues/                    # Leagues management
│   ├── teams/                      # Teams management
│   ├── fixtures/                   # Fixtures and matches
│   ├── standings/                  # League standings
│   ├── favorites/                  # User favorites
│   ├── notifications/              # Push notifications
│   └── settings/                   # Application settings
├── shared/                         # Shared components across features
│   ├── data/                       # Shared data models
│   │   ├── models/                 # Common data models
│   │   │   ├── league_model.dart
│   │   │   ├── team_model.dart
│   │   │   ├── fixture_model.dart
│   │   │   └── standings_model.dart
│   │   └── repositories/           # Shared repository interfaces
│   ├── providers/                  # Global providers
│   │   ├── connectivity_provider.dart
│   │   ├── theme_provider.dart
│   │   └── analytics_provider.dart
│   └── widgets/                    # Shared UI components
│       ├── cards/                  # Card components
│       │   ├── team_card.dart
│       │   └── match_card.dart
│       ├── indicators/             # Status indicators
│       │   ├── live_indicator.dart
│       │   └── form_indicator.dart
│       └── dashboard/              # Dashboard components
│           ├── quick_stats_card.dart
│           └── recent_matches_card.dart
├── navigation/                     # Navigation and routing
│   ├── app_router.dart             # Main app router configuration
│   └── main_navigation.dart        # Bottom navigation setup
└── main.dart                       # Application entry point
```

### State Management Architecture

The application uses **Riverpod** for state management with a layered approach:

```dart
// Provider hierarchy example
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepositoryImpl(apiClient);
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final loginUseCase = ref.watch(loginUseCaseProvider);
  return AuthNotifier(loginUseCase);
});
```

### Data Flow Pattern

```
User Interaction → Provider → Use Case → Repository → Data Source → API/Local Storage
                                                          ↓
User Interface ← Provider ← Use Case ← Repository ← Response Mapping ← API Response
```

## 🔥 Backend Architecture (Firebase)

### Microservices Structure

```
functions/
├── src/
│   ├── api/                        # HTTP API layer
│   │   ├── index.ts                # Express app configuration
│   │   ├── callable.ts             # Firebase callable functions
│   │   └── routes/                 # RESTful API routes
│   │       ├── leagues.ts          # League management endpoints
│   │       ├── teams.ts            # Team management endpoints
│   │       ├── fixtures.ts         # Fixture management endpoints
│   │       ├── standings.ts        # Standings endpoints
│   │       ├── users.ts            # User management endpoints
│   │       ├── favorites.ts        # User favorites endpoints
│   │       ├── notifications.ts    # Notification endpoints
│   │       ├── analytics.ts        # Analytics endpoints
│   │       └── admin.ts            # Admin-only endpoints
│   ├── scheduled/                  # Scheduled/cron functions
│   │   ├── index.ts                # Scheduled function exports
│   │   ├── data_sync.ts            # External API data synchronization
│   │   ├── cache_cleanup.ts        # Cache maintenance
│   │   ├── analytics_generation.ts # Analytics computation
│   │   └── notifications.ts        # Scheduled notifications
│   ├── triggers/                   # Database and Auth triggers
│   │   ├── index.ts                # Trigger function exports
│   │   ├── auth.ts                 # Authentication triggers
│   │   └── firestore.ts            # Firestore triggers
│   ├── services/                   # Business logic services
│   │   ├── index.ts                # Service exports
│   │   ├── football-api.ts         # External API integration
│   │   ├── notification.ts         # Push notification service
│   │   ├── analytics.ts            # Analytics computation
│   │   └── cache.ts                # Caching service
│   ├── utils/                      # Utility functions
│   │   ├── index.ts                # Utility exports
│   │   ├── auth.ts                 # Authentication helpers
│   │   ├── cache.ts                # Caching utilities
│   │   ├── validation.ts           # Input validation
│   │   ├── rate-limiter.ts         # Rate limiting
│   │   ├── error-handler.ts        # Error handling
│   │   ├── logger.ts               # Logging utilities  
│   │   └── transformers.ts         # Data transformation
│   ├── types/                      # TypeScript type definitions
│   │   └── index.ts                # Common interfaces and types
│   └── index.ts                    # Main function exports
```

### Service Layer Architecture

```typescript
// Service pattern example
export class FootballApiService {
  private readonly baseUrl: string;
  private readonly apiKey: string;
  private readonly cache: CacheService;
  private readonly rateLimiter: RateLimiterService;

  constructor() {
    this.baseUrl = process.env.FOOTBALL_API_BASE_URL!;
    this.apiKey = process.env.FOOTBALL_API_KEY!;
    this.cache = new CacheService();
    this.rateLimiter = new RateLimiterService();
  }

  async fetchLeagues(): Promise<League[]> {
    // Check rate limits
    await this.rateLimiter.checkLimit('football-api', 'leagues');
    
    // Check cache first
    const cached = await this.cache.get('leagues');
    if (cached) return cached;
    
    // Fetch from external API
    const response = await this.makeApiRequest('/leagues');
    
    // Cache the result
    await this.cache.set('leagues', response, 3600);
    
    return response;
  }
}
```

### Database Schema Design

#### Firestore Collections

```typescript
// Collection structure with relationships
interface DatabaseSchema {
  users: {
    [userId: string]: {
      email: string;
      display_name: string;
      preferences: UserPreferences;
      created_at: Timestamp;
      updated_at: Timestamp;
      last_login: Timestamp;
    };
  };
  
  user_permissions: {
    [userId: string]: {
      role: 'user' | 'moderator' | 'admin';
      permissions: string[];
      granted_by: string;
      granted_at: Timestamp;
    };
  };
  
  leagues: {
    [leagueId: string]: {
      api_league_id: number;
      name: string;
      country: string;
      logo: string;
      flag: string;
      season: number;
      is_active: boolean;
      created_at: Timestamp;
      updated_at?: Timestamp;
    };
  };
  
  teams: {
    [teamId: string]: {
      api_team_id: number;
      league_id: string; // Reference to leagues collection
      name: string;
      code: string;
      country: string;
      founded: number;
      logo: string;
      venue: {
        name: string;
        city: string;
        capacity: number;
      };
      is_active: boolean;
      created_at: Timestamp;
      updated_at?: Timestamp;
    };
  };
  
  fixtures: {
    [fixtureId: string]: {
      api_fixture_id: number;
      league_id: string; // Reference to leagues collection
      season: number;
      date: Timestamp;
      status: {
        long: string;
        short: string;
        elapsed: number;
      };
      home_team_id: string; // Reference to teams collection
      away_team_id: string; // Reference to teams collection
      goals: {
        home: number;
        away: number;
      };
      score: {
        halftime: { home: number; away: number; };
        fulltime: { home: number; away: number; };
      };
      created_at: Timestamp;
      updated_at?: Timestamp;
    };
  };
  
  standings: {
    [standingId: string]: {
      league_id: string; // Reference to leagues collection
      team_id: string; // Reference to teams collection
      season: number;
      position: number;
      points: number;
      games_played: number;
      wins: number;
      draws: number;
      losses: number;
      goals_for: number;
      goals_against: number;
      goals_diff: number;
      form: string;
      updated_at: Timestamp;
    };
  };
  
  user_favorites: {
    [favoriteId: string]: {
      user_id: string; // Reference to users collection
      type: 'team' | 'league';
      entity_id: string; // Reference to teams or leagues collection
      created_at: Timestamp;
    };
  };
  
  notifications: {
    [notificationId: string]: {
      user_id: string; // Reference to users collection
      title: string;
      message: string;
      type: string;
      data?: Record<string, any>;
      read: boolean;
      read_at?: Timestamp;
      created_at: Timestamp;
    };
  };
  
  // System collections
  analytics_cache: {
    [cacheId: string]: {
      key: string;
      data: any;
      expires_at: Timestamp;
      created_at: Timestamp;
    };
  };
  
  activity_logs: {
    [logId: string]: {
      user_id: string;
      action: string;
      entity_type: string;
      entity_id: string;
      metadata: Record<string, any>;
      timestamp: Timestamp;
    };
  };
  
  rate_limits: {
    [limitId: string]: {
      identifier: string;
      endpoint: string;
      count: number;
      window_start: Timestamp;
      expires_at: Timestamp;
    };
  };
  
  api_cache: {
    [cacheId: string]: {
      key: string;
      data: any;
      ttl: number;
      created_at: Timestamp;
      expires_at: Timestamp;
    };
  };
}
```

### Security Rules Architecture

```javascript
// Firestore security rules pattern
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions for reusability
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    function hasRole(role) {
      return isAuthenticated() && 
             exists(/databases/$(database)/documents/user_permissions/$(request.auth.uid)) &&
             get(/databases/$(database)/documents/user_permissions/$(request.auth.uid)).data.role == role;
    }
    
    // Role-based access patterns
    match /users/{userId} {
      allow read: if isOwner(userId) || hasRole('admin');
      allow write: if isOwner(userId);
    }
    
    // Public read, restricted write pattern
    match /leagues/{leagueId} {
      allow read: if true;
      allow write: if hasRole('moderator') || hasRole('admin');
    }
  }
}
```

## 🔄 Data Flow Architecture

### Request Flow Pattern

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Flutter   │    │  Firebase   │    │   Cloud     │    │  External   │
│     App     │    │    Auth     │    │ Functions   │    │     API     │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │                   │
       │ 1. User Request   │                   │                   │
       │──────────────────►│                   │                   │
       │                   │ 2. Validate Token │                   │
       │                   │──────────────────►│                   │
       │                   │                   │ 3. Check Cache    │
       │                   │                   │────────────────┐  │
       │                   │                   │                │  │
       │                   │                   │◄───────────────┘  │
       │                   │                   │ 4. External Call  │
       │                   │                   │──────────────────►│
       │                   │                   │ 5. API Response   │
       │                   │                   │◄──────────────────│
       │                   │                   │ 6. Process & Cache│
       │                   │                   │────────────────┐  │
       │                   │                   │                │  │
       │                   │                   │◄───────────────┘  │
       │ 7. Response       │                   │                   │
       │◄──────────────────────────────────────│                   │
```

### Real-time Data Synchronization

```typescript
// Firestore real-time listener pattern
export class FirestoreService {
  setupRealTimeListeners() {
    // Live fixtures listener
    this.db.collection('fixtures')
      .where('status.short', 'in', ['NS', 'LIVE', '1H', '2H'])
      .onSnapshot((snapshot) => {
        snapshot.docChanges().forEach((change) => {
          if (change.type === 'modified') {
            this.notifyClientsOfFixtureUpdate(change.doc.data());
          }
        });
      });
    
    // User favorites listener
    this.db.collection('user_favorites')
      .where('user_id', '==', userId)
      .onSnapshot((snapshot) => {
        this.updateUserFavoritesCache(snapshot.docs);
      });
  }
}
```

## 🔧 Design Patterns

### Repository Pattern Implementation

```dart
// Abstract repository interface
abstract class TeamsRepository {
  Future<Either<Failure, List<Team>>> getTeams({
    String? leagueId,
    String? search,
    int page = 1,
    int limit = 20,
  });
  
  Future<Either<Failure, Team>> getTeamById(String teamId);
  Future<Either<Failure, Unit>> addToFavorites(String teamId);
  Future<Either<Failure, Unit>> removeFromFavorites(String teamId);
}

// Implementation with dependency injection
class TeamsRepositoryImpl implements TeamsRepository {
  final TeamsRemoteDataSource remoteDataSource;
  final TeamsLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  TeamsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Team>>> getTeams({
    String? leagueId,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteTeams = await remoteDataSource.getTeams(
          leagueId: leagueId,
          search: search,
          page: page,
          limit: limit,
        );
        
        // Cache the results
        await localDataSource.cacheTeams(remoteTeams);
        
        return Right(remoteTeams);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final localTeams = await localDataSource.getCachedTeams();
        return Right(localTeams);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }
}
```

### Use Case Pattern

```dart
// Abstract use case base class
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

// Concrete use case implementation
class GetTeamsUseCase implements UseCase<List<Team>, GetTeamsParams> {
  final TeamsRepository repository;

  GetTeamsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Team>>> call(GetTeamsParams params) async {
    return await repository.getTeams(
      leagueId: params.leagueId,
      search: params.search,
      page: params.page,
      limit: params.limit,
    );
  }
}

// Parameters class
class GetTeamsParams extends Equatable {
  final String? leagueId;
  final String? search;
  final int page;
  final int limit;

  const GetTeamsParams({
    this.leagueId,
    this.search,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [leagueId, search, page, limit];
}
```

### Provider Pattern with Riverpod

```dart
// State management with Riverpod
class TeamsNotifier extends StateNotifier<TeamsState> {
  final GetTeamsUseCase getTeamsUseCase;
  final SearchTeamsUseCase searchTeamsUseCase;

  TeamsNotifier({
    required this.getTeamsUseCase,
    required this.searchTeamsUseCase,
  }) : super(const TeamsState.initial());

  Future<void> loadTeams({
    String? leagueId,
    bool refresh = false,
  }) async {
    if (refresh || state.teams.isEmpty) {
      state = const TeamsState.loading();
    }

    final result = await getTeamsUseCase(GetTeamsParams(
      leagueId: leagueId,
      page: refresh ? 1 : state.currentPage + 1,
    ));

    result.fold(
      (failure) => state = TeamsState.error(failure.message),
      (teams) => state = TeamsState.loaded(
        teams: refresh ? teams : [...state.teams, ...teams],
        hasReachedMax: teams.length < 20,
        currentPage: refresh ? 1 : state.currentPage + 1,
      ),
    );
  }

  Future<void> searchTeams(String query) async {
    state = const TeamsState.loading();

    final result = await searchTeamsUseCase(SearchTeamsParams(query: query));

    result.fold(
      (failure) => state = TeamsState.error(failure.message),
      (teams) => state = TeamsState.loaded(
        teams: teams,
        hasReachedMax: true,
        currentPage: 1,
      ),
    );
  }
}

// Provider definition
final teamsProvider = StateNotifierProvider<TeamsNotifier, TeamsState>((ref) {
  return TeamsNotifier(
    getTeamsUseCase: ref.watch(getTeamsUseCaseProvider),
    searchTeamsUseCase: ref.watch(searchTeamsUseCaseProvider),
  );
});
```

## 🚀 Performance Architecture

### Caching Strategy

```typescript
// Multi-level caching system
interface CacheStrategy {
  // Level 1: In-memory cache (fastest)
  memoryCache: Map<string, CacheEntry>;
  
  // Level 2: Redis cache (fast, shared)
  redisCache: RedisClient;
  
  // Level 3: Firestore cache (persistent)
  firestoreCache: FirestoreCollection;
}

class CacheService implements CacheStrategy {
  async get<T>(key: string): Promise<T | null> {
    // Try memory cache first
    const memoryResult = this.memoryCache.get(key);
    if (memoryResult && !this.isExpired(memoryResult)) {
      return memoryResult.data;
    }
    
    // Try Redis cache
    const redisResult = await this.redisCache.get(key);
    if (redisResult) {
      // Update memory cache
      this.memoryCache.set(key, {
        data: redisResult,
        expiresAt: Date.now() + this.getTTL(key)
      });
      return redisResult;
    }
    
    // Try Firestore cache
    const firestoreResult = await this.getFromFirestoreCache(key);
    if (firestoreResult) {
      // Update higher-level caches
      await this.redisCache.setex(key, this.getTTL(key), firestoreResult);
      this.memoryCache.set(key, {
        data: firestoreResult,
        expiresAt: Date.now() + this.getTTL(key)
      });
      return firestoreResult;
    }
    
    return null;
  }
}
```

### Database Optimization

```typescript
// Index optimization for Firestore queries
const firestoreIndexes = {
  // Composite indexes for common queries
  fixtures: [
    { fields: ['league_id', 'season', 'date'] },
    { fields: ['status.short', 'date'] },
    { fields: ['home_team_id', 'season', 'date'] },
    { fields: ['away_team_id', 'season', 'date'] },
  ],
  
  standings: [
    { fields: ['league_id', 'season', 'position'] },
  ],
  
  user_favorites: [
    { fields: ['user_id', 'type'] },
    { fields: ['user_id', 'type', 'created_at'] },
  ],
};

// Query optimization patterns
class QueryOptimizer {
  // Use pagination to limit result sets
  async getFixturesPaginated(leagueId: string, page: number, limit: number) {
    let query = this.db.collection('fixtures')
      .where('league_id', '==', leagueId)
      .orderBy('date', 'desc')
      .limit(limit);
    
    if (page > 1) {
      const offset = (page - 1) * limit;
      const offsetSnapshot = await this.db.collection('fixtures')
        .where('league_id', '==', leagueId)
        .orderBy('date', 'desc')
        .limit(offset)
        .get();
      
      if (!offsetSnapshot.empty) {
        const lastDoc = offsetSnapshot.docs[offsetSnapshot.docs.length - 1];
        query = query.startAfter(lastDoc);
      }
    }
    
    return await query.get();
  }
}
```

### Flutter Performance Optimization

```dart
// Widget optimization techniques
class OptimizedTeamsList extends StatelessWidget {
  final List<Team> teams;
  
  const OptimizedTeamsList({Key? key, required this.teams}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: teams.length,
      // Use itemExtent for better performance
      itemExtent: 80.0,
      itemBuilder: (context, index) {
        final team = teams[index];
        
        // Use const constructors where possible
        return const TeamListItem(
          key: ValueKey(team.id), // Stable keys for list items
          team: team,
        );
      },
    );
  }
}

// Lazy loading implementation
class LazyLoadingList<T> extends StatefulWidget {
  final Future<List<T>> Function(int page) loadMore;
  final Widget Function(T item) itemBuilder;
  
  const LazyLoadingList({
    Key? key,
    required this.loadMore,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  State<LazyLoadingList<T>> createState() => _LazyLoadingListState<T>();
}

class _LazyLoadingListState<T> extends State<LazyLoadingList<T>> {
  final List<T> _items = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadMore();
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    
    setState(() => _isLoading = true);
    
    try {
      final newItems = await widget.loadMore(_currentPage);
      
      setState(() {
        _items.addAll(newItems);
        _currentPage++;
        _hasMore = newItems.isNotEmpty;
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          _loadMore();
        }
        return false;
      },
      child: ListView.builder(
        itemCount: _items.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _items.length) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return widget.itemBuilder(_items[index]);
        },
      ),
    );
  }
}
```

## 🔒 Security Architecture

### Authentication Flow

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Flutter   │    │  Firebase   │    │   Cloud     │    │  Firestore  │
│     App     │    │    Auth     │    │ Functions   │    │  Database   │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │                   │
       │ 1. Login Request  │                   │                   │
       │──────────────────►│                   │                   │
       │                   │ 2. Validate       │                   │
       │                   │ Credentials       │                   │
       │                   │────────────────┐  │                   │
       │                   │                │  │                   │
       │                   │◄───────────────┘  │                   │
       │ 3. ID Token       │                   │                   │
       │◄──────────────────│                   │                   │
       │                   │                   │                   │
       │ 4. API Request    │                   │                   │
       │ + ID Token        │                   │                   │
       │──────────────────────────────────────►│                   │
       │                   │                   │ 5. Verify Token   │
       │                   │                   │──────────────────►│
       │                   │                   │ 6. Token Valid    │
       │                   │                   │◄──────────────────│
       │                   │                   │ 7. Check Perms    │
       │                   │                   │──────────────────►│
       │                   │                   │ 8. Permission OK  │
       │                   │                   │◄──────────────────│
       │ 9. API Response   │                   │                   │
       │◄──────────────────────────────────────│                   │
```

### Role-Based Access Control (RBAC)

```typescript
// Permission system implementation  
enum UserRole {
  USER = 'user',
  MODERATOR = 'moderator',
  ADMIN = 'admin'
}

enum Permission {
  READ_PUBLIC = 'read:public',
  READ_USER_DATA = 'read:user_data',
  WRITE_USER_DATA = 'write:user_data',
  MANAGE_TEAMS = 'manage:teams',
  MANAGE_LEAGUES = 'manage:leagues',
  MANAGE_USERS = 'manage:users',
  ADMIN_ACCESS = 'admin:access'
}

const rolePermissions: Record<UserRole, Permission[]> = {
  [UserRole.USER]: [
    Permission.READ_PUBLIC,
    Permission.READ_USER_DATA,
    Permission.WRITE_USER_DATA,
  ],
  [UserRole.MODERATOR]: [
    Permission.READ_PUBLIC,
    Permission.READ_USER_DATA,
    Permission.WRITE_USER_DATA,
    Permission.MANAGE_TEAMS,
    Permission.MANAGE_LEAGUES,
  ],
  [UserRole.ADMIN]: Object.values(Permission),
};

class AuthService {
  async checkPermission(
    userContext: UserContext,
    requiredPermission: Permission
  ): Promise<boolean> {
    const userPermissions = await this.getUserPermissions(userContext.uid);
    return userPermissions.includes(requiredPermission);
  }

  requirePermission(userContext: UserContext, permission: Permission) {
    if (!this.checkPermission(userContext, permission)) {
      throw new functions.https.HttpsError(
        'permission-denied',
        `Missing required permission: ${permission}`
      );
    }
  }
}
```

### Data Validation

```typescript
// Input validation with Zod schemas
import { z } from 'zod';

export const CreateLeagueSchema = z.object({
  api_league_id: z.number().positive(),
  name: z.string().min(1).max(100),
  country: z.string().min(1).max(50),
  logo: z.string().url(),
  flag: z.string().url(),
  season: z.number().min(2020).max(2030),
});

export const UpdateUserProfileSchema = z.object({
  display_name: z.string().min(1).max(50).optional(),
  preferences: z.object({
    theme: z.enum(['light', 'dark', 'system']).optional(),
    language: z.enum(['en', 'sk']).optional(),
    notifications: z.boolean().optional(),
  }).optional(),
});

// Validation middleware
export function validateRequest<T>(schema: z.ZodSchema<T>, data: unknown): T {
  try {
    return schema.parse(data);
  } catch (error) {
    if (error instanceof z.ZodError) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Validation failed',
        { errors: error.errors }
      );
    }
    throw error;
  }
}
```

## 📊 Monitoring and Analytics

### Application Monitoring

```typescript
// Comprehensive logging system
class Logger {
  private static instance: Logger;
  
  static getInstance(): Logger {
    if (!Logger.instance) {
      Logger.instance = new Logger();
    }
    return Logger.instance;
  }

  info(message: string, context?: Record<string, any>) {
    console.log(JSON.stringify({
      level: 'info',
      message,
      context,
      timestamp: new Date().toISOString(),
      service: 'football-stats-api',
    }));
  }

  error(message: string, error: Error, context?: Record<string, any>) {
    console.error(JSON.stringify({
      level: 'error',
      message,
      error: {
        name: error.name,
        message: error.message,
        stack: error.stack,
      },
      context,
      timestamp: new Date().toISOString(),
      service: 'football-stats-api',
    }));
  }

  performance(operation: string, duration: number, context?: Record<string, any>) {
    console.log(JSON.stringify({
      level: 'performance',
      operation,
      duration,
      context,
      timestamp: new Date().toISOString(),
      service: 'football-stats-api',
    }));
  }
}

// Performance monitoring decorator
function performanceMonitor(target: any, propertyName: string, descriptor: PropertyDescriptor) {
  const method = descriptor.value;
  
  descriptor.value = async function (...args: any[]) {
    const start = Date.now();
    const logger = Logger.getInstance();
    
    try {
      const result = await method.apply(this, args);
      const duration = Date.now() - start;
      
      logger.performance(`${target.constructor.name}.${propertyName}`, duration, {
        args: args.length,
        success: true,
      });
      
      return result;
    } catch (error) {
      const duration = Date.now() - start;
      
      logger.performance(`${target.constructor.name}.${propertyName}`, duration, {
        args: args.length,
        success: false,
        error: (error as Error).message,
      });
      
      throw error;
    }
  };
}
```

### Analytics Data Collection

```dart
// Flutter analytics implementation
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  static Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }
  
  static Future<void> logUserAction(String action, {
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(
      name: 'user_action',
      parameters: {
        'action': action,
        ...?parameters,
      },
    );
  }
  
  static Future<void> logTeamView(String teamId, String teamName) async {
    await _analytics.logEvent(
      name: 'team_view',
      parameters: {
        'team_id': teamId,
        'team_name': teamName,
      },
    );
  }
  
  static Future<void> logFavoriteAdded(String type, String entityId) async {
    await _analytics.logEvent(
      name: 'favorite_added',
      parameters: {
        'favorite_type': type,
        'entity_id': entityId,
      },
    );
  }
}

// Usage in widgets
class TeamDetailsPage extends ConsumerWidget {
  final String teamId;
  
  const TeamDetailsPage({Key? key, required this.teamId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Log screen view
    AnalyticsService.logScreenView('team_details');
    
    final teamAsync = ref.watch(teamDetailsProvider(teamId));
    
    return teamAsync.when(
      data: (team) {
        // Log team view
        AnalyticsService.logTeamView(team.id, team.name);
        
        return Scaffold(
          appBar: AppBar(title: Text(team.name)),
          body: TeamDetailsContent(team: team),
        );
      },
      loading: () => const LoadingScreen(),
      error: (error, stack) => ErrorScreen(error: error),
    );
  }
}
```

## 🔄 Testing Architecture

### Testing Strategy

```dart
// Unit testing example
class MockTeamsRepository extends Mock implements TeamsRepository {}

void main() {
  group('GetTeamsUseCase', () {
    late GetTeamsUseCase useCase;
    late MockTeamsRepository mockRepository;

    setUp(() {
      mockRepository = MockTeamsRepository();
      useCase = GetTeamsUseCase(mockRepository);
    });

    test('should get teams from repository', () async {
      // Arrange
      const tTeams = [Team(id: '1', name: 'Team 1')];
      when(() => mockRepository.getTeams(any()))
          .thenAnswer((_) async => const Right(tTeams));

      // Act
      final result = await useCase(const GetTeamsParams());

      // Assert
      expect(result, const Right(tTeams));
      verify(() => mockRepository.getTeams(any()));
      verifyNoMoreInteractions(mockRepository);
    });
  });
}

// Widget testing example
void main() {
  group('TeamCard Widget', () {
    testWidgets('should display team information', (tester) async {
      // Arrange
      const team = Team(
        id: '1',
        name: 'Manchester United',
        logo: 'https://example.com/logo.png',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TeamCard(team: team),
        ),
      );

      // Assert
      expect(find.text('Manchester United'), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });
  });
}

// Integration testing example
void main() {
  group('Teams Feature Integration', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          // Override dependencies with mocks
          teamsRepositoryProvider.overrideWithValue(MockTeamsRepository()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('should load teams when provider is watched', () async {
      // Arrange
      final mockRepository = container.read(teamsRepositoryProvider) as MockTeamsRepository;
      when(() => mockRepository.getTeams(any()))
          .thenAnswer((_) async => const Right([]));

      // Act
      final provider = container.read(teamsProvider.notifier);
      await provider.loadTeams();

      // Assert
      final state = container.read(teamsProvider);
      expect(state, isA<TeamsLoaded>());
    });
  });
}
```

### Firebase Functions Testing

```typescript
// Cloud Functions testing
import * as test from 'firebase-functions-test';
import { expect } from 'chai';

const testEnv = test();

describe('League Functions', () => {
  after(() => {
    testEnv.cleanup();
  });

  describe('getLeagues', () => {
    it('should return leagues list', async () => {
      // Mock Firestore
      const snap = testEnv.firestore.makeDocumentSnapshot(
        { name: 'Premier League', country: 'England' },
        'leagues/league1'
      );

      // Test the function
      const wrapped = testEnv.wrap(getLeagues);
      const result = await wrapped({ query: {} });

      expect(result.data).to.be.an('array');
    });
  });

  describe('createLeague', () => {
    it('should create a new league', async () => {
      const leagueData = {
        api_league_id: 39,
        name: 'Premier League',
        country: 'England',
      };

      const context = {
        auth: {
          uid: 'admin-user-id',
          token: { role: 'admin' },
        },
      };

      const wrapped = testEnv.wrap(createLeague);
      const result = await wrapped(leagueData, context);

      expect(result.data.name).to.equal('Premier League');
    });
  });
});
```

## 🚀 Deployment Architecture

### CI/CD Pipeline

```yaml
# GitHub Actions workflow
name: Deploy Football Stats

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      # Flutter tests
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
      - run: flutter pub get
      - run: flutter test
      - run: flutter analyze
      
      # Firebase Functions tests
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: cd functions && npm ci
      - run: cd functions && npm test
      - run: cd functions && npm run lint

  deploy-staging:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop'
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      # Deploy to staging
      - run: npm install -g firebase-tools
      - run: firebase use staging --token ${{ secrets.FIREBASE_TOKEN }}
      - run: firebase deploy --only functions,firestore,storage --token ${{ secrets.FIREBASE_TOKEN }}

  deploy-production:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      # Deploy to production
      - run: npm install -g firebase-tools
      - run: firebase use production --token ${{ secrets.FIREBASE_TOKEN }}
      - run: firebase deploy --only functions,firestore,storage --token ${{ secrets.FIREBASE_TOKEN }}
      
      # Deploy Flutter web
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
      - run: flutter build web --release
      - run: firebase deploy --only hosting --token ${{ secrets.FIREBASE_TOKEN }}
```

### Environment Configuration

```typescript
// Environment-specific configuration
interface EnvironmentConfig {
  projectId: string;
  apiKeys: {
    footballApi: string;
  };
  features: {
    cacheEnabled: boolean;
    rateLimitEnabled: boolean;
    analyticsEnabled: boolean;
  };
  thirdParty: {
    sentryDsn?: string;
    logLevel: 'debug' | 'info' | 'warn' | 'error';
  };
}

const environments: Record<string, EnvironmentConfig> = {
  development: {
    projectId: 'football-stats-dev',
    apiKeys: {
      footballApi: process.env.FOOTBALL_API_KEY_DEV!,
    },
    features: {
      cacheEnabled: true,
      rateLimitEnabled: false,
      analyticsEnabled: false,
    },
    thirdParty: {
      logLevel: 'debug',
    },
  },
  staging: {
    projectId: 'football-stats-staging',
    apiKeys: {
      footballApi: process.env.FOOTBALL_API_KEY_STAGING!,
    },
    features: {
      cacheEnabled: true,
      rateLimitEnabled: true,
      analyticsEnabled: true,
    },
    thirdParty: {
      sentryDsn: process.env.SENTRY_DSN_STAGING,
      logLevel: 'info',
    },
  },
  production: {
    projectId: 'football-stats-prod',
    apiKeys: {
      footballApi: process.env.FOOTBALL_API_KEY_PROD!,
    },
    features: {
      cacheEnabled: true,
      rateLimitEnabled: true,
      analyticsEnabled: true,
    },
    thirdParty: {
      sentryDsn: process.env.SENTRY_DSN_PROD,
      logLevel: 'warn',
    },
  },
};

export const config = environments[process.env.NODE_ENV || 'development'];
```

---

## 📚 Architecture Decision Records (ADRs)

### ADR-001: Choose Flutter for Mobile Development

**Status**: Accepted

**Context**: Need to develop a cross-platform mobile application with high performance and native feel.

**Decision**: Use Flutter with Dart for mobile application development.

**Consequences**:
- ✅ Single codebase for iOS, Android, and Web
- ✅ High performance with native compilation
- ✅ Rich ecosystem and Google backing
- ❌ Larger app size compared to native apps
- ❌ Learning curve for team

### ADR-002: Choose Firebase for Backend Services

**Status**: Accepted

**Context**: Need a scalable, managed backend solution with real-time capabilities.

**Decision**: Use Firebase (Firestore, Cloud Functions, Authentication) for backend services.

**Consequences**:
- ✅ Managed infrastructure and scaling
- ✅ Real-time database capabilities
- ✅ Integrated authentication and security
- ✅ Built-in analytics and monitoring
- ❌ Vendor lock-in to Google Cloud
- ❌ Limited complex query capabilities

### ADR-003: Use Riverpod for State Management

**Status**: Accepted

**Context**: Need a robust, testable state management solution for Flutter.

**Decision**: Use Riverpod for state management throughout the application.

**Consequences**:
- ✅ Excellent testability and dependency injection
- ✅ Compile-time safety and error checking
- ✅ Great developer experience with code generation
- ✅ Handles complex state dependencies well
- ❌ Learning curve for developers new to Riverpod
- ❌ More boilerplate compared to simpler solutions

### ADR-004: Implement Clean Architecture

**Status**: Accepted  

**Context**: Need maintainable, testable, and scalable application architecture.

**Decision**: Implement Clean Architecture with clear separation of layers.

**Consequences**:
- ✅ High testability and maintainability
- ✅ Clear separation of concerns
- ✅ Framework-independent business logic
- ✅ Easy to modify and extend
- ❌ More initial complexity and boilerplate
- ❌ Learning curve for team members

---

## 🔮 Future Architecture Considerations

### Planned Improvements

1. **Microservices Migration**
   - Split monolithic Cloud Functions into smaller, focused services
   - Implement proper service mesh for inter-service communication
   - Add distributed tracing and monitoring

2. **Performance Optimizations**
   - Implement GraphQL for more efficient data fetching
   - Add CDN for static assets and images
   - Implement advanced caching strategies

3. **Scalability Enhancements**
   - Add horizontal scaling for Cloud Functions
   - Implement database sharding for large datasets
   - Add load balancing and traffic distribution

4. **Security Improvements**
   - Implement OAuth 2.0 / OpenID Connect
   - Add API gateway with rate limiting and DDoS protection
   - Implement comprehensive audit logging

5. **DevOps Maturity**
   - Add comprehensive monitoring and alerting
   - Implement blue-green deployments
   - Add automated rollback capabilities
   - Implement chaos engineering practices

---

**Last Updated**: January 31, 2025  
**Architecture Version**: 1.0.0  
**Next Review**: March 31, 2025