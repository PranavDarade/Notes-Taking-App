import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:intl/intl.dart';
import '../../domain/entities/note_entity.dart';
import '../../core/constants/app_constants.dart';

class NoteCard extends ConsumerWidget {
  final NoteEntity note;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTogglePin;
  final VoidCallback? onToggleFavorite;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onTogglePin,
    this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final String hex = note.color.isNotEmpty ? note.color : '#FFFFFFFF';
    final int parsed = int.tryParse(hex.replaceFirst('#', '0xFF')) ?? 0xFFFFFFFF;
    final color = Color(parsed);
    
    return Slidable(
      key: ValueKey(note.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          if (onTogglePin != null)
            SlidableAction(
              onPressed: (_) => onTogglePin!(),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: note.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
              label: note.isPinned ? 'Unpin' : 'Pin',
            ),
          if (onToggleFavorite != null)
            SlidableAction(
              onPressed: (_) => onToggleFavorite!(),
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              icon: note.isFavorite ? Icons.favorite : Icons.favorite_border,
              label: note.isFavorite ? 'Unfavorite' : 'Favorite',
            ),
          if (onEdit != null)
            SlidableAction(
              onPressed: (_) => onEdit!(),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
            ),
          if (onDelete != null)
            SlidableAction(
              onPressed: (_) => onDelete!(),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
        ],
      ),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.9), color.withOpacity(0.4)],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppConstants.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                // Header with title and actions
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        note.title.isEmpty ? 'Untitled' : note.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (note.isPinned)
                      Icon(
                        Icons.push_pin,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    if (note.isFavorite)
                      Icon(
                        Icons.favorite,
                        size: 16,
                        color: Colors.red,
                      ),
                    if (note.isLocked)
                      Icon(
                        Icons.lock,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Content preview
                if (note.content.isNotEmpty)
                  Text(
                    _getContentPreview(note.content),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                
                const SizedBox(height: 12),
                
                // Tags
                if (note.tags.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: note.tags.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tag,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                
                const SizedBox(height: 8),
                
                // Footer with date and reminder
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM dd, yyyy').format(note.updatedAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    if (note.reminderDate != null)
                      Icon(
                        Icons.notifications,
                        size: 14,
                        color: Colors.orange,
                      ),
                  ],
                ),
                    ],
                  ),
                ),
              ],
          ),
        ),
      ),
    );
  }

  String _getContentPreview(String content) {
    if (content.isEmpty) return '';
    try {
      final decoded = jsonDecode(content);
      if (decoded is List) {
        final doc = quill.Document.fromJson(decoded);
        final text = doc.toPlainText().trim();
        return text.length > 100 ? '${text.substring(0, 100)}...' : text;
      }
      return content.length > 100 ? '${content.substring(0, 100)}...' : content;
    } catch (_) {
      return content.length > 100 ? '${content.substring(0, 100)}...' : content;
    }
  }
}
