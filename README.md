# Wenyan Classics — 文言文学习 App (Flutter)

一个面向中文古文学习的跨平台 Flutter 应用：每日一篇、注释与译文、词语点击释义、测验与复习（间隔重复）。

## MVP 功能
- 文库与导入：内置高中篇目索引（assets/texts/index.json）；支持将用户 JSON 放到应用数据目录（稍后在设置页提供“导入”入口）
- 日常学习：古文原文 + 分句断句 + 注释 + 译文
- 词语点击释义：点击词弹出词条（内置小词库 + 权威词典：本地 SQLite / 远程 API）
- 测验模式：填空/选择/判断 + 解析（规划中）
- 生词本与复习：基于间隔重复（规划中）

## 运行
```
flutter pub get
flutter run
```

## 导入自定义篇目
将 JSON 文件放到 `assets/texts/`，并把文件登记到 `assets/texts/index.json`，格式示例：
```json
{
  "title": "陋室铭",
  "author": "刘禹锡",
  "paragraphs": ["山不在高，有仙则名。", "水不在深，有龙则灵。"],
  "notes": ["铭：古代刻于器物或碑碣上的文字。"],
  "translation": "……"
}
```

## 词典计划（权威来源）
- 优先考虑接入「汉典」/「教育部重编国语辞典」或开放 API（若需代理/授权，将在设置页配置密钥）
- 当前为本地示例词库（见 `LessonPage._lexicon`）

## 目录结构
```
lib/
  main.dart
  features/
    lesson/                 # 学习页（词语点击释义）
    review/                 # 复习页（占位）
    settings/               # 设置页（占位）
assets/
  texts/
    sample.json             # 示例篇目
    index.json              # 文库索引
```

## CI/CD
- GitHub Actions：push/PR 自动 analyze/test/build；打 tag v* 自动生成 Release APK

## 许可
MIT
