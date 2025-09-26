import 'package:dartz/dartz.dart';
import '../entities/note_entity.dart';

abstract class CreateNoteUseCase {
  Future<Either<String, NoteEntity>> call({
    String title,
    String content,
    List<String> tags,
    String color,
    DateTime? reminderDate,
  });
}
