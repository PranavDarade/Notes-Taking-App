import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/note_repository.dart';
import '../local/hive_service.dart';
import '../models/note.dart';
import '../../services/sync_service.dart';

class NoteRepositoryImpl implements NoteRepository {
  final HiveService _hiveService;
  final SyncService _syncService;
  final Uuid _uuid = const Uuid();

  NoteRepositoryImpl(this._hiveService, this._syncService);

  @override
  Future<Either<String, List<NoteEntity>>> getAllNotes() async {
    try {
      final notes = _hiveService.getAllNotes();
      final entities = notes.map(_mapModelToEntity).toList();
      return Right(entities);
    } catch (e) {
      return Left('Failed to get notes: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, NoteEntity?>> getNoteById(String id) async {
    try {
      final note = _hiveService.getNoteById(id);
      if (note == null) {
        return const Right(null);
      }
      return Right(_mapModelToEntity(note));
    } catch (e) {
      return Left('Failed to get note: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<NoteEntity>>> getPinnedNotes() async {
    try {
      final notes = _hiveService.getAllNotes();
      final pinnedNotes = notes.where((note) => note.isPinned).toList();
      final entities = pinnedNotes.map(_mapModelToEntity).toList();
      return Right(entities);
    } catch (e) {
      return Left('Failed to get pinned notes: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<NoteEntity>>> getFavoriteNotes() async {
    try {
      final notes = _hiveService.getAllNotes();
      final favoriteNotes = notes.where((note) => note.isFavorite).toList();
      final entities = favoriteNotes.map(_mapModelToEntity).toList();
      return Right(entities);
    } catch (e) {
      return Left('Failed to get favorite notes: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<NoteEntity>>> searchNotes(String query) async {
    try {
      final notes = _hiveService.getAllNotes();
      final searchResults = notes.where((note) {
        final titleMatch = note.title.toLowerCase().contains(query.toLowerCase());
        final contentMatch = note.content.toLowerCase().contains(query.toLowerCase());
        final tagMatch = note.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
        return titleMatch || contentMatch || tagMatch;
      }).toList();
      final entities = searchResults.map(_mapModelToEntity).toList();
      return Right(entities);
    } catch (e) {
      return Left('Failed to search notes: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, NoteEntity>> createNote(NoteEntity noteEntity) async {
    try {
      final note = _mapEntityToModel(noteEntity);
      await _hiveService.addNote(note);
      
      // Sync with Firebase if authenticated
      if (_syncService.isAuthenticated) {
        await _syncService.syncAllNotes();
      }
      
      return Right(noteEntity);
    } catch (e) {
      return Left('Failed to create note: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, NoteEntity>> updateNote(NoteEntity noteEntity) async {
    try {
      final note = _mapEntityToModel(noteEntity);
      await _hiveService.updateNote(note);
      
      // Sync with Firebase if authenticated
      if (_syncService.isAuthenticated) {
        await _syncService.syncAllNotes();
      }
      
      return Right(noteEntity);
    } catch (e) {
      return Left('Failed to update note: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> deleteNote(String id) async {
    try {
      await _hiveService.deleteNote(id);
      
      // Delete from Firebase if authenticated
      if (_syncService.isAuthenticated) {
        await _syncService.deleteRemoteNote(id);
      }
      
      return const Right(null);
    } catch (e) {
      return Left('Failed to delete note: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> syncNotes() async {
    try {
      if (!_syncService.isAuthenticated) {
        return const Left('User not authenticated');
      }
      
      final result = await _syncService.syncAllNotes();
      return result;
    } catch (e) {
      return Left('Failed to sync notes: ${e.toString()}');
    }
  }

  NoteEntity _mapModelToEntity(Note note) {
    return NoteEntity(
      id: note.id,
      title: note.title,
      content: note.content,
      tags: note.tags,
      isPinned: note.isPinned,
      isFavorite: note.isFavorite,
      color: note.color,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
      reminderDate: note.reminderDate,
      isLocked: note.isLocked,
      userId: note.userId,
      lastSyncedAt: note.lastSyncedAt,
    );
  }

  Note _mapEntityToModel(NoteEntity entity) {
    return Note(
      id: entity.id,
      title: entity.title,
      content: entity.content,
      tags: entity.tags,
      isPinned: entity.isPinned,
      isFavorite: entity.isFavorite,
      color: entity.color,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      reminderDate: entity.reminderDate,
      isLocked: entity.isLocked,
      userId: entity.userId,
      lastSyncedAt: entity.lastSyncedAt,
    );
  }
}
