// Benchmark measurement and output formatting.

///|
pub(all) struct BenchmarkResult {
  name : String
  sample_size : Int
  iterations : Int
  total_microseconds : Double
  average_microseconds : Double
  checksum : Int
} derive(Debug)

///|
fn benchmark_iteration(
  document : @scenegraph.ArtboardDocument,
  index : @spatial.GridSpatialIndex,
  viewport : @viewport.Viewport,
) -> Int {
  let query = index.query_rect(viewport.visible_world_rect())
  let plan = @render.compile_render_plan(document, Some(viewport))
  let canvas = @export.canvas_commands_from_plan(plan)
  let encoded = @serialization.encode_document(document)
  query.length() * 3 +
  plan.ops.length() * 5 +
  canvas.length() * 7 +
  encoded.length()
}

///|
fn measure_scenario(sample_size : Int, iterations : Int) -> BenchmarkResult {
  let document = build_benchmark_document(sample_size)
  let index = @spatial.GridSpatialIndex::build_from_doc(document, 64.0)
  let viewport = @viewport.Viewport::new(4096.0, 4096.0, 1024.0, 768.0)
  ignore(benchmark_iteration(document, index, viewport))
  let start = @clock.monotonic_clock_start()
  let mut checksum = 0
  for i = 0; i < iterations; i = i + 1 {
    checksum = checksum + benchmark_iteration(document, index, viewport)
  }
  let total = @clock.monotonic_clock_end(start)
  {
    name: "render-query-export",
    sample_size,
    iterations,
    total_microseconds: total,
    average_microseconds: total / iterations.to_double(),
    checksum,
  }
}

///|
pub fn run_benchmark_suite() -> Array[BenchmarkResult] {
  [
    measure_scenario(32, 64),
    measure_scenario(256, 24),
    measure_scenario(1024, 8),
  ]
}

///|
pub fn format_benchmark_result(result : BenchmarkResult) -> String {
  result.name +
  " sample_size=" +
  result.sample_size.to_string() +
  " iterations=" +
  result.iterations.to_string() +
  " total_us=" +
  result.total_microseconds.to_string() +
  " average_us=" +
  result.average_microseconds.to_string() +
  " checksum=" +
  result.checksum.to_string()
}
