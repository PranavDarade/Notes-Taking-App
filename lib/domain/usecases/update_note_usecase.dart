import 'package:dartz/dartz.dart';
import '../entities/note_entity.dart';

abstract class UpdateNoteUseCase {
  Future<Either<String, NoteEntity>> call(NoteEntity note);
}

abstract class TogglePinNoteUseCase {
  Future<Either<String, NoteEntity>> call(String noteId);
}

abstract class ToggleFavoriteNoteUseCase {
  Future<Either<String, NoteEntity>> call(String noteId);
}

abstract class LockNoteUseCase {
  Future<Either<String, NoteEntity>> call(String noteId);
}

abstract class UnlockNoteUseCase {
  Future<Either<String, NoteEntity>> call(String noteId);
}
