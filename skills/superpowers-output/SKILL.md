---
name: superpowers-output
description: 使用 superpowers 能力时使用。规定设计文档、实施计划与子代理过程产物分别放在哪、哪些进版本控制。
---

# superpowers 产出存放

按生命周期分两处：

| 内容 | 位置 | 版本控制 |
| --- | --- | --- |
| 设计文档、实施计划 | `docs/superpowers/specs/`、`docs/superpowers/plans/` | 纳入 |
| 子代理 brief / report、review diff、补丁、缓存 | 项目根 `.superpowers/` | 不纳入 |

项目没有 `docs/` 就直接创建；`.superpowers/` 写进项目 `.gitignore`。

`.gitignore` 忽略一个目录后 Git 不会进入该目录，目录内的 `!` 放行规则永远不生效。要保留的文档只能放在 `.superpowers/` 之外，不能靠 `!` 从里面捞。
