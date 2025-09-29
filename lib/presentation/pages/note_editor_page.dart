import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import '../../data/local/hive_service.dart';
import '../../data/models/note.dart';
import '../../services/sync_service.dart';

class NoteEditorPage extends StatefulWidget {
  final String noteId;
  const NoteEditorPage({Key? key, required this.noteId}) : super(key: key);

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  final _hive = HiveService();
  late Note _note;
  late quill.QuillController _controller;
  final TextEditingController _titleCtrl = TextEditingController();
  String _fontFamily = 'sans-serif';
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  void _loadNote() {
    final note = _hive.getNoteById(widget.noteId);
    if (note == null) return;
    _note = note;
    _titleCtrl.text = _note.title;

    try {
      final document = _buildDocumentFromContent(note.content);
      _controller = quill.QuillController(
        document: document,
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (_) {
      _controller = quill.QuillController.basic();
    }

    _isLoaded = true;
  }

  Future<void> _save() async {
    final opsJson = _controller.document.toDelta().toJson();
    _note.content = jsonEncode(opsJson);
    _note.updatedAt = DateTime.now();
    await _hive.updateNote(_note);
    // Force background sync with Firestore when signed in
    try {
      final sync = SyncService();
      if (sync.isAuthenticated) {
        await sync.syncAllNotes();
      }
    } catch (_) {}
  }

  quill.Document _buildDocumentFromContent(String contentJson) {
    if (contentJson.isEmpty) {
      return quill.Document();
    }
    final dynamic decoded = jsonDecode(contentJson);
    if (decoded is List) {
      return quill.Document.fromJson(decoded);
    }
    return quill.Document();
  }

  void _openFontPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Sans Serif'),
              onTap: () {
                setState(() => _fontFamily = 'sans-serif');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Serif'),
              onTap: () {
                setState(() => _fontFamily = 'serif');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openMoreMenu() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            ListTile(title: Text('Share (coming soon)')),
            ListTile(title: Text('Duplicate (coming soon)')),
          ],
        ),
      ),
    );
  }

  void _openFontSizePicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: const Text('Small'), onTap: () { _controller.formatSelection(quill.Attribute.fromKeyValue('size', 'small')); Navigator.pop(context); }),
            ListTile(title: const Text('Normal'), onTap: () { _controller.formatSelection(quill.Attribute.size); Navigator.pop(context); }),
            ListTile(title: const Text('Large'), onTap: () { _controller.formatSelection(quill.Attribute.fromKeyValue('size', 'large')); Navigator.pop(context); }),
            ListTile(title: const Text('Huge'), onTap: () { _controller.formatSelection(quill.Attribute.fromKeyValue('size', 'huge')); Navigator.pop(context); }),
          ],
        ),
      ),
    );
  }

  void _openTextColorPicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (final c in [Colors.white, Colors.red, Colors.green, Colors.blue, Colors.amber])
              IconButton(
                icon: Icon(Icons.circle, color: c),
                onPressed: () { _controller.formatSelection(quill.Attribute.fromKeyValue('color', '#${c.value.toRadixString(16).substring(2)}')); Navigator.pop(context); },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const SizedBox.shrink(),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _controller.undo,
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: _controller.redo,
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              await _save();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saved')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleCtrl,
                    onChanged: (v) => _note = _note.copyWith(title: v),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFamily: _fontFamily,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Title',
                      border: InputBorder.none,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '${_note.updatedAt.toLocal()} | ${_controller.document.length} characters'.split('.').first,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  child: DefaultTextStyle.merge(
                    style: TextStyle(fontFamily: _fontFamily),
                    child: quill.QuillEditor.basic(
                      controller: _controller,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(icon: const Icon(Icons.title), onPressed: _openFontPicker, tooltip: 'Font Family'),
                  IconButton(icon: const Icon(Icons.format_size), onPressed: _openFontSizePicker, tooltip: 'Font Size'),
                  IconButton(icon: const Icon(Icons.format_color_text), onPressed: _openTextColorPicker, tooltip: 'Text Color'),
                  IconButton(icon: const Icon(Icons.format_list_bulleted), onPressed: () { _controller.formatSelection(quill.Attribute.ul); }, tooltip: 'Bulleted List'),
                  IconButton(icon: const Icon(Icons.format_list_numbered), onPressed: () { _controller.formatSelection(quill.Attribute.ol); }, tooltip: 'Numbered List'),
                  IconButton(icon: const Icon(Icons.more_vert), onPressed: _openMoreMenu),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
