import 'package:dartz/dartz.dart';
import '../entities/note_entity.dart';

abstract class NoteRepository {
  Future<Either<String, List<NoteEntity>>> getAllNotes();
  Future<Either<String, NoteEntity?>> getNoteById(String id);
  Future<Either<String, List<NoteEntity>>> getPinnedNotes();
  Future<Either<String, List<NoteEntity>>> getFavoriteNotes();
  Future<Either<String, List<NoteEntity>>> searchNotes(String query);
  Future<Either<String, NoteEntity>> createNote(NoteEntity note);
  Future<Either<String, NoteEntity>> updateNote(NoteEntity note);
  Future<Either<String, void>> deleteNote(String id);
  Future<Either<String, void>> syncNotes();
}
