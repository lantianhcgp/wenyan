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
    final scheme = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<LibraryEntry>>(
        future: _future,
        builder: (context, snap) {
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 120),
                Center(child: Text('暂无篇目')),
              ],
            );
          }
          return ListView(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('经典文库', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: scheme.onSecondaryContainer)),
                    const SizedBox(height: 8),
                    Text('从高频经典篇目开始，边读边查边测。', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSecondaryContainer.withOpacity(0.9))),
                  ],
                ),
              ),
              ...items.map((e) => Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      title: Text(e.title, style: Theme.of(context).textTheme.titleMedium),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(e.author.isEmpty ? '未署作者' : e.author),
                      ),
                      trailing: Icon(Icons.arrow_outward_rounded, color: scheme.primary),
                      onTap: () async {
                        final data = await LibraryService.loadBySource(e.source);
                        if (!mounted) return;
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => LessonPage(data: data)));
                      },
                    ),
                  )),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}
