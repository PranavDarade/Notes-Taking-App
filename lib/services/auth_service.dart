import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/entities/user_entity.dart';
import '../domain/repositories/auth_repository.dart';

class AuthService implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<Either<String, UserEntity?>> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Right(null);
      }
      return Right(_mapFirebaseUserToEntity(user));
    } catch (e) {
      return Left('Failed to get current user: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, UserEntity>> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        return const Left('Sign in failed');
      }
      return Right(_mapFirebaseUserToEntity(credential.user!));
    } on FirebaseAuthException catch (e) {
      return Left('Sign in failed: ${e.message}');
    } catch (e) {
      return Left('Sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, UserEntity>> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        return const Left('Sign up failed');
      }
      return Right(_mapFirebaseUserToEntity(credential.user!));
    } on FirebaseAuthException catch (e) {
      return Left('Sign up failed: ${e.message}');
    } catch (e) {
      return Left('Sign up failed: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, UserEntity>> signInWithGoogle() async {
    // TODO: Implement Google Sign-In when google_sign_in package is added
    return const Left('Google Sign-In not implemented yet');
  }

  @override
  Future<Either<String, void>> signOut() async {
    try {
      await _auth.signOut();
      return const Right(null);
    } catch (e) {
      return Left('Sign out failed: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left('Password reset failed: ${e.message}');
    } catch (e) {
      return Left('Password reset failed: ${e.toString()}');
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;
      return _mapFirebaseUserToEntity(user);
    });
  }

  UserEntity _mapFirebaseUserToEntity(User user) {
    return UserEntity(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: user.metadata.lastSignInTime ?? DateTime.now(),
    );
  }
}
