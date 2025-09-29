import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dartz/dartz.dart';
import '../domain/entities/note_entity.dart';
import '../data/local/hive_service.dart';
import '../data/models/note.dart';
import '../core/constants/app_constants.dart';
import 'encryption_service.dart';

class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final HiveService _hiveService = HiveService();
  final EncryptionService _encryption = EncryptionService();

  /// Sync all notes between Hive and Firestore
  Future<Either<String, void>> syncAllNotes() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left('User not authenticated');
      }

      // Get local notes
      final localNotes = _hiveService.getAllNotes().map(_mapModelToEntity).toList();
      
      // Get remote notes
      final remoteNotes = await _getRemoteNotes(user.uid);
      
      // Merge and resolve conflicts
      await _mergeNotes(localNotes, remoteNotes, user.uid);
      
      return const Right(null);
    } catch (e) {
      return Left('Sync failed: ${e.toString()}');
    }
  }

  /// Get notes from Firestore
  Future<List<NoteEntity>> _getRemoteNotes(String userId) async {
    final snapshot = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.notesCollection)
        .get();

    return await Future.wait(snapshot.docs.map((doc) async {
      final data = doc.data();
      return NoteEntity(
        id: doc.id,
        title: data['title'] is String ? data['title'] as String : '',
        content: data['content'] is String
            ? await _encryption.decryptText(data['content'] as String)
            : '',
        tags: List<String>.from(data['tags'] ?? []),
        isPinned: data['isPinned'] ?? false,
        isFavorite: data['isFavorite'] ?? false,
        color: data['color'] ?? '#FFFFFFFF',
        createdAt: (data['createdAt'] is Timestamp)
            ? (data['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
        updatedAt: (data['updatedAt'] is Timestamp)
            ? (data['updatedAt'] as Timestamp).toDate()
            : DateTime.now(),
        reminderDate: data['reminderDate'] != null 
            ? (data['reminderDate'] as Timestamp).toDate()
            : null,
        isLocked: data['isLocked'] ?? false,
        userId: userId,
        lastSyncedAt: data['lastSyncedAt'] != null 
            ? (data['lastSyncedAt'] as Timestamp).toDate()
            : null,
      );
    }));
  }

  /// Merge local and remote notes, resolving conflicts
  Future<void> _mergeNotes(
    List<NoteEntity> localNotes,
    List<NoteEntity> remoteNotes,
    String userId,
  ) async {
    
    // Create maps for easier lookup
    final localMap = {for (var note in localNotes) note.id: note};
    final remoteMap = {for (var note in remoteNotes) note.id: note};
    
    // Process remote notes
    for (final remoteNote in remoteNotes) {
      final localNote = localMap[remoteNote.id];
      
      if (localNote == null) {
        // Remote note doesn't exist locally - add it
        await _hiveService.addNote(_mapEntityToModel(remoteNote));
      } else {
        // Both exist - resolve conflict based on lastSyncedAt
        if (remoteNote.lastSyncedAt != null && 
            (localNote.lastSyncedAt == null || 
             remoteNote.lastSyncedAt!.isAfter(localNote.lastSyncedAt!))) {
          // Remote is newer - update local
          await _hiveService.updateNote(_mapEntityToModel(remoteNote));
        } else if (localNote.lastSyncedAt != null && 
                   (remoteNote.lastSyncedAt == null || 
                    localNote.lastSyncedAt!.isAfter(remoteNote.lastSyncedAt!))) {
          // Local is newer - update remote
          await _updateRemoteNote(localNote, userId);
        }
      }
    }
    
    // Process local notes that don't exist remotely
    for (final localNote in localNotes) {
      if (!remoteMap.containsKey(localNote.id)) {
        // Local note doesn't exist remotely - upload it
        await _uploadNote(localNote, userId);
      }
    }
  }

  /// Upload a note to Firestore
  Future<void> _uploadNote(NoteEntity note, String userId) async {
    final encryptedContent = await _encryption.encryptText(note.content);
    final data = {
      'title': note.title,
      'content': encryptedContent,
      'tags': note.tags,
      'isPinned': note.isPinned,
      'isFavorite': note.isFavorite,
      'color': note.color,
      'createdAt': Timestamp.fromDate(note.createdAt),
      'updatedAt': Timestamp.fromDate(note.updatedAt),
      'reminderDate': note.reminderDate != null 
          ? Timestamp.fromDate(note.reminderDate!)
          : null,
      'isLocked': note.isLocked,
      'lastSyncedAt': Timestamp.fromDate(DateTime.now()),
    };

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.notesCollection)
        .doc(note.id)
        .set(data);
  }

  /// Update a note in Firestore
  Future<void> _updateRemoteNote(NoteEntity note, String userId) async {
    final encryptedContent = await _encryption.encryptText(note.content);
    final data = {
      'title': note.title,
      'content': encryptedContent,
      'tags': note.tags,
      'isPinned': note.isPinned,
      'isFavorite': note.isFavorite,
      'color': note.color,
      'createdAt': Timestamp.fromDate(note.createdAt),
      'updatedAt': Timestamp.fromDate(note.updatedAt),
      'reminderDate': note.reminderDate != null 
          ? Timestamp.fromDate(note.reminderDate!)
          : null,
      'isLocked': note.isLocked,
      'lastSyncedAt': Timestamp.fromDate(DateTime.now()),
    };

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.notesCollection)
        .doc(note.id)
        .set(data, SetOptions(merge: true));
  }

  /// Delete a note from Firestore
  Future<void> deleteRemoteNote(String noteId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .collection(AppConstants.notesCollection)
        .doc(noteId)
        .delete();
  }

  /// Map NoteEntity to Note model (for Hive)
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

  /// Map Note model to NoteEntity (from Hive)
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

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;
}
