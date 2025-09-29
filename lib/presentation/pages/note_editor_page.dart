import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import '../../data/local/hive_service.dart';
import '../../data/models/note.dart';

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

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_note.title.isEmpty ? 'Untitled' : _note.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              await _save();
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: Column(
        children: [
          quill.QuillSimpleToolbar(controller: _controller),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              child: quill.QuillEditor.basic(
                controller: _controller,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
