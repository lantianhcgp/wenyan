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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Text('词典服务配置', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('查询顺序：内置注释 → 本地 SQLite 词典 → 远程 API → Moedict 开放词典'),
          const SizedBox(height: 12),
          TextField(controller: _baseCtrl, decoration: const InputDecoration(labelText: '词典 API 基础地址（支持 ?q=词&key=...）')),
          const SizedBox(height: 8),
          TextField(controller: _keyCtrl, decoration: const InputDecoration(labelText: '词典 API Key（可选）')),
          const SizedBox(height: 12),
          FilledButton(onPressed: _save, child: const Text('保存')),
          const Divider(height: 32),
          Text('当前状态', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: const Text('本地词典数据库'),
            subtitle: Text(_dbReady ? '已初始化，可用于离线查词与出题' : '初始化中…'),
          ),
          ListTile(
            leading: const Icon(Icons.bookmarks_outlined),
            title: const Text('生词本'),
            subtitle: Text('当前已加入 $_reviewCount 个待复习词条'),
          ),
          const Divider(height: 32),
          Text('数据', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const ImportButton(),
          const SizedBox(height: 8),
          const DictionaryImportButton(),
        ],
      ),
    );
  }
}
