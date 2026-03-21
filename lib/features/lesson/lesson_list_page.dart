import 'package:flutter/material.dart';
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
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final data = await LibraryService.loadBySource(e.source);
                  if (!mounted) return;
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => LessonPage(data: data)));
                },
              );
            },
          );
        },
      ),
    );
  }
}
