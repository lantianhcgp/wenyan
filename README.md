# Wenyan Classics — 文言文学习 App (Flutter)

一个面向中文古文学习的跨平台 Flutter 应用：每日一篇、注释与译文、词语点击释义、测验与复习（间隔重复）。

## 功能清单（当前可用）
- 文库与导入：
  - 内置篇目索引（assets/texts/index.json）
  - 设置页一键导入自定义 JSON（写入应用数据目录 /texts）
- 日常学习：古文原文 + 注释 + 译文
- 词语点击释义：
  - 先查本地小词库
  - 再查本地 SQLite 权威词典（若已有 dictionary.db）
  - 最后可选远程 API（设置页配置 base/key）
- 生词本与复习：
  - 点击词条弹窗可“加入生词本”
  - 复习页：基于简化 SM-2 的三键复习（不认识/模糊/认识）

## 待接入（你提供词典后我会完成）
- 词典 SQLite 导入器：把你提供的词典转换为 dictionary.db（schema: entries(head TEXT PRIMARY KEY, gloss TEXT)）
- 测验模式：从篇目与词典生成选择/填空题目（可先上选择题）

## 运行
```
flutter pub get
flutter run
```

## 导入自定义篇目
设置页 -> 导入自定义篇目 JSON。
格式示例：
```json
{
  "title": "陋室铭",
  "author": "刘禹锡",
  "paragraphs": ["山不在高，有仙则名。", "水不在深，有龙则灵。"],
  "notes": ["铭：古代刻于器物或碑碣上的文字。"],
  "translation": "……"
}
```

## 词典接入
- 设置页可配置远程 API（?q=词&key=...）
- 本地权威词典：放置 dictionary.db 到应用数据目录，或打包到 assets/db/ 并在首次运行复制
  - 表结构：`entries(head TEXT PRIMARY KEY, gloss TEXT)`

## 目录结构
```
lib/
  main.dart
  features/
    lesson/                 # 学习页（词语点击释义）
    review/                 # 复习页（简化 SM-2 UI）
    settings/               # 设置页（导入篇目 + 词典配置）
assets/
  texts/
    sample.json             # 示例篇目
    index.json              # 文库索引
  db/
    dictionary.db (可选)
```

## CI/CD
- GitHub Actions：push/PR 自动 analyze/test/build；打 tag v* 自动生成 Release 并上传 APK

## 许可
MIT
