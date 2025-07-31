import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/repositories/auth_repository.dart';
import '../../../../shared/data/models/user_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';

// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

// Auth State Provider
final authProvider = StreamProvider<UserModel?>((ref) async* {
  final authRepository = ref.watch(authRepositoryProvider);
  
  await for (final user in authRepository.authStateChanges) {
    if (user != null) {
      try {
        final userProfile = await authRepository.getCurrentUserProfile();
        yield userProfile;
      } catch (e) {
        // If profile doesn't exist, create it
        try {
          final newProfile = await authRepository.updateUserProfile(
            UserModel(
              id: user.uid,
              email: user.email ?? '',
              displayName: user.displayName ?? '',
              photoUrl: user.photoURL,
              isEmailVerified: user.emailVerified,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              lastLoginAt: DateTime.now(),
            ),
          );
          yield newProfile;
        } catch (createError) {
          yield null;
        }
      }
    } else {
      yield null;
    }
  }
});

// Auth State Notifier for Auth Actions
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AsyncValue.loading());

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      final user = await _authRepository.signInWithEmailAndPassword(email, password);
      state = AsyncValue.data(user);
    } on AuthException catch (e) {
      state = AsyncValue.error(
        AuthFailure(message: e.message, code: e.code != null ? int.tryParse(e.code!) : null),
        StackTrace.current,
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(
        AuthFailure(message: 'Sign in failed: $e'),
        stackTrace,
      );
    }
  }

  Future<void> signUpWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      state = const AsyncValue.loading();
      final user = await _authRepository.signUpWithEmailAndPassword(
        email,
        password,
        displayName,
      );
      state = AsyncValue.data(user);
    } on AuthException catch (e) {
      state = AsyncValue.error(
        AuthFailure(message: e.message, code: e.code != null ? int.tryParse(e.code!) : null),
        StackTrace.current,
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(
        AuthFailure(message: 'Sign up failed: $e'),
        stackTrace,
      );
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      state = const AsyncValue.loading();
      final user = await _authRepository.signInWithGoogle();
      state = AsyncValue.data(user);
    } on AuthException catch (e) {
      state = AsyncValue.error(
        AuthFailure(message: e.message, code: e.code != null ? int.tryParse(e.code!) : null),
        StackTrace.current,
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(
        AuthFailure(message: 'Google sign in failed: $e'),
        stackTrace,
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(
        AuthFailure(message: 'Sign out failed: $e'),
        stackTrace,
      );
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authRepository.sendPasswordResetEmail(email);
    } on AuthException catch (e) {
      throw AuthFailure(message: e.message, code: e.code != null ? int.tryParse(e.code!) : null);
    } catch (e) {
      throw AuthFailure(message: 'Password reset failed: $e');
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _authRepository.sendEmailVerification();
    } on AuthException catch (e) {
      throw AuthFailure(message: e.message, code: e.code != null ? int.tryParse(e.code!) : null);
    } catch (e) {
      throw AuthFailure(message: 'Email verification failed: $e');
    }
  }

  Future<void> updateProfile(UserModel user) async {
    try {
      final updatedUser = await _authRepository.updateUserProfile(user);
      state = AsyncValue.data(updatedUser);
    } catch (e, stackTrace) {
      state = AsyncValue.error(
        AuthFailure(message: 'Profile update failed: $e'),
        stackTrace,
      );
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _authRepository.deleteAccount();
      state = const AsyncValue.data(null);
    } on AuthException catch (e) {
      throw AuthFailure(message: e.message, code: e.code != null ? int.tryParse(e.code!) : null);
    } catch (e) {
      throw AuthFailure(message: 'Account deletion failed: $e');
    }
  }
}

// Auth Actions Provider
final authActionsProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});

// Current User Provider
final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.whenOrNull(data: (user) => user);
});

// Is Authenticated Provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

// Is Email Verified Provider
final isEmailVerifiedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isEmailVerified ?? false;
});

// Loading State Provider
final authLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  final actionsState = ref.watch(authActionsProvider);
  return authState.isLoading || actionsState.isLoading;
});

// Auth Error Provider
final authErrorProvider = Provider<Failure?>((ref) {
  final authState = ref.watch(authProvider);
  final actionsState = ref.watch(authActionsProvider);
  
  if (authState.hasError) {
    final error = authState.error;
    if (error is Failure) return error;
    return UnknownFailure(message: error.toString());
  }
  
  if (actionsState.hasError) {
    final error = actionsState.error;
    if (error is Failure) return error;
    return UnknownFailure(message: error.toString());
  }
  
  return null;
});