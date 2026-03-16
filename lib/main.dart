import 'package:flutter/material.dart';
import 'features/lesson/lesson_list_page.dart';
import 'features/review/review_page.dart';
import 'features/settings/settings_page.dart';
import 'features/quiz/quiz_page.dart';

void main() {
  runApp(const WenyanApp());
}

class WenyanApp extends StatefulWidget {
  const WenyanApp({super.key});

  @override
  State<WenyanApp> createState() => _WenyanAppState();
}

class _WenyanAppState extends State<WenyanApp> {
  int _index = 0;
  final _pages = const [LessonListPage(), ReviewPage(), QuizPage(), SettingsPage()];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '文言文学习',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('文言文学习')),
        body: _pages[_index],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: '文库'),
            NavigationDestination(icon: Icon(Icons.repeat), label: '复习'),
            NavigationDestination(icon: Icon(Icons.quiz_outlined), label: '测验'),
            NavigationDestination(icon: Icon(Icons.settings), label: '设置'),
          ],
        ),
      ),
    );
  }
}
