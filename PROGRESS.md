# Wenyan Progress

_Last updated: 2026-03-22 10:42 Asia/Shanghai_

- 当前任务：审查本地未提交 UI 改动，收敛 MD3 / Material You 视觉方向，并推进下一版 release
- 进度：90%（已开始真实切版动作：pubspec 版本号已从 0.4.0+6 提升到 0.4.3+7，下一步就是整理提交并考虑打 tag）

## Current goal

Continue iterating the app toward a more polished MD3 / Material You style, unify visual language across pages, and ship a new release when the current UI pass is stable.

## Done

- Release workflow has already been made functional and published before.
- The app has already started moving toward a more unified MD3 / expressive style.
- Theme foundation work has begun.
- Library / Review / Settings areas have already seen local in-progress changes.
- Local chat logging and task continuity improvements were set up outside the repo so work is less likely to lose context.

## In progress

- First-pass review of local uncommitted UI changes is complete.
- Theme skeleton and page-level MD3 direction look worth keeping.
- The current local patch forms a coherent first-pass visual system rather than isolated tweaks.
- Continue visual unification work across learning, quiz, review, and settings flows.
- Improve dark mode consistency.

## Next

- Finish the lesson page visual pass cleanly.
- Finish the quiz page visual pass cleanly.
- Continue polishing the full learning flow end-to-end.
- Commit a coherent visual pass.
- Push and prepare the next release if stable.

## Risks / blockers

- Flutter / Dart CLI is not available in the current environment, so local build verification is temporarily blocked here.
- The repository now includes the local helper script `scripts/update_progress.sh`, but its progress logic is still too coarse and should not be treated as the sole source of truth.
- The app version is still `0.4.0+6`, so the next release cut has not been prepared yet.
- External web search is currently not available through the default Brave-backed search tool in this environment, so case-study gathering may need to rely on alternative search routes or existing design knowledge.

## Expected output for next checkpoint

- One concrete visual-unification commit
- Updated UI consistency status by page
- Release-prep status for the next version
- A bumped app version ready for the next cut
- If feasible, a new release
