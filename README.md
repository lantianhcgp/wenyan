# Wenyan Classics — 文言文学习 App (Flutter)

一个面向中文古文学习的跨平台 Flutter 应用：每日一篇、注释与译文、语法要点（通假字/词类活用/句式）、测验与复习（间隔重复）。

## 功能规划（MVP）
- 日常学习：古文原文 + 分句断句 + 注释 + 译文
- 语法要点：关键词、语法现象卡片化讲解
- 测验模式：填空/选择/判断 + 解析
- 生词本与复习：基于间隔重复（SM2 简化）
- 离线资源：本地内置若干篇目（可增量更新）

## 运行
```
flutter pub get
flutter run
```

## 目录结构
```
lib/
  main.dart
  features/
    lesson/
    review/
    settings/
assets/
  texts/
```

## 许可
MIT
