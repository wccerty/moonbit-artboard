// Spatial hit testing algorithms (Winding Number / Raycasting & Document hit test).

///|
pub fn point_in_rect(p : @math.Vec2, rect : @math.Rect2D) -> Bool {
  rect.contains_point(p)
}

///|
pub fn point_in_polygon(p : @math.Vec2, vertices : Array[@math.Vec2]) -> Bool {
  let n = vertices.length()
  if n < 3 {
    false
  } else {
    let mut wn = 0
    for i = 0; i < n; i = i + 1 {
      let v1 = vertices[i]
      let v2 = vertices[(i + 1) % n]
      if v1.y <= p.y {
        if v2.y > p.y {
          let vt = (p.y - v1.y) / (v2.y - v1.y)
          if p.x < v1.x + vt * (v2.x - v1.x) {
            wn = wn + 1
          }
        }
      } else if v2.y <= p.y {
        let vt = (p.y - v1.y) / (v2.y - v1.y)
        if p.x < v1.x + vt * (v2.x - v1.x) {
          wn = wn - 1
        }
      }
    }
    !(wn == 0)
  }
}

///|
pub fn hit_test_node(
  doc : @scenegraph.ArtboardDocument,
  node_id : @scenegraph.NodeID,
  point : @math.Vec2,
) -> Bool {
  match doc.get_node(node_id) {
    None => false
    Some(node) => {
      if !node.visible || node.locked {
        return false
      }
      let bounds = doc.get_world_bounds(node_id)
      if !bounds.contains_point(point) {
        return false
      }
      match node.node_type {
        GroupNode(children) => {
          for i = 0; i < children.length(); i = i + 1 {
            if hit_test_node(doc, children[i], point) {
              return true
            }
          }
          false
        }
        ShapeNode(s) => {
          let path = s.geometry.to_path()
          path.bounds().contains_point(point)
        }
        _ => true
      }
    }
  }
}

///|
pub fn hit_test_document(
  doc : @scenegraph.ArtboardDocument,
  point : @math.Vec2,
) -> @scenegraph.NodeID? {
  // Search root nodes in reverse z-index order (top-most first)
  let len = doc.root_ids.length()
  for i = len - 1; i >= 0; i = i - 1 {
    let id = doc.root_ids[i]
    if hit_test_node(doc, id, point) {
      return Some(id)
    }
  }
  None
}
