import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/dictionary_db.dart';
import '../../data/review_db.dart';
import 'import_button.dart';
import 'dictionary_import_button.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _baseCtrl = TextEditingController();
  final _keyCtrl = TextEditingController();
  int _reviewCount = 0;
  bool _dbReady = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    _baseCtrl.text = sp.getString('dic_base') ?? '';
    _keyCtrl.text = sp.getString('dic_key') ?? '';
    await DictionaryDb.init();
    _reviewCount = await ReviewDb.count();
    _dbReady = true;
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('dic_base', _baseCtrl.text.trim());
    await sp.setString('dic_key', _keyCtrl.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已保存词典配置')));
    }
  }

  @override
  void dispose() {
    _baseCtrl.dispose();
    _keyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('学习设置', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: scheme.onPrimaryContainer)),
              const SizedBox(height: 8),
              Text('管理词典来源、篇目导入和本地学习数据。', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onPrimaryContainer.withOpacity(0.9))),
            ],
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('词典服务配置', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                const Text('查询顺序：内置注释 → 本地 SQLite 词典 → 远程 API → Moedict 开放词典'),
                const SizedBox(height: 16),
                TextField(controller: _baseCtrl, decoration: const InputDecoration(labelText: '词典 API 基础地址（支持 ?q=词&key=...）')),
                const SizedBox(height: 12),
                TextField(controller: _keyCtrl, decoration: const InputDecoration(labelText: '词典 API Key（可选）')),
                const SizedBox(height: 16),
                FilledButton(onPressed: _save, child: const Text('保存配置')),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('当前状态', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.storage_outlined),
                  title: const Text('本地词典数据库'),
                  subtitle: Text(_dbReady ? '已初始化，可用于离线查词与出题' : '初始化中…'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.bookmarks_outlined),
                  title: const Text('生词本'),
                  subtitle: Text('当前已加入 $_reviewCount 个待复习词条'),
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('数据导入', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                const ImportButton(),
                const SizedBox(height: 12),
                const DictionaryImportButton(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
