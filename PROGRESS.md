# Wenyan Progress

_Last updated: 2026-05-28 15:30 Asia/Shanghai_

- 当前任务：代码审查完成，已修复关键 bug 并完成清理，准备提交
- 进度：本轮迭代完成（已修复 10 个问题，等待 CI 验证后准备 release）

## Current goal

代码审查已完成，修复了影响稳定性、正确性和用户体验的关键问题。下一步是推送代码、等待 CI 验证，然后准备新版本发布。

## Done

- Release workflow has already been made functional and published before.
- The app has already started moving toward a more unified MD3 / expressive style.
- Theme foundation work has been completed.
- Library / Review / Settings areas have already seen local in-progress changes.
- Local chat logging and task continuity improvements were set up outside the repo so work is less likely to lose context.

### 本轮代码审查修复（2026-05-28）

| 优先级 | 问题 | 修复 |
|--------|------|------|
| 🔴 高 | segment_text.dart 异步 context 未检查 mounted | 添加 `if (!context.mounted) return` |
| 🔴 高 | SM-2 fuzzy 分支逻辑错误（interval 不变） | 重置 interval=1，降低 ease，下次复习 1 天后 |
| 🟡 中 | lesson_page.dart 硬编码跨篇目词汇 | 移除硬编码，仅加载当前篇目 JSON 注释 |
| 🟡 中 | quiz_page.dart dialog 关闭后 setState 未检查 mounted | 添加 `if (!mounted) return` |
| 🟡 中 | import_button.dart / dictionary_import_button.dart 文件路径 null 安全 | 空值检查，提前 return |
| 🟡 中 | dictionary_db.dart importJson 异常静默吞掉 | 返回 -1 错误码，UI 显示错误提示 |
| 🟢 低 | models.dart 未使用的 Token 类 | 删除 |
| 🟢 低 | main.dart 未使用的 appNavigatorKey | 删除 |
| 🟢 低 | review_page.dart 无法区分「从未添加」和「复习完成」 | 新增 hasAnyItems() 方法，显示不同提示 |

## In progress

- First-pass review of local uncommitted UI changes is complete.
- Theme skeleton and page-level MD3 direction look worth keeping.
- The current local patch forms a coherent first-pass visual system rather than isolated tweaks.
- Continue visual unification work across learning, quiz, review, and settings flows.
- Improve dark mode consistency.

## Next

- 推送代码并等待 GitHub Actions CI 验证
- 完成课程页面视觉打磨
- 完成测验页面视觉打磨
- 继续打磨学习流程端到端体验
- 准备下一个版本发布

## Risks / blockers

- Flutter / Dart CLI is not available in the current environment, so local build verification is temporarily blocked here.
- The repository now includes the local helper script `scripts/update_progress.sh`, but its progress logic is still too coarse and should not be treated as the sole source of truth.
- External web search is currently not available through the default Brave-backed search tool in this environment, so case-study gathering may need to rely on alternative search routes or existing design knowledge.

## Expected output for next checkpoint

- 代码推送并触发 CI
- 课程页和测验页的视觉打磨
- 一个 coherent visual pass commit
- 准备下一个版本发布
