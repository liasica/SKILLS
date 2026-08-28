#!/usr/bin/env bash
# SessionStart hook：把强制指令注入上下文
# skill 名与 description 已在 skill 列表里常驻，这里只补「必须加载」这条硬要求
set -euo pipefail

read -r -d '' MSG <<'EOF' || true
<EXTREMELY_IMPORTANT>
带 liasica-skills: 前缀的 skill 是硬性规范，不是参考资料。任务命中某个 skill 的 description 所述场景时，必须先用 Skill 工具加载它再动手，有一分可能相关就加载。凭记忆作答等同于违规。
</EXTREMELY_IMPORTANT>
EOF

python3 -c '
import json, sys
print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": sys.stdin.read().strip(),
    }
}, ensure_ascii=False))
' <<< "$MSG"
