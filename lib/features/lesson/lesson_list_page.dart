import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'library_service.dart';
import 'lesson_page.dart';

class LessonListPage extends StatefulWidget {
  const LessonListPage({super.key});

  @override
  State<LessonListPage> createState() => _LessonListPageState();
}

class _LessonListPageState extends State<LessonListPage> {
  late Future<List<LibraryEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = LibraryService.listAll();
  }

  Future<void> _refresh() async {
    setState(() => _future = LibraryService.listAll());
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<LibraryEntry>>(
        future: _future,
        builder: (context, snap) {
          final items = snap.data ?? [];
          if (items.isEmpty) return const ListTile(title: Text('暂无篇目')); 
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final e = items[i];
              return ListTile(
                title: Text(e.title),
                subtitle: Text(e.author),
                onTap: () async {
                  Map<String, dynamic> data;
                  if (e.source.startsWith('asset:')) {
                    final path = e.source.substring('asset:'.length);
                    final raw = await rootBundle.loadString(path);
                    data = json.decode(raw) as Map<String, dynamic>;
                  } else {
                    // 简化：交给 LessonPage 直接读取 assets 示例；扩展时可改为接受 data
                    final raw = await rootBundle.loadString('assets/texts/sample.json');
                    data = json.decode(raw) as Map<String, dynamic>;
                  }
                  // 跳转到学习页（当前示例使用内置加载）
                  // 这里保持简单，直接 push 到 LessonPage
                  // 如需传 data，可改造 LessonPage 接受构造参数
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LessonPage()));
                },
              );
            },
          );
        },
      ),
    );
  }
}
