# Findings

## 基线（2026-08-19）

- 工作目录：`D:\韦成昌初审2`。
- 分支：`main`，工作树在初始检查时干净；本地跟踪 `origin/main`。
- `origin` 指向用户给定的 GitHub 仓库；远端符号 HEAD 指向 `refs/heads/main`，但本轮不推送。
- `moon version --all`：`moon 0.1.20260814`，`moonc v0.10.8+8606a5800`，本地已达到外部自查规则提到的 0.10.7 以上建议线。
- 生产与测试文件共 52 个 `.mbt`，当前按物理行统计 4,948 行；`moon test` 为 36/36 通过。
- `moon check --deny-warn`、`moon fmt --check`、`moon test --deny-warn` 通过。
- `moon run src/main` 通过并输出集成演示结果。
- `moon test --deny-warn --target native` 在当前 Windows 环境失败，错误来自 MoonBit runtime `env.c` 的 `rand_s` 隐式声明；不能把它表述成项目自身 native 逻辑通过。

## 现有结构

- `src/math`：向量、矩阵、Bezier、边界、三角剖分、样条。
- `src/shapes`：颜色、样式、图元、路径、文字、渐变、布尔路径。
- `src/scenegraph`：节点、文档、层、约束、自动布局、组件。
- `src/spatial`：命中测试与空间索引。
- `src/selection`、`src/history`、`src/tools`：编辑交互状态。
- `src/serialization`、`src/export`：JSON/SVG/Canvas/PDF/代码导出。
- `src/main`：集成演示。
- `cmd/main`：当前是空模板式可执行包。

## 已发现的功能风险

- `src/serialization/decoder.mbt` 当前基本只读取标题并返回空文档，不能兑现 JSON 往返能力。
- `src/spatial/spatial_index.mbt` 的 `GridSpatialIndex` 当前是线性数组扫描，不是真正的网格桶索引。
- `src/spatial/hit_test.mbt` 对形状主要使用局部包围盒，未完整处理世界变换、精确路径和绘制顺序。
- README 中写有 5,713 行、36 测试及 OSC/申报人/GitLink 内部表述；当前实际源码行数为 4,948，需改为可复现统计。
- 现有 CI 只有 Ubuntu，未执行 `moon check --deny-warn`、`--target all`、覆盖率摘要或接口无差异验证；Windows native 不应照搬为必过门槛。
- `gitlink` 本地 remote URL 曾包含内嵌认证信息；输出中不重复敏感内容。需要在最终安全检查中决定是否只清理本地 remote 配置并提醒轮换凭据，不触碰 GitLink 仓库。

## 外部自查规则要点

- `osc2026-guide` 要求验收模式重点检查：MoonBit 主实现、README、可运行示例、CI、测试、Mooncakes、OSI 许可证、仓库清洁度、提交历史、默认分支和真实源码规模。
- 八月黑客松只检查 GitHub 提交材料，不需要 GitLink；申报书应保持为外部材料，不纳入 README 内部问答。
- 官方/社区 CI 参考包括 `moon version --all`、`moon update`、`moon check --target all`、`moon test --target all`、`moon fmt` 与 `moon info` 后检查工作树无生成差异；示例项目还覆盖三平台，并在可行平台做 native 测试。

