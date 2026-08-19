///|
pub(all) struct RenderStats {
  mut visited_nodes : Int
  mut visible_nodes : Int
  mut culled_nodes : Int
  mut draw_ops : Int
  mut path_segments : Int
} derive(Eq, Debug)

///|
pub fn RenderStats::empty() -> RenderStats {
  {
    visited_nodes: 0,
    visible_nodes: 0,
    culled_nodes: 0,
    draw_ops: 0,
    path_segments: 0,
  }
}
