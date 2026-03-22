import 'package:flutter/material.dart';
import 'features/lesson/lesson_list_page.dart';
import 'features/review/review_page.dart';
import 'features/quiz/quiz_page.dart';
import 'features/settings/settings_page.dart';
import 'theme/app_theme.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

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
  final _titles = const ['文库', '复习', '测验', '设置'];
  final _subtitles = const [
    '读经典，点词即查，循序渐进。',
    '用轻量间隔重复巩固生词。',
    '从篇目与词典里出题练手感。',
    '管理词典、导入内容与偏好。',
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: '文言文学习',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 92,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_titles[_index]),
              const SizedBox(height: 4),
              Text(
                _subtitles[_index],
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: _pages[_index],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.auto_stories_rounded), label: '文库'),
            NavigationDestination(icon: Icon(Icons.history_edu_rounded), label: '复习'),
            NavigationDestination(icon: Icon(Icons.bolt_rounded), label: '测验'),
            NavigationDestination(icon: Icon(Icons.tune_rounded), label: '设置'),
          ],
        ),
      ),
    );
  }
}
