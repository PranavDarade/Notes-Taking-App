import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../../core/constants/app_constants.dart';
import '../providers/notes_provider.dart';
import '../widgets/note_card.dart';
import 'note_editor_page.dart';

class NoteDetailPage extends ConsumerWidget {
  final String noteId;

  const NoteDetailPage({
    super.key,
    required this.noteId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteAsync = ref.watch(noteByIdProvider(noteId));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareNote(context, noteAsync),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editNote(context, noteId),
          ),
          noteAsync.maybeWhen(
            data: (note) => IconButton(
              icon: Icon(note?.isLocked == true ? Icons.lock_open : Icons.lock_outline),
              onPressed: () => _toggleLock(ref, noteId),
              tooltip: 'Lock/Unlock',
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, ref, value, noteId),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'pin',
                child: ListTile(
                  leading: Icon(Icons.push_pin),
                  title: Text('Pin/Unpin'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'favorite',
                child: ListTile(
                  leading: Icon(Icons.favorite),
                  title: Text('Favorite/Unfavorite'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Delete', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: noteAsync.when(
        data: (note) {
          if (note == null) {
            return const Center(
              child: Text('Note not found'),
            );
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card (title only)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                note.title.isEmpty ? 'Untitled' : note.title,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (note.isFavorite) const Icon(Icons.favorite, color: Colors.red),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Content Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Content',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _getContentText(note.content),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Tags Section
                if (note.tags.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tags',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: note.tags.map((tag) {
                              return Chip(
                                label: Text(tag),
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Metadata Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Details',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          context,
                          'Created',
                          _formatDateTime(note.createdAt),
                        ),
                        _buildDetailRow(
                          context,
                          'Last Modified',
                          _formatDateTime(note.updatedAt),
                        ),
                        if (note.reminderDate != null)
                          _buildDetailRow(
                            context,
                            'Reminder',
                            _formatDateTime(note.reminderDate!),
                          ),
                        _buildDetailRow(
                          context,
                          'Status',
                          _getStatusText(note),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading note',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _getContentText(String content) {
    if (content.isEmpty) return 'No content';
    try {
      final decoded = jsonDecode(content);
      if (decoded is List) {
        final doc = quill.Document.fromJson(decoded);
        final text = doc.toPlainText().trim();
        return text.isEmpty ? 'No content' : text;
      }
      return content;
    } catch (_) {
      return content;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getStatusText(note) {
    final statuses = <String>[];
    if (note.isPinned) statuses.add('Pinned');
    if (note.isFavorite) statuses.add('Favorite');
    if (note.isLocked) statuses.add('Locked');
    return statuses.isEmpty ? 'Normal' : statuses.join(', ');
  }

  void _shareNote(BuildContext context, AsyncValue<dynamic> noteAsync) {
    noteAsync.whenData((note) {
      if (note != null) {
        Share.share(
          '${note.title}\n\n${_getContentText(note.content)}',
          subject: note.title.isEmpty ? 'Untitled Note' : note.title,
        );
      }
    });
  }

  void _editNote(BuildContext context, String noteId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorPage(noteId: noteId)),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action, String noteId) {
    switch (action) {
      case 'pin':
        _togglePin(ref, noteId);
        break;
      case 'favorite':
        _toggleFavorite(ref, noteId);
        break;
      case 'delete':
        _deleteNote(context, ref, noteId);
        break;
    }
  }

  void _togglePin(WidgetRef ref, String noteId) {
    ref.read(notesNotifierProvider.notifier).togglePin(noteId);
  }

  void _toggleFavorite(WidgetRef ref, String noteId) {
    ref.read(notesNotifierProvider.notifier).toggleFavorite(noteId);
  }

  void _toggleLock(WidgetRef ref, String noteId) {
    ref.read(notesNotifierProvider.notifier).toggleLocked(noteId);
  }

  void _deleteNote(BuildContext context, WidgetRef ref, String noteId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(notesNotifierProvider.notifier).deleteNote(noteId);
              Navigator.pop(context); // Go back to home
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
