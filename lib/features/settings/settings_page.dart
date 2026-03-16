import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'import_button.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _baseCtrl = TextEditingController();
  final _keyCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    _baseCtrl.text = sp.getString('dic_base') ?? '';
    _keyCtrl.text = sp.getString('dic_key') ?? '';
    setState(() {});
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('dic_base', _baseCtrl.text.trim());
    await sp.setString('dic_key', _keyCtrl.text.trim());
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已保存词典配置')));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Text('词典服务配置', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          TextField(controller: _baseCtrl, decoration: const InputDecoration(labelText: '词典 API 基础地址（支持 ?q=词&key=...）')),
          const SizedBox(height: 8),
          TextField(controller: _keyCtrl, decoration: const InputDecoration(labelText: '词典 API Key（可选）')),
          const SizedBox(height: 12),
          FilledButton(onPressed: _save, child: const Text('保存')),
          const Divider(height: 32),
          Text('数据', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const ImportButton(),
        ],
      ),
    );
  }
}
