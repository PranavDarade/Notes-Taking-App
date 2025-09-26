import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../local/hive_service.dart';

class NoteRepository {
  final HiveService _hive;
  final Uuid _uuid = Uuid();

  NoteRepository(this._hive);

  List<Note> fetchNotes() => _hive.getAllNotes();

  Future<Note> createNote({String title = '', String content = ''}) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final note = Note(
      id: id,
      title: title,
      content: content,
      tags: [],
      createdAt: now,
      updatedAt: now,
    );
    await _hive.addNote(note);
    return note;
  }

  Future<void> deleteNote(String id) => _hive.deleteNote(id);

  Future<void> updateNote(Note note) async {
    note.updatedAt = DateTime.now();
    await _hive.updateNote(note);
  }
}
