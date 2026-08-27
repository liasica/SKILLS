#!/usr/bin/env bash
# 安装 skills 与标点检查器
# skills 软链到本机探测到的每个 harness 的 skills 目录
# 检查器软链到 ~/.local/bin/check-punct，任何工具都能直接调用
# Claude Code 额外接一个 PostToolUse hook，写文件后自动检查
# 幂等，可重复执行；仓库 git pull 后无需重装
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN="${XDG_BIN_HOME:-$HOME/.local/bin}"

# harness 的 skills 目录，父目录存在才装
TARGETS=(
  "$HOME/.claude/skills"
  "$HOME/.codex/skills"
  "$HOME/.gemini/skills"
)
# 追加目标用 SKILL_TARGETS 环境变量指定，空格分隔
if [ -n "${SKILL_TARGETS:-}" ]; then
  for extra in $SKILL_TARGETS; do TARGETS+=("$extra"); done
fi

installed=0
for target in "${TARGETS[@]}"; do
  [ -d "$(dirname "$target")" ] || continue
  mkdir -p "$target"
  for dir in "$REPO"/skills/*/; do
    name="$(basename "$dir")"
    link="$target/$name"
    if [ -e "$link" ] && [ ! -L "$link" ]; then
      echo "skip  $link（同名实体目录，未覆盖）"
      continue
    fi
    ln -sfn "${dir%/}" "$link"
  done
  echo "link  $target"
  installed=$((installed + 1))
done
[ "$installed" -gt 0 ] || echo "warn  没有探测到任何 harness，用 SKILL_TARGETS 指定目录"

# 检查器，harness 无关
mkdir -p "$BIN"
chmod +x "$REPO/hooks/check-punct.py"
ln -sfn "$REPO/hooks/check-punct.py" "$BIN/check-punct"
echo "link  $BIN/check-punct"

# Claude Code 的 PostToolUse hook
if [ -d "$HOME/.claude" ]; then
  python3 - "$HOME/.claude/settings.json" "$BIN/check-punct" <<'PY'
import collections, io, json, os, sys

settings, checker = sys.argv[1], sys.argv[2]
cmd = (
    "jq -r '.tool_response.filePath // .tool_input.file_path // empty' "
    '| { read -r f; [ -n "$f" ] && %s "$f"; } 2>/dev/null; true' % checker
)
entry = collections.OrderedDict([
    ('matcher', 'Write|Edit'),
    ('hooks', [collections.OrderedDict([
        ('type', 'command'),
        ('command', cmd),
        ('timeout', 15),
        ('statusMessage', u'检查标点规范'),
    ])]),
])

if os.path.exists(settings):
    with io.open(settings, encoding='utf-8') as f:
        data = json.load(f, object_pairs_hook=collections.OrderedDict)
else:
    data = collections.OrderedDict()

post = data.setdefault('hooks', collections.OrderedDict()).setdefault('PostToolUse', [])
post[:] = [g for g in post if 'check-punct' not in json.dumps(g)]
post.append(entry)

with io.open(settings, 'w', encoding='utf-8') as f:
    f.write(json.dumps(data, ensure_ascii=False, indent=2) + '\n')
print('hook  Claude Code PostToolUse / Write|Edit')
PY
fi

echo
echo "完成。$BIN 不在 PATH 时手动加入，或直接用全路径调用 check-punct"
