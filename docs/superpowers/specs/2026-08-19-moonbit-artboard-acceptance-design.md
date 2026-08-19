# MoonBit Artboard 验收完善设计

## 目标与边界

本轮把 `wccerty/moonbit-artboard` 完善为一个可以被其他 MoonBit 项目复用的矢量画布数据与编辑内核。交付以真实功能为中心：文档可可靠保存/恢复，空间查询可扩展，命中测试遵守世界坐标，视口和渲染计划可被多个后端复用，核心路径有边界测试和可复现基准。

本轮不实现浏览器 UI、协作协议、字体 shaping、位图解码或 PDF 排版引擎；现有 PDF 适配器继续作为轻量导出适配器，但不在 README 中夸大为完整 PDF 引擎。申报书 `OSC2026_August_Hackathon_Application.md` 是外部材料，只读，不参与源码统计，也不在 README 中描述申报过程、内部身份或验收问答。

## 可验收的结果

1. `src` 与 `cmd` 中的非测试 `.mbt` 生产代码，按仓库内统计脚本的“非空、非注释有效代码行”口径超过 8,000 行；测试代码单独统计，不混入生产数字。
2. 现有 API 保持可用；新增的可失败 JSON 解码 API 不用静默默认文档掩盖错误，旧便捷 API 保留兼容行为并在文档中说明。
3. `moon check --deny-warn`、WASM-GC 测试、格式检查、接口生成无差异和主集成示例可复现；Linux runner 额外执行 native 测试与覆盖率。
4. `cmd/bench` 使用固定输入构造真实场景，输出测量的操作数量、耗时和结果校验摘要；README 与基准记录只填写实际运行结果和运行环境。
5. README 只保留用户需要的项目定位、能力、快速开始、CLI、架构、基准、测试、CI、许可证和 API 使用示例。

## 架构

### 1. 数学与形状层

在 `src/math` 增加数值容差、线段/Bezier 最近点、折线长度、曲线 flatten 和多边形边界辅助；所有退化输入（少于三个点、零长度线段、不可逆矩阵、极小曲率）都返回稳定结果，不使用未定义的除零路径。

在 `src/shapes` 增加面向编辑器的路径采样和精确命中辅助。采样器把 `PathSegment` 转为带有误差上界的折线，命中测试先做世界包围盒粗筛，再将世界点逆变换到节点局部坐标，最后按图元类型做填充或描边判断。已有 `Path::bounds`、`Geometry::to_path` 和 SVG path API 继续复用。

### 2. 场景图层

在 `src/scenegraph` 增加：

- 确定性深度优先遍历，统一 root 与 group 子节点的绘制顺序。
- `NodeQuery` 结果结构，支持按可见性、锁定状态、节点类型和世界包围盒过滤。
- `DocumentValidationReport`，检查重复 ID、孤儿节点、父子循环、缺失子节点、无效尺寸和不一致 root 列表。
- 变换/边界相关的内部辅助，避免导出、空间索引、命中测试各自实现不同的层级语义。

验证报告是只读计算，不修改用户文档；编辑器可以先展示问题再决定如何修复。

### 3. 空间索引层

把 `src/spatial/spatial_index.mbt` 的线性数组实现扩展为可维护的 uniform grid：

- 每个 item 根据世界包围盒覆盖的 cell 坐标进入多个 bucket。
- `insert`、`remove`、`update` 维护 item 到 cell 的反向关系，避免删除时全表扫描。
- `query_rect` 只访问相交 cell，使用稳定的 NodeID 去重，并按插入序返回结果。
- `SpatialIndexStats` 暴露 item 数、bucket 数、候选数和命中数，供基准与调试使用。
- `build_from_doc` 对所有可查询节点建立索引，而不是只索引 root 节点；group 的包围盒仍可作为整体候选。

保留现有 `GridSpatialIndex` 名称和基本方法；新能力以新增方法或兼容扩展提供，减少使用者迁移成本。

### 4. 视口与渲染计划层

新增 `src/viewport` 包，定义：

- `Viewport`：世界视口尺寸、相机中心、缩放、设备像素比和最小/最大缩放限制。
- 屏幕/世界坐标双向转换、平移、以光标为中心缩放、视口矩形和可视节点查询。
- `DirtyRegion`：空区域、矩形并集、裁剪和是否需要完整重绘。
- `FrameMetrics`：索引候选数、绘制节点数、命令数和被裁剪节点数。

新增 `src/render` 包，定义后端无关的 `RenderOp`/`RenderPlan`：

- 编译器只遍历一次确定性场景图，处理 visible、locked 不影响渲染、opacity 累积、世界矩阵和 group save/restore 边界。
- 记录 shape、path、text、image、clip 和 state 操作，并为每次 plan 生成稳定统计。
- Canvas 2D 导出适配器从 render plan 转换为已有 `CanvasCommand`；SVG 导出继续生成 SVG，但复用统一遍历与转义规则。
- RenderPlan 不持有外部后端资源，因此可在 WASM、native 和测试中重复验证。

### 5. JSON 持久化层

在 `src/serialization` 增加完整 tokenizer/parser：字符串转义、Unicode 基本转义、数字、布尔、null、对象、数组、尾部输入和错误位置均有明确处理。新增 `JsonDecodeError` 与 checked API：

```text
pub fn decode_document_checked(
  json_str : String,
) -> Result[@scenegraph.ArtboardDocument, JsonDecodeError]
```

`decode_document` 保留现有返回类型作为便捷入口，内部调用 checked API；成功时恢复文档元数据、节点 ID、父子关系、变换、可见/锁定状态、图元、样式、文本和图片。失败时返回兼容的空文档，但不把该入口当作可靠校验 API。编码器输出稳定字段顺序，往返测试使用结构化属性比较而不是依赖 Map 的随机顺序。

### 6. Benchmark 与 CLI

新增 `cmd/bench` 可执行包，固定生成三档文档（小型编辑场景、中型多层场景、大型重复图层场景），依次测量：

- 文档构建与验证。
- 空间索引构建和固定矩形查询。
- 变换感知命中测试。
- JSON 编码、checked 解码与属性校验。
- RenderPlan 编译和导出命令转换。

每项输出样本规模、迭代次数、总耗时、平均耗时、结果计数和校验摘要。运行次数和输入固定，输出不伪造吞吐量；机器、OS、MoonBit 版本和命令由 `benchmarks/README.md` 记录。计时使用 `moonbitlang/core/bench` 的 `monotonic_clock_start` 与 `monotonic_clock_end` 单调时钟 API；基准命令在 native 运行，不把跨平台构建检查冒充性能数据。

## 测试策略

- 每个新增公共类型和方法先在对应包的 `*_test.mbt` 写一个能失败的行为测试，再实现最小通过版本。
- 数学测试覆盖零长度、极限参数、逆矩阵失败、曲线端点和边界切线。
- 场景图测试覆盖深层变换、循环/孤儿验证、确定性遍历和不可见/锁定节点。
- 空间测试覆盖跨多个 cell 的 item、边界相切、重复候选、更新/删除和空索引。
- 命中测试覆盖旋转矩形、Bezier path、透明/锁定节点、嵌套 group 和反向 z-order。
- 序列化测试覆盖完整节点集合、转义字符串、空数组、非法数字、截断 JSON、未知字段和错误位置。
- 视口/渲染测试覆盖 zoom 限制、光标中心缩放、dirty region 合并、opacity 累积、裁剪和稳定命令顺序。
- 保留现有 36 个测试并扩展到可解释的边界测试集合；不为了数字添加空断言。

## CI 与仓库文件

`.github/workflows/ci.yml` 改为三平台矩阵：安装最新 stable MoonBit，执行 `moon version --all`、`moon update`、`moon fmt --check`、`moon info` 后检查生成接口没有 diff、`moon check --deny-warn`、WASM-GC 测试和主示例。Ubuntu 额外执行 native check/test、coverage summary、coverage analyze 与 benchmark smoke；Windows 不强制当前已知会受 runtime `rand_s` 影响的 native 任务。工作流使用最小 `contents: read` 权限和 `persist-credentials: false`。

README 不写入任何申报、结项、核心贡献者或 GitLink 叙述。根目录 `LICENSE` 保持 Apache-2.0；新增文件不引入未知来源代码或第三方运行时依赖。

## 验证门槛

最终交付前必须重新运行并记录：

```text
moon version --all
moon fmt --check
moon check --deny-warn
moon info
git diff --exit-code -- '*.mbti'
moon test --deny-warn
moon run src/main
moon run cmd/bench --target native
```

另行运行源码统计脚本，并人工检查 `git diff --stat`、申报书哈希未变化、构建产物未被跟踪、README 中没有内部竞赛措辞。任何未能在当前 Windows 环境验证的 native 结果必须在交付报告中如实标记为环境限制。
