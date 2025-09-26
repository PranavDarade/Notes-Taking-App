import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/local/hive_service.dart';
import '../../data/models/note.dart';
import '../../core/constants/app_constants.dart';

class HomePageAndroid extends ConsumerStatefulWidget {
  const HomePageAndroid({super.key});

  @override
  ConsumerState<HomePageAndroid> createState() => _HomePageAndroidState();
}

class _HomePageAndroidState extends ConsumerState<HomePageAndroid> {
  final _hive = HiveService();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notes = _hive.getAllNotes();
    final filteredNotes = notes.where((note) {
      if (_searchQuery.isEmpty) return true;
      return note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             note.content.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes App'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: NotesSearchDelegate(_hive),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
          
          // Notes List
          Expanded(
            child: filteredNotes.isEmpty
                ? Center(
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
                          _searchQuery.isEmpty ? 'No notes yet' : 'No notes found',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isEmpty 
                              ? 'Create your first note to get started'
                              : 'Try a different search term',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = filteredNotes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Color(int.parse(note.color.substring(1, 7), radix: 16) + 0xFF000000),
                            child: Text(
                              note.title.isNotEmpty ? note.title[0].toUpperCase() : 'N',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            note.title.isEmpty ? 'Untitled' : note.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note.content.length > 100
                                    ? '${note.content.substring(0, 100)}...'
                                    : note.content,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  if (note.isPinned)
                                    const Icon(Icons.push_pin, size: 16, color: Colors.blue),
                                  if (note.isFavorite)
                                    const Icon(Icons.favorite, size: 16, color: Colors.red),
                                  if (note.isLocked)
                                    const Icon(Icons.lock, size: 16, color: Colors.orange),
                                  const Spacer(),
                                  Text(
                                    '${note.updatedAt.day}/${note.updatedAt.month}/${note.updatedAt.year}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) => _handleMenuAction(value, note.id),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: ListTile(
                                  leading: Icon(Icons.edit),
                                  title: Text('Edit'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              PopupMenuItem(
                                value: 'pin',
                                child: ListTile(
                                  leading: Icon(note.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
                                  title: Text(note.isPinned ? 'Unpin' : 'Pin'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              PopupMenuItem(
                                value: 'favorite',
                                child: ListTile(
                                  leading: Icon(note.isFavorite ? Icons.favorite_border : Icons.favorite),
                                  title: Text(note.isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
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
                          onTap: () => _editNote(note.id),
                        ),
                      );
                    },
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

  void _createNewNote() async {
    final id = const Uuid().v4();
    final now = DateTime.now();
    final newNote = Note(
      id: id,
      title: '',
      content: '',
      tags: [],
      createdAt: now,
      updatedAt: now,
    );
    await _hive.addNote(newNote);
    _editNote(id);
  }

  void _editNote(String noteId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorPageAndroid(noteId: noteId),
      ),
    );
    setState(() {});
  }

  void _handleMenuAction(String action, String noteId) {
    switch (action) {
      case 'edit':
        _editNote(noteId);
        break;
      case 'pin':
        _togglePin(noteId);
        break;
      case 'favorite':
        _toggleFavorite(noteId);
        break;
      case 'delete':
        _deleteNote(noteId);
        break;
    }
  }

  void _togglePin(String noteId) async {
    final note = _hive.getNoteById(noteId);
    if (note != null) {
      note.isPinned = !note.isPinned;
      await _hive.updateNote(note);
      setState(() {});
    }
  }

  void _toggleFavorite(String noteId) async {
    final note = _hive.getNoteById(noteId);
    if (note != null) {
      note.isFavorite = !note.isFavorite;
      await _hive.updateNote(note);
      setState(() {});
    }
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
      await _hive.deleteNote(noteId);
      setState(() {});
    }
  }
}

class NoteEditorPageAndroid extends StatefulWidget {
  final String noteId;
  
  const NoteEditorPageAndroid({super.key, required this.noteId});

  @override
  State<NoteEditorPageAndroid> createState() => _NoteEditorPageAndroidState();
}

class _NoteEditorPageAndroidState extends State<NoteEditorPageAndroid> {
  final _hive = HiveService();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  late Note _note;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _loadNote();
    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  void _loadNote() {
    final note = _hive.getNoteById(widget.noteId);
    if (note == null) return;
    _note = note;
    _titleController.text = note.title;
    _contentController.text = note.content;
  }

  Future<void> _save() async {
    _note.title = _titleController.text;
    _note.content = _contentController.text;
    _note.updatedAt = DateTime.now();
    await _hive.updateNote(_note);
    setState(() {
      _hasUnsavedChanges = false;
    });
  }

  Future<bool> _onWillPop() async {
    if (_hasUnsavedChanges) {
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text('Do you want to save your changes?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Discard'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        ),
      );
      
      if (shouldSave == true) {
        await _save();
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_note.title.isEmpty ? 'Untitled' : _note.title),
          actions: [
            if (_hasUnsavedChanges)
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () async {
                  await _save();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note saved!')),
                  );
                },
              ),
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () async {
                await _save();
                Navigator.pop(context);
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Note title...',
                  border: OutlineInputBorder(),
                ),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    hintText: 'Start writing...',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotesSearchDelegate extends SearchDelegate {
  final HiveService _hive;

  NotesSearchDelegate(this._hive);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final notes = _hive.getAllNotes();
    final filteredNotes = notes.where((note) {
      if (query.isEmpty) return false;
      return note.title.toLowerCase().contains(query.toLowerCase()) ||
             note.content.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filteredNotes.length,
      itemBuilder: (context, index) {
        final note = filteredNotes[index];
        return ListTile(
          title: Text(note.title.isEmpty ? 'Untitled' : note.title),
          subtitle: Text(
            note.content.length > 100
                ? '${note.content.substring(0, 100)}...'
                : note.content,
          ),
          onTap: () {
            close(context, null);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NoteEditorPageAndroid(noteId: note.id),
              ),
            );
          },
        );
      },
    );
  }
}
