---
name: github-actions
description: 创建或修改 GitHub Actions 工作流时使用。规定 action 版本必须最新、name 必须用英文。
---

# GitHub Actions 规范

## action 版本

引用的 action 一律用最新稳定版本，新增或修改前先核对官方仓库的 release tag：

```bash
gh api repos/actions/checkout/releases/latest --jq .tag_name
```

## 命名

workflow、job、step 的 `name:` 一律用英文，写成动词开头的祈使短语：

```
Checkout code / Install dependencies / Build and push images / Health check / Deploy / Report version
```

`steps.<id>` 这类标识符本就是英文，不受影响。工作流内的注释与运行时日志文案继续用中文，按标点符号规范书写。
