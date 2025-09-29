import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';
import '../../core/constants/app_constants.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(NoteAdapter());
    await Hive.openBox<Note>(AppConstants.notesBoxName);
  }

  Box<Note> _notes() => Hive.box<Note>(AppConstants.notesBoxName);

  List<Note> getAllNotes() => _notes().values.toList();

  Future<void> addNote(Note note) async {
    await _notes().put(note.id, note);
  }

  Future<void> updateNote(Note note) async {
    await _notes().put(note.id, note);
  }

  Future<void> deleteNote(String id) async {
    await _notes().delete(id);
  }

  Note? getNoteById(String id) => _notes().get(id);

  Future<void> clearAllNotes() async {
    await _notes().clear();
  }

  Future<void> close() async {
    await _notes().close();
  }
}
