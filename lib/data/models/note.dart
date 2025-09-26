import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note extends HiveObject with EquatableMixin {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content; // Store Quill delta JSON

  @HiveField(3)
  List<String> tags;

  @HiveField(4)
  bool isPinned;

  @HiveField(5)
  bool isFavorite;

  @HiveField(6)
  String color; // Hex color string

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime updatedAt;

  @HiveField(9)
  DateTime? reminderDate;

  @HiveField(10)
  bool isLocked;

  @HiveField(11)
  String? userId; // For Firebase sync

  @HiveField(12)
  DateTime? lastSyncedAt; // For sync tracking

  Note({
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

  Note copyWith({
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
    return Note(
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
