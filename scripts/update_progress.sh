#!/usr/bin/env bash
set -euo pipefail

REPO="/home/botdrop/wenyan"
PROGRESS_FILE="$REPO/PROGRESS.md"
BRANCH="main"
STAMP=$(TZ=Asia/Shanghai date '+%Y-%m-%d %H:%M Asia/Shanghai')
SSH_CMD="ssh -F /home/botdrop/.ssh/config -i /home/botdrop/.ssh/id_ed25519_wenyan -o IdentitiesOnly=yes"

cd "$REPO"

STATUS_LINES=$(git status --short | wc -l | tr -d ' ')
TRACKED_MODS=$(git status --short | grep -E '^( M|M |MM|A |AM| D|D )' | wc -l | tr -d ' ' || true)
UNTRACKED=$(git status --short | grep -E '^\?\?' | wc -l | tr -d ' ' || true)
HEAD_SHA=$(git rev-parse --short HEAD)

if (( STATUS_LINES == 0 )); then
  PROGRESS_VALUE="100%（工作区干净，当前无未提交改动）"
else
  PROGRESS_VALUE="15%（未提交改动 ${STATUS_LINES} 项：已跟踪 ${TRACKED_MODS}，未跟踪 ${UNTRACKED}）"
fi

CURRENT_TASK="审查本地未提交 UI 改动，收敛 MD3 / Material You 视觉方向，并推进下一版 release"

PROGRESS_FILE="$PROGRESS_FILE" STAMP="$STAMP" CURRENT_TASK="$CURRENT_TASK" PROGRESS_VALUE="$PROGRESS_VALUE" python3 - <<'PY'
from pathlib import Path
import os
p = Path(os.environ['PROGRESS_FILE'])
text = p.read_text(encoding='utf-8')
lines = text.splitlines()
new_lines = []
for line in lines:
    if line.startswith('_Last updated: '):
        new_lines.append(f"_Last updated: {os.environ['STAMP']}_")
    elif line.startswith('- 当前任务：'):
        new_lines.append(f"- 当前任务：{os.environ['CURRENT_TASK']}")
    elif line.startswith('- 进度：'):
        new_lines.append(f"- 进度：{os.environ['PROGRESS_VALUE']}")
    else:
        new_lines.append(line)
p.write_text('\n'.join(new_lines) + '\n', encoding='utf-8')
PY

if ! git diff --quiet -- PROGRESS.md; then
  git add PROGRESS.md
  git commit -m "docs: auto-update progress status" >/dev/null 2>&1 || exit 0
  GIT_SSH_COMMAND="$SSH_CMD" git push origin "$BRANCH" >/dev/null 2>&1 || exit 0
fi

echo "updated progress at $STAMP (head=$HEAD_SHA status=$STATUS_LINES)"
