import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/note_repository.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../../data/local/hive_service.dart';
import '../../services/sync_service.dart';

// Repository Provider
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  final syncService = ref.watch(syncServiceProvider);
  return NoteRepositoryImpl(hiveService, syncService);
});

// Hive Service Provider
final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

// Sync Service Provider
final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService();
});

// Notes List Provider
final notesProvider = FutureProvider<List<NoteEntity>>((ref) async {
  final repository = ref.watch(noteRepositoryProvider);
  final result = await repository.getAllNotes();
  return result.fold(
    (error) => throw Exception(error),
    (notes) => notes,
  );
});

// Pinned Notes Provider
final pinnedNotesProvider = FutureProvider<List<NoteEntity>>((ref) async {
  final repository = ref.watch(noteRepositoryProvider);
  final result = await repository.getPinnedNotes();
  return result.fold(
    (error) => throw Exception(error),
    (notes) => notes,
  );
});

// Favorite Notes Provider
final favoriteNotesProvider = FutureProvider<List<NoteEntity>>((ref) async {
  final repository = ref.watch(noteRepositoryProvider);
  final result = await repository.getFavoriteNotes();
  return result.fold(
    (error) => throw Exception(error),
    (notes) => notes,
  );
});

// Search Provider
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<NoteEntity>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];
  
  final repository = ref.watch(noteRepositoryProvider);
  final result = await repository.searchNotes(query);
  return result.fold(
    (error) => throw Exception(error),
    (notes) => notes,
  );
});

// Note by ID Provider
final noteByIdProvider = FutureProvider.family<NoteEntity?, String>((ref, id) async {
  final repository = ref.watch(noteRepositoryProvider);
  final result = await repository.getNoteById(id);
  return result.fold(
    (error) => throw Exception(error),
    (note) => note,
  );
});

// Notes State Notifier
class NotesNotifier extends StateNotifier<AsyncValue<List<NoteEntity>>> {
  final NoteRepository _repository;

  NotesNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    state = const AsyncValue.loading();
    final result = await _repository.getAllNotes();
    state = result.fold(
      (error) => AsyncValue.error(error, StackTrace.current),
      (notes) => AsyncValue.data(notes),
    );
  }

  Future<void> createNote({
    String title = '',
    String content = '',
    List<String> tags = const [],
    String color = '#FFFFFFFF',
    DateTime? reminderDate,
  }) async {
    final note = NoteEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      tags: tags,
      color: color,
      reminderDate: reminderDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await _repository.createNote(note);
    result.fold(
      (error) => state = AsyncValue.error(error, StackTrace.current),
      (createdNote) {
        final currentNotes = state.value ?? [];
        state = AsyncValue.data([createdNote, ...currentNotes]);
      },
    );
  }

  Future<void> updateNote(NoteEntity note) async {
    final result = await _repository.updateNote(note);
    result.fold(
      (error) => state = AsyncValue.error(error, StackTrace.current),
      (updatedNote) {
        final currentNotes = state.value ?? [];
        final index = currentNotes.indexWhere((n) => n.id == updatedNote.id);
        if (index != -1) {
          final newNotes = List<NoteEntity>.from(currentNotes);
          newNotes[index] = updatedNote;
          state = AsyncValue.data(newNotes);
        }
      },
    );
  }

  Future<void> deleteNote(String id) async {
    final result = await _repository.deleteNote(id);
    result.fold(
      (error) => state = AsyncValue.error(error, StackTrace.current),
      (_) {
        final currentNotes = state.value ?? [];
        final newNotes = currentNotes.where((note) => note.id != id).toList();
        state = AsyncValue.data(newNotes);
      },
    );
  }

  Future<void> togglePin(String id) async {
    final currentNotes = state.value ?? [];
    final note = currentNotes.firstWhere((n) => n.id == id);
    final updatedNote = note.copyWith(
      isPinned: !note.isPinned,
      updatedAt: DateTime.now(),
    );
    await updateNote(updatedNote);
  }

  Future<void> toggleFavorite(String id) async {
    final currentNotes = state.value ?? [];
    final note = currentNotes.firstWhere((n) => n.id == id);
    final updatedNote = note.copyWith(
      isFavorite: !note.isFavorite,
      updatedAt: DateTime.now(),
    );
    await updateNote(updatedNote);
  }

  Future<void> refresh() async {
    await _loadNotes();
  }
}

final notesNotifierProvider = StateNotifierProvider<NotesNotifier, AsyncValue<List<NoteEntity>>>((ref) {
  final repository = ref.watch(noteRepositoryProvider);
  return NotesNotifier(repository);
});
