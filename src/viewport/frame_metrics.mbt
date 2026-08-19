// Lightweight counters shared by render and benchmark reporting.

///|
pub(all) struct FrameMetrics {
  elapsed_microseconds : Double
  visited_nodes : Int
  visible_nodes : Int
  culled_nodes : Int
  draw_ops : Int
} derive(Eq, Debug)

///|
pub fn FrameMetrics::new(
  elapsed_microseconds : Double,
  visited_nodes : Int,
  visible_nodes : Int,
  culled_nodes : Int,
  draw_ops : Int,
) -> FrameMetrics {
  { elapsed_microseconds, visited_nodes, visible_nodes, culled_nodes, draw_ops }
}

///|
pub fn FrameMetrics::empty() -> FrameMetrics {
  FrameMetrics::new(0.0, 0, 0, 0, 0)
}

///|
pub fn FrameMetrics::throughput(self : FrameMetrics) -> Double {
  if self.elapsed_microseconds <= 0.0 {
    0.0
  } else {
    self.draw_ops.to_double() * 1000000.0 / self.elapsed_microseconds
  }
}
