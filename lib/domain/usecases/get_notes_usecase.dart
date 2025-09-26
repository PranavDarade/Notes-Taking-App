import 'package:dartz/dartz.dart';
import '../entities/note_entity.dart';

abstract class GetNotesUseCase {
  Future<Either<String, List<NoteEntity>>> call();
}

abstract class GetNoteByIdUseCase {
  Future<Either<String, NoteEntity?>> call(String id);
}

abstract class GetPinnedNotesUseCase {
  Future<Either<String, List<NoteEntity>>> call();
}

abstract class GetFavoriteNotesUseCase {
  Future<Either<String, List<NoteEntity>>> call();
}

abstract class SearchNotesUseCase {
  Future<Either<String, List<NoteEntity>>> call(String query);
}
