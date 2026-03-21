# Wenyan Classics — 文言文学习 App (Flutter)

一个面向中文古文学习的跨平台 Flutter 应用：每日一篇、注释与译文、词语点击释义、测验与复习（间隔重复）。

## 功能清单（当前可用）
- 文库与导入：
  - 内置篇目索引（assets/texts/index.json）
  - 设置页一键导入自定义 JSON（写入应用数据目录 /texts）
- 日常学习：古文原文 + 注释 + 译文
- 词语点击释义：
  - 先查当前篇目内置注释
  - 再查本地 SQLite 词典
  - 再查可选远程 API
  - 最后兜底 Moedict 开放词典
- 生词本与复习：
  - 点击词条弹窗可“加入生词本”
  - 复习页：基于简化 SM-2 的三键复习（不认识/模糊/认识）
- 测验：
  - 本篇测验：基于篇目内容、注释、标题作者生成题目
  - 词典测验：基于本地词典随机抽题
- 设置页：
  - 词典 API 配置
  - 查看本地词典与生词本状态
  - 导入篇目与词典 JSON

## 运行
```bash
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
- 词典 JSON 本地导入（设置页）：支持数组或键值映射两种格式，自动写入 SQLite

## 推荐数据准备
- 课文 JSON：补充 notes / translation 后，本篇测验质量会明显提升
- 词典 JSON / SQLite：建议至少导入几千条文言或古汉语词条，词典测验体验会更稳定

## 目录结构
```text
lib/
  main.dart
  features/
    lesson/                 # 学习页（词语点击释义 + 本篇测验入口）
    review/                 # 复习页（简化 SM-2 UI）
    settings/               # 设置页（导入篇目 + 词典配置/导入）
    quiz/                   # 测验页（本篇题 / 词典题）
assets/
  texts/
    sample.json             # 示例篇目
    index.json              # 文库索引
  db/
    dictionary.db (可选)
```

## CI/CD
- GitHub Actions：push/PR 自动 analyze/test/build
- 打 tag `v*` 自动生成 Release 并上传 APK/AAB

## 许可
MIT
