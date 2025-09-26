import 'package:equatable/equatable.dart';

class NoteEntity extends Equatable {
  final String id;
  final String title;
  final String content;
  final List<String> tags;
  final bool isPinned;
  final bool isFavorite;
  final String color;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? reminderDate;
  final bool isLocked;
  final String? userId;
  final DateTime? lastSyncedAt;

  const NoteEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.isFavorite = false,
    this.color = '#FFFFFFFF',
    this.reminderDate,
    this.isLocked = false,
    this.userId,
    this.lastSyncedAt,
  });

  NoteEntity copyWith({
    String? id,
    String? title,
    String? content,
    List<String>? tags,
    bool? isPinned,
    bool? isFavorite,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? reminderDate,
    bool? isLocked,
    String? userId,
    DateTime? lastSyncedAt,
  }) {
    return NoteEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
      isFavorite: isFavorite ?? this.isFavorite,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reminderDate: reminderDate ?? this.reminderDate,
      isLocked: isLocked ?? this.isLocked,
      userId: userId ?? this.userId,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        tags,
        isPinned,
        isFavorite,
        color,
        createdAt,
        updatedAt,
        reminderDate,
        isLocked,
        userId,
        lastSyncedAt,
      ];
}
