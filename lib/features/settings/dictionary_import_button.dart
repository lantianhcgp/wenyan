import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../data/dictionary_db.dart';

class DictionaryImportButton extends StatelessWidget {
  const DictionaryImportButton({super.key});

  Future<void> _pickAndImport(BuildContext context) async {
    final res = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    if (res != null && res.files.isNotEmpty) {
      final f = res.files.single;
      final bytes = f.bytes ?? (f.path != null ? await File(f.path!).readAsBytes() : null);
      if (bytes == null) return;
      final n = await DictionaryDb.importJson(String.fromCharCodes(bytes));
      if (context.mounted) {
        if (n < 0) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('导入失败，请检查 JSON 格式')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已导入词条 $n 条')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _pickAndImport(context),
      icon: const Icon(Icons.file_upload),
      label: const Text('导入词典 JSON 到本地 DB'),
    );
  }
}
