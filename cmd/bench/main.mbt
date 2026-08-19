// Reproducible local benchmark entry point.

///|
fn main {
  println("MoonBit Artboard benchmark suite")
  println("clock=moonbitlang/core/bench.monotonic_clock_us")
  let results = run_benchmark_suite()
  for i = 0; i < results.length(); i = i + 1 {
    println(format_benchmark_result(results[i]))
  }
}
