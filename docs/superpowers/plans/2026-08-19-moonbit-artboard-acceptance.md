# MoonBit Artboard Acceptance Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` to implement this plan task-by-task with verification checkpoints.

**Goal:** Turn the existing MoonBit vector-artboard kernel into a reproducible, production-usable acceptance candidate with complete persistence, real spatial querying, transform-aware geometry, viewport/render planning, boundary tests, measured benchmarks, mature documentation, and current-toolchain CI.

**Architecture:** Preserve the existing package boundaries and add focused `viewport` and `render` packages. Centralize scene traversal and world-transform semantics in `scenegraph`; consume those semantics from spatial indexing, hit testing, persistence validation, and backend adapters. Keep the old public convenience APIs working while adding checked APIs for operations that can fail.

**Tech Stack:** MoonBit stable toolchain `moon 0.1.20260814` / `moonc v0.10.8+8606a5800` at planning time, WASM-GC as the default target, native only for benchmark and Linux CI timing, `moonbitlang/core/bench` monotonic clock, GitHub Actions, PowerShell line-count utility, Apache-2.0.

## Global Constraints

- Never modify `OSC2026_August_Hackathon_Application.md`.
- Do not push GitHub, touch GitLink, publish Mooncakes, or change remote repository state in this implementation session.
- New production behavior is written test-first: create a failing behavior test, run it, implement the smallest passing behavior, then refactor while green.
- Count source honestly: production statistics include only non-empty, non-comment lines in non-test `.mbt` files under `src` and `cmd`; `*_test.mbt` files, Markdown, workflow YAML, generated `.mbti`, `_build`, and proposal files are reported separately.
- Keep all MoonBit blocks separated by `///|`, use package-local files with one responsibility, and regenerate `.mbti` only with `moon info`.
- Do not use third-party runtime dependencies or copy code with unknown provenance.
- Every milestone ends with `moon fmt`, `moon check --deny-warn`, targeted tests, and a recorded result in `progress.md`.

---

### Task 1: Add shared numeric tolerance and projection primitives

**Files:**
- Create: `src/math/numeric.mbt`
- Create: `src/math/geometry_distance.mbt`
- Test: `src/math/numeric_test.mbt`
- Modify: `src/math/moon.pkg` only if the implementation needs a new core import.

**Interfaces:**
- Consumes: existing `Vec2`, `Rect2D`, `Matrix2D` and `moonbitlang/core/math` alias `@cmath`.
- Produces: tolerance helpers used by path flattening, hit testing, validation, and viewport clamping.

```mbt
pub fn nearly_equal(left : Double, right : Double, tolerance : Double) -> Bool
pub fn clamp_double(value : Double, minimum : Double, maximum : Double) -> Double
pub fn signed_area(points : Array[Vec2]) -> Double

pub(all) struct SegmentProjection {
  point : Vec2
  parameter : Double
  distance_squared : Double
} derive(Eq, Debug)

pub fn project_point_to_segment(
  point : Vec2,
  start : Vec2,
  end : Vec2,
) -> SegmentProjection
pub fn distance_squared_to_segment(
  point : Vec2,
  start : Vec2,
  end : Vec2,
) -> Double
```

- [ ] **Step 1: Write the failing tests.** Add tests for equal values within/outside tolerance, reversed clamp bounds, clockwise/counter-clockwise area, a projection onto an ordinary segment, and a zero-length segment.

```mbt
test "projection handles a zero length segment" {
  let result = project_point_to_segment(
    Vec2::new(4.0, 3.0),
    Vec2::new(1.0, 1.0),
    Vec2::new(1.0, 1.0),
  )
  assert_eq(result.point, Vec2::new(1.0, 1.0))
  assert_eq(result.parameter, 0.0)
  assert_true(result.distance_squared > 12.0)
}
```

- [ ] **Step 2: Run the focused test to verify RED.** Run `moon test src/math --filter 'projection handles a zero length segment'`. Expected: the test fails because the new projection symbol does not exist.
- [ ] **Step 3: Implement the minimal functions.** Use a clamped dot-product parameter; when the segment length squared is below `1e-24`, return the start point and parameter `0.0`. Keep the tolerance argument explicit so callers choose the precision appropriate to screen or world units.
- [ ] **Step 4: Run the focused test to verify GREEN.** Run `moon test src/math --filter 'projection|tolerance|area'`. Expected: all new math tests pass.
- [ ] **Step 5: Run package validation.** Run `moon fmt`, `moon check --deny-warn`, and `moon test src/math --deny-warn`. Expected: exit code 0 and no warnings.

### Task 2: Implement curve flattening and precise path hit primitives

**Files:**
- Create: `src/math/bezier_flatten.mbt`
- Create: `src/shapes/path_flatten.mbt`
- Create: `src/shapes/path_hit.mbt`
- Test: `src/math/bezier_flatten_test.mbt`
- Test: `src/shapes/path_geometry_test.mbt`

**Interfaces:**
- Consumes: `CubicBezier`, `QuadraticBezier`, `PathSegment`, `Path`, `ShapeGeometry`, and Task 1 projection/area helpers.
- Produces: deterministic polylines and fill/stroke hit primitives for scenegraph and spatial packages.

```mbt
pub fn flatten_cubic(
  curve : CubicBezier,
  tolerance : Double,
  max_depth : Int,
) -> Array[Vec2]
pub fn flatten_quadratic(
  curve : QuadraticBezier,
  tolerance : Double,
  max_depth : Int,
) -> Array[Vec2]
pub fn flatten_path(
  path : Path,
  tolerance : Double,
  max_segments : Int,
) -> Array[Array[Vec2]]
pub fn path_contains_point(
  path : Path,
  point : Vec2,
  tolerance : Double,
) -> Bool
pub fn path_distance_to_point(
  path : Path,
  point : Vec2,
  tolerance : Double,
) -> Double
pub fn geometry_contains_point(
  geometry : ShapeGeometry,
  point : Vec2,
  tolerance : Double,
) -> Bool
```

- [ ] **Step 1: Write failing tests.** Cover cubic endpoint preservation, tolerance producing no fewer than two points, quadratic flattening, a path with two subpaths, a closed rectangle containing an interior point but not an exterior point, a line stroke distance, and an arc with zero radii.
- [ ] **Step 2: Run the focused tests to verify RED.** Run `moon test src/math --filter 'flatten'` and `moon test src/shapes --filter 'path geometry'`. Expected: missing-symbol failures.
- [ ] **Step 3: Implement adaptive subdivision.** Use the distance of control points from the chord as the flatness criterion, recurse until the criterion is within tolerance or `max_depth` is reached, and append each segment endpoint exactly once. Convert quadratic curves to cubic curves through the existing `to_cubic` API. Approximate `ArcTo` with a bounded angular subdivision and treat zero/negative radii as a straight line to the endpoint.
- [ ] **Step 4: Implement subpath winding and stroke distance.** Preserve current-point/subpath-start state, close a subpath when `Close` appears, use signed crossings for fill containment, and return the minimum segment distance for stroke hit tests. An open path must never report a fill hit.
- [ ] **Step 5: Run focused tests to verify GREEN.** Run `moon test src/math --filter 'flatten'` and `moon test src/shapes --filter 'path geometry'`. Expected: all new tests pass.
- [ ] **Step 6: Validate both packages.** Run `moon fmt`, `moon check --deny-warn`, `moon test src/math --deny-warn`, and `moon test src/shapes --deny-warn`.

### Task 3: Centralize scenegraph traversal and document validation

**Files:**
- Create: `src/scenegraph/traversal.mbt`
- Create: `src/scenegraph/validation.mbt`
- Test: `src/scenegraph/traversal_test.mbt`
- Test: `src/scenegraph/validation_test.mbt`

**Interfaces:**
- Consumes: `ArtboardDocument`, `Node`, existing `get_world_matrix`/`get_world_bounds`, and `ShapeGeometry` bounds.
- Produces: one deterministic traversal used by spatial indexing, render planning, exporters, and validation.

```mbt
pub(all) struct TraversalEntry {
  id : NodeID
  parent_id : NodeID?
  world_transform : @math.Matrix2D
  world_bounds : @math.Rect2D
  depth : Int
  inherited_opacity : Double
} derive(Debug)

pub fn ArtboardDocument::traverse(self : ArtboardDocument) -> Array[TraversalEntry]

pub(all) enum ValidationIssue {
  DuplicateNodeId(String)
  MissingParent(NodeID)
  MissingChild(NodeID, NodeID)
  ParentCycle(NodeID)
  OrphanNode(NodeID)
  InvalidDimension(NodeID)
  RootMismatch(NodeID)
} derive(Eq, Debug)

pub(all) struct DocumentValidationReport {
  valid : Bool
  issues : Array[ValidationIssue]
} derive(Eq, Debug)

pub fn ArtboardDocument::validate(self : ArtboardDocument) -> DocumentValidationReport
```

- [ ] **Step 1: Write failing tests.** Assert pre-order traversal for a root group and two children, accumulated opacity across two levels, a missing child issue, an orphan node issue, a parent cycle issue, invalid dimensions, and a valid document with no issues.
- [ ] **Step 2: Run the focused tests to verify RED.** Run `moon test src/scenegraph --filter 'traversal|validation'`. Expected: missing-symbol failures.
- [ ] **Step 3: Implement traversal.** Walk `root_ids` in stored order, recurse through group child arrays, compute world matrix by multiplying parent and local matrices, compute world bounds for each entry, and carry opacity as `parent_opacity * node.opacity` clamped to `[0.0, 1.0]`. Add a visited map keyed by `NodeID.value` so malformed cycles cannot recurse forever.
- [ ] **Step 4: Implement validation.** Build parent/child references from both node fields and group arrays, run DFS color states for cycles, check root membership, dimensions, and referenced IDs, and return all issues without mutating the document.
- [ ] **Step 5: Run focused tests to verify GREEN.** Run `moon test src/scenegraph --filter 'traversal|validation'`.
- [ ] **Step 6: Validate package and generated interface.** Run `moon fmt`, `moon check --deny-warn`, `moon test src/scenegraph --deny-warn`, then `moon info` and review the expected `pkg.generated.mbti` additions.

### Task 4: Replace the linear spatial index with a real uniform grid

**Files:**
- Modify: `src/spatial/spatial_index.mbt`
- Create: `src/spatial/grid_cells.mbt`
- Modify: `src/spatial/hit_test.mbt`
- Test: `src/spatial/spatial_index_test.mbt`
- Test: `src/spatial/hit_test_boundary_test.mbt`

**Interfaces:**
- Consumes: Task 2 path/geometry hit primitives, Task 3 `TraversalEntry`, `NodeID`, `Rect2D`.
- Produces: backward-compatible `GridSpatialIndex` plus mutable update/remove/statistics APIs.

```mbt
pub(all) struct SpatialIndexStats {
  item_count : Int
  bucket_count : Int
  candidate_count : Int
  hit_count : Int
} derive(Eq, Debug)

pub fn GridSpatialIndex::remove(
  self : GridSpatialIndex,
  id : @scenegraph.NodeID,
) -> Bool
pub fn GridSpatialIndex::update(
  self : GridSpatialIndex,
  id : @scenegraph.NodeID,
  bounds : @math.Rect2D,
) -> Bool
pub fn GridSpatialIndex::query_rect_with_stats(
  self : GridSpatialIndex,
  query : @math.Rect2D,
) -> (Array[@scenegraph.NodeID], SpatialIndexStats)
pub fn GridSpatialIndex::stats(self : GridSpatialIndex) -> SpatialIndexStats
```

- [ ] **Step 1: Write failing tests.** Add tests for an item in one cell, an item spanning four cells, boundary-touching queries, duplicate candidates caused by multiple cells, update moving an item, remove, empty query, and `build_from_doc` indexing child shapes.
- [ ] **Step 2: Run the focused tests to verify RED.** Run `moon test src/spatial --filter 'grid|update|remove|boundary'`. Expected: missing methods or incorrect linear-index behavior fails.
- [ ] **Step 3: Implement cell keys and reverse membership.** Convert floor-divided cell coordinates to a stable string key, store `Map[String, Array[NodeID]]` buckets, store each item’s bounds and covered keys, and remove an ID from all previous buckets before update. A non-positive cell size is normalized to `1.0`.
- [ ] **Step 4: Implement query deduplication and statistics.** Visit every cell overlapped by the query, deduplicate NodeIDs with a temporary map, then filter candidates with exact `Rect2D.intersects`. Preserve insertion order using the item array and report candidate/hit counts.
- [ ] **Step 5: Make document hit testing transform-aware.** Search the traversal result in reverse draw order, reject invisible/locked nodes, use world bounds for coarse filtering, inverse-transform the query point into local coordinates, and call exact geometry/path hit functions. Return the topmost hit ID.
- [ ] **Step 6: Run focused tests to verify GREEN.** Run `moon test src/spatial --filter 'grid|update|remove|boundary'`.
- [ ] **Step 7: Validate package.** Run `moon fmt`, `moon check --deny-warn`, `moon test src/spatial --deny-warn`, and `moon info`.

### Task 5: Complete JSON parsing and checked document decoding

**Files:**
- Create: `src/serialization/json_errors.mbt`
- Create: `src/serialization/json_parser.mbt`
- Modify: `src/serialization/decoder.mbt`
- Modify: `src/serialization/encoder.mbt`
- Modify: `src/serialization/json_ast.mbt` only for parser helpers that belong with the AST.
- Test: `src/serialization/json_parser_test.mbt`
- Test: `src/serialization/serialization_boundary_test.mbt`

**Interfaces:**
- Consumes: existing `JsonValue`, document/node/shape/style constructors, and encoder field names.
- Produces: strict parser and checked decoder while retaining `decode_document(String) -> ArtboardDocument`.

```mbt
pub(all) enum JsonDecodeError {
  UnexpectedEnd(Int)
  UnexpectedCharacter(Int, String)
  InvalidNumber(Int, String)
  InvalidEscape(Int)
  ExpectedField(Int, String)
  InvalidDocument(Int, String)
} derive(Eq, Debug)

pub fn parse_json(
  json_str : String,
) -> Result[JsonValue, JsonDecodeError]

pub fn decode_document_checked(
  json_str : String,
) -> Result[@scenegraph.ArtboardDocument, JsonDecodeError]

pub fn decode_document(
  json_str : String,
) -> @scenegraph.ArtboardDocument
```

- [ ] **Step 1: Write failing parser tests.** Cover objects, arrays, strings with quote/backslash/newline escapes, numbers with exponent, booleans, null, whitespace, trailing input, truncated input, invalid escape, and malformed number.
- [ ] **Step 2: Run parser tests to verify RED.** Run `moon test src/serialization --filter 'json parser'`. Expected: missing `parse_json` or incorrect behavior fails.
- [ ] **Step 3: Implement tokenizer/parser.** Track byte/code-unit position, parse one value recursively, require comma/colon delimiters, decode the escapes that the encoder emits, reject trailing non-whitespace input, and return `JsonDecodeError` with the first failing position.
- [ ] **Step 4: Write failing document round-trip tests.** Build a document containing artboard, group, rectangle with style, path, text containing quotes/newlines, image, nested transforms, opacity, and visibility; encode it; checked-decode it; compare title, dimensions, node IDs, node types, transforms, style fields, and parent/child links. Add invalid document tests for missing nodes, wrong field types, unknown geometry, and missing required fields.
- [ ] **Step 5: Run round-trip tests to verify RED.** Run `moon test src/serialization --filter 'round trip|invalid document'`. Expected: the current decoder’s empty-document behavior fails.
- [ ] **Step 6: Implement document decoding.** Decode metadata first, create all nodes in a first pass, resolve parent and group child references in a second pass, accept unknown fields for forward compatibility, reject missing/incorrect required fields, and preserve the encoder’s geometry/style representation. Make `decode_document` return a new empty document only when checked decoding fails, preserving the existing signature.
- [ ] **Step 7: Harden encoding.** Escape control characters, quotes, backslashes, and line breaks in every string field; serialize node arrays in traversal order instead of relying on Map iteration so benchmark and fixture output is deterministic.
- [ ] **Step 8: Run focused tests to verify GREEN.** Run `moon test src/serialization --filter 'json parser|round trip|invalid document'`.
- [ ] **Step 9: Validate package and public interface.** Run `moon fmt`, `moon check --deny-warn`, `moon test src/serialization --deny-warn`, `moon info`, and inspect `src/serialization/pkg.generated.mbti`.

### Task 6: Add the viewport and dirty-region package

**Files:**
- Create: `src/viewport/moon.pkg`
- Create: `src/viewport/viewport.mbt`
- Create: `src/viewport/dirty_region.mbt`
- Create: `src/viewport/frame_metrics.mbt`
- Test: `src/viewport/viewport_test.mbt`
- Test: `src/viewport/dirty_region_test.mbt`

**Interfaces:**
- Consumes: `Vec2`, `Rect2D`, `Matrix2D`, `ArtboardDocument`, `GridSpatialIndex`.
- Produces: camera state, coordinate conversions, visible-node queries, dirty-region aggregation, and frame metrics for render planning.

```mbt
pub(all) struct Viewport {
  world_width : Double
  world_height : Double
  screen_width : Double
  screen_height : Double
  center : @math.Vec2
  zoom : Double
  device_pixel_ratio : Double
  min_zoom : Double
  max_zoom : Double
} derive(Eq, Debug)

pub fn Viewport::new(
  world_width : Double,
  world_height : Double,
  screen_width : Double,
  screen_height : Double,
) -> Viewport
pub fn Viewport::world_rect(self : Viewport) -> @math.Rect2D
pub fn Viewport::world_to_screen(self : Viewport, point : @math.Vec2) -> @math.Vec2
pub fn Viewport::screen_to_world(self : Viewport, point : @math.Vec2) -> @math.Vec2
pub fn Viewport::pan_by(self : Viewport, delta_screen : @math.Vec2) -> Unit
pub fn Viewport::zoom_at(self : Viewport, factor : Double, screen_point : @math.Vec2) -> Unit

pub(all) struct DirtyRegion {
  bounds : @math.Rect2D
  full_redraw : Bool
} derive(Eq, Debug)

pub fn DirtyRegion::empty() -> DirtyRegion
pub fn DirtyRegion::mark(self : DirtyRegion, bounds : @math.Rect2D) -> Unit
pub fn DirtyRegion::merge(self : DirtyRegion, other : DirtyRegion) -> Unit
pub fn DirtyRegion::needs_redraw(self : DirtyRegion) -> Bool
```

- [ ] **Step 1: Write failing tests.** Cover initial centered viewport, screen/world round-trip, pan direction, zoom clamping, zoom around a cursor preserving its world point, negative/zero viewport dimensions, empty dirty region, overlapping disjoint dirty regions, and full-redraw escalation.
- [ ] **Step 2: Run focused tests to verify RED.** Run `moon test src/viewport --filter 'viewport|dirty'`. Expected: package and symbols do not exist.
- [ ] **Step 3: Implement viewport transforms.** Use `screen = (world - center) * zoom + screen_center`, inverse the same transform, clamp zoom to `[0.01, 64.0]`, normalize non-positive dimensions to `1.0`, and make `zoom_at` adjust center so the chosen world point remains under the cursor.
- [ ] **Step 4: Implement dirty-region aggregation.** Treat empty as no redraw, union intersecting/adjacent regions, preserve disjoint regions through a bounded region list, and set `full_redraw` when region count or covered area exceeds a deterministic threshold.
- [ ] **Step 5: Run focused tests to verify GREEN.** Run `moon test src/viewport --filter 'viewport|dirty'`.
- [ ] **Step 6: Validate package.** Run `moon fmt`, `moon check --deny-warn`, and `moon test src/viewport --deny-warn`.

### Task 7: Build the backend-neutral RenderPlan and adapt Canvas export

**Files:**
- Create: `src/render/moon.pkg`
- Create: `src/render/render_op.mbt`
- Create: `src/render/render_plan.mbt`
- Create: `src/render/render_compiler.mbt`
- Create: `src/render/render_stats.mbt`
- Modify: `src/export/canvas2d.mbt`
- Modify: `src/export/svg_exporter.mbt` for shared traversal/escaping helpers.
- Test: `src/render/render_plan_test.mbt`
- Test: `src/export/export_boundary_test.mbt`

**Interfaces:**
- Consumes: Task 2 path primitives, Task 3 traversal, Task 4 spatial culling, Task 6 viewport, existing node styles and Canvas commands.
- Produces: stable render operations and backend adapters that agree on order, transforms, opacity, visibility, and string escaping.

```mbt
pub(all) enum RenderOp {
  Save
  Restore
  SetTransform(@math.Matrix2D)
  SetOpacity(Double)
  DrawPath(@shapes.Path, @shapes.Style)
  DrawText(String, @math.Vec2, Double, String, @shapes.Style)
  DrawImage(String, @math.Rect2D, Double)
} derive(Eq, Debug)

pub(all) struct RenderStats {
  visited_nodes : Int
  visible_nodes : Int
  culled_nodes : Int
  draw_ops : Int
  path_segments : Int
} derive(Eq, Debug)

pub(all) struct RenderPlan {
  ops : Array[RenderOp]
  stats : RenderStats
} derive(Eq, Debug)

pub fn compile_render_plan(
  doc : @scenegraph.ArtboardDocument,
  viewport : @viewport.Viewport?,
) -> RenderPlan
pub fn canvas_commands_from_plan(
  plan : RenderPlan,
) -> Array[@export.CanvasCommand]
```

- [ ] **Step 1: Write failing render tests.** Build nested groups and shapes, assert exact operation order, save/restore nesting, accumulated opacity, world transforms, invisible-node omission, viewport culling, and stats counts. Add a text/image case and a path with `QuadTo`/`ArcTo`.
- [ ] **Step 2: Run focused render tests to verify RED.** Run `moon test src/render --filter 'render plan'`. Expected: new package/symbol failures.
- [ ] **Step 3: Implement RenderOp and compiler.** Walk `ArtboardDocument::traverse`, maintain one save/restore pair per rendered node, skip invisible nodes, cull outside the optional viewport rectangle, multiply opacity through the traversal entry, convert shapes to paths, and count path segments without mutating the source document.
- [ ] **Step 4: Adapt Canvas commands.** Map `DrawPath` segments to `BeginPath`, `MoveTo`, `LineTo`, `CubicTo`, `ClosePath`, fill/stroke operations; map `SetOpacity` to a new Canvas command only if the public enum can remain compatible, otherwise emit a backend-independent `CanvasCommand::SetGlobalAlpha` and update its tests. Preserve existing `generate_canvas_instructions` output for documents without nested opacity.
- [ ] **Step 5: Harden SVG escaping and traversal.** Escape `&`, `<`, `>`, quotes, and apostrophes in IDs, text, image URLs, and path attributes; use the shared traversal order; write deterministic output for the same document.
- [ ] **Step 6: Run focused tests to verify GREEN.** Run `moon test src/render --filter 'render plan'` and `moon test src/export --filter 'Canvas|SVG|boundary'`.
- [ ] **Step 7: Validate dependent packages.** Run `moon fmt`, `moon check --deny-warn`, `moon test src/render --deny-warn`, `moon test src/export --deny-warn`, and `moon info`.

### Task 8: Expand integration and regression coverage

**Files:**
- Modify: `src/math/math_test.mbt`
- Modify: `src/shapes/shapes_test.mbt`
- Modify: `src/scenegraph/scenegraph_test.mbt`
- Modify: `src/spatial/spatial_test.mbt`
- Modify: `src/selection/selection_test.mbt`
- Modify: `src/history/history_test.mbt`
- Modify: `src/tools/tools_test.mbt`
- Modify: `src/serialization/serialization_test.mbt`
- Modify: `src/export/export_test.mbt`
- Create: `src/integration_test.mbt` only if a root package exists; otherwise add `src/main/integration_boundary_test.mbt`.

**Interfaces:**
- Consumes: all completed packages.
- Produces: cross-package regression evidence for a realistic editor workflow.

- [ ] **Step 1: Write failing integration tests.** Add a deterministic workflow test that creates an artboard, adds nested shapes/text/image nodes, applies transforms and auto-layout, selects and hits nodes, builds a spatial index, compiles a render plan, encodes/decodes JSON, and asserts document validation remains valid. Add a failure-path test that uses malformed JSON and a cycle-injected document.
- [ ] **Step 2: Run the integration tests to verify RED.** Run `moon test --filter 'integration workflow|malformed JSON|cycle'`. Expected: at least one new assertion fails against the pre-integration implementation or missing APIs.
- [ ] **Step 3: Implement only the smallest integration fixes.** Resolve API mismatches found by the failing tests in their owning package; do not add test-only production methods or weaken assertions.
- [ ] **Step 4: Run the full suite.** Run `moon test --deny-warn`. Expected: every existing and new test passes with zero failures.
- [ ] **Step 5: Record coverage.** Run `moon test --enable-coverage`, `moon coverage report -f summary`, and `moon coverage analyze`; inspect uncovered lines in new geometry, parser, index, viewport, and render code and add behavior tests for meaningful gaps.

### Task 9: Add the benchmark CLI and honest source-statistics tool

**Files:**
- Create: `cmd/bench/moon.pkg`
- Create: `cmd/bench/main.mbt`
- Create: `cmd/bench/scenarios.mbt`
- Create: `cmd/bench/measurements.mbt`
- Create: `benchmarks/README.md`
- Create: `scripts/count-moonbit-lines.ps1`
- Test: `cmd/bench/bench_scenarios_test.mbt` if the executable package supports tests; otherwise test scenario builders in a library package under `src/benchmark_support`.

**Interfaces:**
- Consumes: scenegraph, serialization, spatial, viewport, render, export and `moonbitlang/core/bench`.
- Produces: measured benchmark output and a machine-readable source count.

```mbt
pub(all) struct BenchmarkResult {
  name : String
  sample_size : Int
  iterations : Int
  total_microseconds : Double
  average_microseconds : Double
  checksum : Int
} derive(Debug)

pub fn run_benchmark_suite() -> Array[BenchmarkResult]
pub fn format_benchmark_result(result : BenchmarkResult) -> String
```

- [ ] **Step 1: Write failing scenario tests.** Assert that small/medium/large builders produce fixed node counts, that the same scenario produces the same checksum twice, and that benchmark iteration counts are positive and explicit.
- [ ] **Step 2: Run scenario tests to verify RED.** Run `moon test cmd/bench --filter 'scenario|checksum'`. Expected: missing package/symbol failures.
- [ ] **Step 3: Implement deterministic scenarios.** Use fixed loops and literal transforms/colors/IDs; do not use random numbers or wall-clock values in the input. Build the document once per scenario, warm up each operation, run a fixed iteration count, and checksum result lengths/counts so the compiler cannot optimize away observable work.
- [ ] **Step 4: Implement measurements.** Import `moonbitlang/core/bench`, call `monotonic_clock_start()` and `monotonic_clock_end()`, divide by the known iteration count, and print toolchain/target metadata followed by one line per result. Never print a hard-coded timing.
- [ ] **Step 5: Implement source counting.** `scripts/count-moonbit-lines.ps1` enumerates `src/**/*.mbt` and `cmd/**/*.mbt`, excludes names ending `_test.mbt` and generated files, removes blank/comment-only lines, prints production/test/file totals, and exits non-zero if production code is below 8,000 lines. It must not read or count `OSC2026_August_Hackathon_Application.md`.
- [ ] **Step 6: Run benchmark and count locally.** Run `moon fmt`, `moon check --deny-warn`, `moon test cmd/bench --deny-warn`, `moon run cmd/bench --target native`, and `pwsh -NoProfile -File scripts/count-moonbit-lines.ps1`. Save the complete real output and environment details in `benchmarks/README.md`; do not invent or round timings.
- [ ] **Step 7: Verify repeatability.** Run the benchmark command twice and compare scenario sizes/checksums. Timing variance may differ; input/result invariants must match.

### Task 10: Rewrite README and strengthen CI

**Files:**
- Rewrite: `README.md`
- Create: `docs/architecture.md`
- Create: `docs/api-examples.md`
- Modify: `.github/workflows/ci.yml`
- Modify: `.github/workflows/copilot-setup-steps.yml` only to align setup/version checks.
- Modify: `.gitignore` only for benchmark/build outputs that are intentionally local.

**Interfaces:**
- Consumes: completed public APIs, actual benchmark output, actual source counts, final test counts, and license file.
- Produces: user-facing documentation and reproducible CI.

- [ ] **Step 1: Write documentation acceptance checks.** Use a PowerShell check in the working session to assert README contains the headings `Project Overview`, `Core Capabilities`, `Quick Start`, `CLI`, `Architecture`, `Benchmarks`, `Testing`, `CI`, and `License`; assert it contains no `申报`, `结项`, `唯一贡献`, `GitLink`, or single-contributor wording. The check should fail against the current README because it lacks the required structure and contains internal competition language.
- [ ] **Step 2: Rewrite README from verified facts.** Include the module name, package usage, a minimal MoonBit code example, exact commands (`moon fmt --check`, `moon check --deny-warn`, `moon test --deny-warn`, `moon run src/main`, `moon run cmd/bench --target native`), package map, benchmark methodology, test command, CI behavior, Apache-2.0 link, and a source-count command. Do not copy the申报书’s claims or state unmeasured performance.
- [ ] **Step 3: Add architecture/API documentation.** Explain data flow from scenegraph traversal through spatial culling and RenderPlan to Canvas/SVG adapters, and document checked JSON decoding plus limitations of the PDF adapter.
- [ ] **Step 4: Replace CI workflow.** Use `actions/checkout@v4` with `persist-credentials: false`, minimum `contents: read`, `push`/`pull_request`/manual triggers, and a matrix `[ubuntu-latest, macos-latest, windows-latest]`. Install the latest stable MoonBit with the official platform script, append the toolchain to `GITHUB_PATH`, run `moon version --all`, `moon update`, `moon fmt --check`, `moon info`, `git diff --exit-code`, `moon check --deny-warn`, `moon test --deny-warn`, and `moon run src/main`. Add an Ubuntu-only native/coverage/benchmark job; do not require Windows native tests because the verified local runtime failure is outside this project’s code.
- [ ] **Step 5: Validate workflow syntax and content locally.** Parse the YAML with an available YAML parser if present; otherwise inspect indentation and run the same shell commands locally. Confirm the workflow does not contain credentials, hard-coded old MoonBit versions, or GitLink steps.
- [ ] **Step 6: Run documentation checks.** Run the README heading/forbidden-term check, `git diff --check`, `moon fmt --check`, and `moon info` followed by `git diff --exit-code -- '*.mbti'`.

### Task 11: Final verification and local acceptance self-review

**Files:**
- Modify: `findings.md`
- Modify: `progress.md`
- Modify: `task_plan.md`
- Create: `docs/acceptance-checklist.md`
- Do not modify: `OSC2026_August_Hackathon_Application.md`

- [ ] **Step 1: Capture proposal immutability evidence.** Record the proposal SHA-256 before final verification, run every implementation command, compute it again, and require equality. Use `Get-FileHash -Algorithm SHA256 -LiteralPath OSC2026_August_Hackathon_Application.md`.
- [ ] **Step 2: Run the complete local gate.** Run these commands sequentially so their outputs are unambiguous:

```powershell
moon version --all
moon update
moon fmt --check
moon check --deny-warn
moon info
git diff --exit-code -- '*.mbti'
moon test --deny-warn
moon run src/main
moon run cmd/bench --target native
pwsh -NoProfile -File scripts/count-moonbit-lines.ps1
git diff --check
git status --short --branch
```

Expected: every command exits 0; the native benchmark is allowed to be the only native command and its output is recorded as measured data. The line counter must report production code over 8,000.
- [ ] **Step 3: Run the final self-review checklist.** Inspect repository structure, README sections, root `LICENSE`, current branch/default branch evidence, meaningful commit history, public GitHub remote presence, MoonBit version, actual source counts, test output, CI coverage, untracked build artifacts, and the absence of internal competition language in README.
- [ ] **Step 4: Report unverifiable items honestly.** Mark Mooncakes publication and remote GitHub Actions status as pending external actions because this session explicitly does not push or publish. Mark local Windows native failure as a toolchain/environment limitation with its exact command and error location; do not claim native support passed on Windows.
- [ ] **Step 5: Update planning files.** Mark completed phases and list every command, test count, source count, benchmark environment, changed file group, and remaining external action in `findings.md` and `progress.md`.
- [ ] **Step 6: Inspect the final diff.** Run `git diff --stat`, `git diff --name-only`, and `git status --short`; verify the proposal is absent from the changed-file list. Create one local final commit only after fresh verification; do not push it.

## Plan Self-Review

- The design’s six functional areas map to Tasks 1–7; integration behavior maps to Task 8; measured data and honest line counting map to Task 9; documentation and CI map to Task 10; final acceptance evidence maps to Task 11.
- Every new public API has a named test location and a focused command that is expected to fail before implementation.
- The render package does not import back into scenegraph, so package dependencies remain acyclic: math → shapes → scenegraph → spatial/viewport → render → export, with serialization and history remaining separate consumers.
- The existing `decode_document` and `GridSpatialIndex` names are retained; new checked/error/statistics APIs extend rather than silently replace the public surface.
- The production-line threshold is enforced by a script over actual source files, while test lines and generated interfaces are reported separately.
- There are no `TBD`, `TODO`, or “implement later” steps; all verification commands and expected outcomes are explicit.
