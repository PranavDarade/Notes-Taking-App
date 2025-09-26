import 'package:dartz/dartz.dart';

abstract class DeleteNoteUseCase {
  Future<Either<String, void>> call(String id);
}
