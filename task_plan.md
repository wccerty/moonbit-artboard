# MoonBit Artboard 验收完善计划

## 目标

在不修改 `OSC2026_August_Hackathon_Application.md`、不推送远程仓库和不发布 Mooncakes 的前提下，把当前 `moonbit-artboard` 完善为可复现、可测试、可维护的本地验收候选版本：真实有效的 MoonBit 生产源码达到 8,000 行以上，补足核心能力与边界测试，记录真实基准数据，重写成熟开源项目 README，并补充符合当前稳定工具链的 GitHub Actions CI。

## 约束

- 申报书只读，不修改、不把内部问答或申报过程写入 README。
- 不虚报源码规模；源码统计脚本必须排除申报书、文档和构建产物，并明确生产代码与测试代码口径。
- 本轮只做本地工作；不执行 `git push`、Mooncakes 发布或 GitLink 操作。
- 遵循当前仓库的 MoonBit 包边界和 `///|` block 风格。
- 新增行为先写失败测试，再实现，再做格式、接口和全量验证。

## 阶段

- [completed] 1. 项目上下文、远程元数据、基线与竞赛自查规则
- [completed] 2. 设计确认与实现计划
- [in_progress] 3. 核心生产能力扩展与回归测试
- [pending] 4. 基准工具、真实数据与规模统计
- [pending] 5. README、CI、许可证与仓库清洁度
- [pending] 6. 全量验证、最终自查报告与本地交付

## 当前阻塞/待确认

- `firecrawl` CLI 未安装，`npx firecrawl` 因 npm 缓存权限失败；已用内置网页读取能力完成公开资料核对。
- 设计已获用户确认；实现计划已写入 `docs/superpowers/plans/2026-08-19-moonbit-artboard-acceptance.md` 并完成自审。
