import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../features/lesson/library_service.dart';

class ImportButton extends StatelessWidget {
  const ImportButton({super.key});

  Future<void> _pickAndImport(BuildContext context) async {
    final res = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    if (res != null && res.files.isNotEmpty) {
      final f = res.files.single;
      final bytes = f.bytes ?? await File(f.path!).readAsBytes();
      await LibraryService.importJson(String.fromCharCodes(bytes), filename: f.name);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('导入成功')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => _pickAndImport(context),
      icon: const Icon(Icons.file_upload),
      label: const Text('导入自定义篇目 JSON'),
    );
  }
}
