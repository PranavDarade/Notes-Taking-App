import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../services/auth_service.dart';

// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthService();
});

// Current User Provider
final currentUserProvider = StreamProvider<UserEntity?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

// Auth State Notifier
class AuthNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.loading()) {
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    final result = await _repository.getCurrentUser();
    state = result.fold(
      (error) => AsyncValue.error(error, StackTrace.current),
      (user) => AsyncValue.data(user),
    );
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    final result = await _repository.signInWithEmail(email, password);
    state = result.fold(
      (error) => AsyncValue.error(error, StackTrace.current),
      (user) => AsyncValue.data(user),
    );
  }

  Future<void> signUpWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    final result = await _repository.signUpWithEmail(email, password);
    state = result.fold(
      (error) => AsyncValue.error(error, StackTrace.current),
      (user) => AsyncValue.data(user),
    );
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    final result = await _repository.signInWithGoogle();
    state = result.fold(
      (error) => AsyncValue.error(error, StackTrace.current),
      (user) => AsyncValue.data(user),
    );
  }

  Future<void> signOut() async {
    final result = await _repository.signOut();
    result.fold(
      (error) => state = AsyncValue.error(error, StackTrace.current),
      (_) => state = const AsyncValue.data(null),
    );
  }

  Future<void> resetPassword(String email) async {
    final result = await _repository.resetPassword(email);
    result.fold(
      (error) => state = AsyncValue.error(error, StackTrace.current),
      (_) => {}, // Success - no state change needed
    );
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserEntity?>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
