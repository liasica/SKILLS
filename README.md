# SKILLS

跨项目通用开发规范，做成 skill 与检查器，一键安装到 Claude Code、Codex、Gemini CLI。

## 安装

```bash
git clone git@github.com:liasica/SKILLS.git ~/projects/liasica/skills
bash ~/projects/liasica/skills/install.sh
```

安装脚本探测本机已有的 harness，把 skills 软链进各自的 `skills/` 目录，检查器软链到 `~/.local/bin/check-punct`。软链方式，`git pull` 后无需重装；脚本幂等，可重复执行。

追加其他 harness：

```bash
SKILL_TARGETS="$HOME/.foo/skills $HOME/.bar/skills" bash install.sh
```

## skills

Markdown + frontmatter，Claude Code、Codex、Gemini CLI 通用。

| skill | 触发场景 |
| --- | --- |
| `project-init` | 初始化新项目或新建 git 仓库 |
| `git-commit` | 写提交信息或 PR 描述 |
| `github-actions` | 创建或修改工作流 |
| `superpowers-output` | 使用 superpowers 能力 |

## check-punct

检查中英文标点混用、注释块尾句末标点、`→` `×` 这类非 ASCII 符号，以及工作流里的中文 `name:`。只报不改。

```bash
check-punct path/to/file.go
find . -name '*.dart' -exec check-punct {} \;
```

覆盖 `.go` `.dart` `.ts` `.tsx` `.js` `.css` 的注释，以及 `.yaml` `.sh` `.sql` `.py` 的 `#` 与 `--` 注释。反引号内、`「」` 内、`[Foo]` doc 引用、URL、`TODO:`、`//go:embed`、端口号、CSS 属性名、函数调用括号都不参与检查。误报时在该行加 `punct-ignore` 豁免。

无违规时静默退出 0；有违规时输出 JSON（`decision` 与 `reason`），便于接进 hook。Claude Code 的 PostToolUse hook 由安装脚本自动配好，写文件后立即反馈。其他 harness 没有等价机制，手动调用或接进自己的流程。

## 设计取舍

**什么该做 skill**：有明确触发场景、内容超过几行的流程。需要时加载，平时不占上下文。

**什么不该做 skill**：一两句话的规则——skill 的 description 本身就占了差不多的 token，还多一次调用。这类规则留在常驻记忆里更划算。

**什么该做检查器而非 skill**：与书写默认相反、事后不自查就发现不了的细粒度规则。中文注释结尾不加句号就是典型：写的时候极易被「中文句子写完加句号」的默认压过去。skill 只是换个地方存同一条指令，仍然靠自觉；检查器由工具强制执行。

标点规范正文仍应留在常驻记忆，因为它约束一切自然语言输出（对话、文档、提交信息），而检查器只能覆盖代码文件里的注释。两者是分工，不是重复。
