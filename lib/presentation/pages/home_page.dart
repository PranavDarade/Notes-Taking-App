import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../domain/entities/note_entity.dart';
import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../../services/biometric_service.dart';
import '../../core/constants/app_constants.dart';
import '../providers/notes_provider.dart';
import '../widgets/search_bar.dart' as custom;
import '../widgets/filter_chips.dart';
import '../widgets/note_card.dart';
import 'note_editor_page.dart';
import 'note_detail_page.dart';
import 'settings_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesNotifierProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final filter = ref.watch(notesFilterProvider);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                AppConstants.appName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primaryContainer,
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.sync),
                onPressed: () async {
                  await ref.read(notesNotifierProvider.notifier).refresh();
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
              ),
            ],
          ),
          
          // Search Bar
          const SliverToBoxAdapter(
            child: custom.SearchBar(),
          ),
          
          // Filter Chips
          const SliverToBoxAdapter(
            child: FilterChips(),
          ),
          
          // Pinned Notes Section
          if (searchQuery.isEmpty)
            const SliverToBoxAdapter(child: SizedBox(height: 0)),
          
          // Notes Grid
          notesAsync.when(
            data: (notes) {
              if (notes.isEmpty) {
                return SliverFillRemaining(
                  child: _buildEmptyState(),
                );
              }
              
              List<NoteEntity> displayNotes = List.of(notes);
              // Apply filter first
              switch (filter) {
                case NotesFilter.pinned:
                  displayNotes = displayNotes.where((n) => n.isPinned).toList();
                  break;
                case NotesFilter.favorites:
                  displayNotes = displayNotes.where((n) => n.isFavorite).toList();
                  break;
                case NotesFilter.locked:
                  displayNotes = displayNotes.where((n) => n.isLocked).toList();
                  break;
                case NotesFilter.recent:
                  displayNotes.sort((a,b)=> b.updatedAt.compareTo(a.updatedAt));
                  break;
                case NotesFilter.all:
                  break;
              }

              // Then apply search
              if (searchQuery.isNotEmpty) {
                displayNotes = displayNotes.where((n) {
                  final hay = (n.title + '\n' + _plainPreview(n.content)).toLowerCase();
                  return hay.contains(searchQuery.toLowerCase());
                }).toList();
              }
              
              return SliverPadding(
                padding: const EdgeInsets.all(AppConstants.padding),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childCount: displayNotes.length,
                  itemBuilder: (context, index) {
                    final note = displayNotes[index];
                    return NoteCard(
                      note: note,
                      onTap: () => _navigateToDetail(note.id),
                      onEdit: () => _navigateToEditor(note.id),
                      onDelete: () => _deleteNote(note.id),
                      onTogglePin: () => _togglePin(note.id),
                      onToggleFavorite: () => _toggleFavorite(note.id),
                    );
                  },
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: Center(
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
                      'Error loading notes',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(notesNotifierProvider.notifier).refresh();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewNote,
        icon: const Icon(Icons.add),
        label: const Text('New Note'),
      ),
    );
  }

  String _plainPreview(String content) {
    try {
      final decoded = jsonDecode(content);
      if (decoded is List) {
        final doc = quill.Document.fromJson(decoded);
        return doc.toPlainText();
      }
      return content;
    } catch (_) {
      return content;
    }
  }

  Widget _buildPinnedSection() {
    return Consumer(
      builder: (context, ref, child) {
        final pinnedNotesAsync = ref.watch(pinnedNotesProvider);
        
        return pinnedNotesAsync.when(
          data: (pinnedNotes) {
            if (pinnedNotes.isEmpty) return const SizedBox.shrink();
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.padding,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.push_pin,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Pinned Notes',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.padding,
                    ),
                    itemCount: pinnedNotes.length,
                    itemBuilder: (context, index) {
                      final note = pinnedNotes[index];
                      return Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 16),
                        child: NoteCard(
                          note: note,
                          onTap: () => _navigateToDetail(note.id),
                          onEdit: () => _navigateToEditor(note.id),
                          onDelete: () => _deleteNote(note.id),
                          onTogglePin: () => _togglePin(note.id),
                          onToggleFavorite: () => _toggleFavorite(note.id),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_add,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No notes yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first note to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createNewNote,
            icon: const Icon(Icons.add),
            label: const Text('Create Note'),
          ),
        ],
      ),
    );
  }

  void _createNewNote() async {
    final notifier = ref.read(notesNotifierProvider.notifier);
    await notifier.createNote();
    
    if (mounted) {
      // Navigate to the latest note
      final notes = ref.read(notesNotifierProvider).value ?? [];
      if (notes.isNotEmpty) {
        _navigateToEditor(notes.first.id);
      }
    }
  }

  void _navigateToDetail(String noteId) async {
    final notes = ref.read(notesNotifierProvider).value;
    final target = notes?.cast<NoteEntity?>().firstWhere((n) => n?.id == noteId, orElse: () => null);
    if (target?.isLocked == true) {
      final ok = await BiometricService().authenticate(reason: 'Unlock note');
      if (!ok) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Authentication required')));
        }
        return;
      }
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetailPage(noteId: noteId),
      ),
    );
    // Refresh notes after returning from detail
    ref.read(notesNotifierProvider.notifier).refresh();
  }

  void _navigateToEditor(String noteId) async {
    final notes = ref.read(notesNotifierProvider).value;
    final target = notes?.cast<NoteEntity?>().firstWhere((n) => n?.id == noteId, orElse: () => null);
    if (target?.isLocked == true) {
      final ok = await BiometricService().authenticate(reason: 'Unlock note');
      if (!ok) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Authentication required')));
        }
        return;
      }
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorPage(noteId: noteId),
      ),
    );
    // Refresh notes after returning from editor
    ref.read(notesNotifierProvider.notifier).refresh();
  }

  void _deleteNote(String noteId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await ref.read(notesNotifierProvider.notifier).deleteNote(noteId);
    }
  }

  void _togglePin(String noteId) async {
    await ref.read(notesNotifierProvider.notifier).togglePin(noteId);
  }

  void _toggleFavorite(String noteId) async {
    await ref.read(notesNotifierProvider.notifier).toggleFavorite(noteId);
  }
}
