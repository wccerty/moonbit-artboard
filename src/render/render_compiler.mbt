// Deterministic scene traversal into a backend-neutral operation stream.

///|
fn hidden_by_ancestor(
  doc : @scenegraph.ArtboardDocument,
  id : @scenegraph.NodeID,
  hidden : Map[String, Bool],
) -> Bool {
  match hidden.get(id.value) {
    Some(value) => value
    None =>
      match doc.get_node(id) {
        None => true
        Some(node) => {
          let parent_hidden = match node.parent_id {
            None => false
            Some(parent) => hidden_by_ancestor(doc, parent, hidden)
          }
          let result = parent_hidden || !node.visible
          hidden[id.value] = result
          result
        }
      }
  }
}

///|
fn append_node_ops(
  doc : @scenegraph.ArtboardDocument,
  entry : @scenegraph.TraversalEntry,
  ops : Array[RenderOp],
  stats : RenderStats,
) -> Unit {
  match doc.get_node(entry.id) {
    None => ()
    Some(node) => {
      ops.push(RenderOp::Save)
      ops.push(RenderOp::SetTransform(entry.world_transform))
      ops.push(RenderOp::SetOpacity(entry.inherited_opacity))
      match node.node_type {
        ShapeNode(shape) => {
          let path = shape.geometry.to_path()
          ops.push(RenderOp::DrawPath(path, shape.style))
          stats.draw_ops = stats.draw_ops + 1
          stats.path_segments = stats.path_segments + path.segments.length()
        }
        TextNode(text) => {
          ops.push(
            RenderOp::DrawText(
              text.text,
              @math.Vec2::zero(),
              text.font_size,
              text.font_family,
              text.style,
            ),
          )
          stats.draw_ops = stats.draw_ops + 1
        }
        ImageNode(image) => {
          ops.push(
            RenderOp::DrawImage(
              image.src,
              @math.Rect2D::new(0.0, 0.0, image.width, image.height),
              entry.inherited_opacity,
            ),
          )
          stats.draw_ops = stats.draw_ops + 1
        }
        GroupNode(_) | ArtboardNode(_) => ()
      }
      ops.push(RenderOp::Restore)
    }
  }
}

///|
pub fn compile_render_plan(
  doc : @scenegraph.ArtboardDocument,
  viewport : @viewport.Viewport?,
) -> RenderPlan {
  let ops : Array[RenderOp] = []
  let stats = RenderStats::empty()
  let hidden : Map[String, Bool] = Map([])
  let entries = doc.traverse()
  let visible_rect = match viewport {
    None => None
    Some(view) => Some(view.visible_world_rect())
  }
  for i = 0; i < entries.length(); i = i + 1 {
    let entry = entries[i]
    stats.visited_nodes = stats.visited_nodes + 1
    if hidden_by_ancestor(doc, entry.id, hidden) {
      continue
    }
    match visible_rect {
      Some(rect) if !entry.world_bounds.is_empty() &&
        !entry.world_bounds.intersects(rect) => {
        stats.culled_nodes = stats.culled_nodes + 1
        continue
      }
      _ => ()
    }
    stats.visible_nodes = stats.visible_nodes + 1
    append_node_ops(doc, entry, ops, stats)
  }
  { ops, stats }
}
