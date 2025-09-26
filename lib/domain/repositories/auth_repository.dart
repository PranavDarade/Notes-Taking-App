import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<String, UserEntity?>> getCurrentUser();
  Future<Either<String, UserEntity>> signInWithEmail(String email, String password);
  Future<Either<String, UserEntity>> signUpWithEmail(String email, String password);
  Future<Either<String, UserEntity>> signInWithGoogle();
  Future<Either<String, void>> signOut();
  Future<Either<String, void>> resetPassword(String email);
  Stream<UserEntity?> get authStateChanges;
}
