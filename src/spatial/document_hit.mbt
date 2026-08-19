// Spatial hit testing algorithms (winding number, ray casting, and document hit test).

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
    let mut winding_number = 0
    for i = 0; i < n; i = i + 1 {
      let v1 = vertices[i]
      let v2 = vertices[(i + 1) % n]
      if v1.y <= p.y {
        if v2.y > p.y {
          let vt = (p.y - v1.y) / (v2.y - v1.y)
          if p.x < v1.x + vt * (v2.x - v1.x) {
            winding_number = winding_number + 1
          }
        }
      } else if v2.y <= p.y {
        let vt = (p.y - v1.y) / (v2.y - v1.y)
        if p.x < v1.x + vt * (v2.x - v1.x) {
          winding_number = winding_number - 1
        }
      }
    }
    winding_number != 0
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
      let local_point = match doc.get_world_matrix(node_id).invert() {
        None => return false
        Some(inverse) => inverse.transform_point(point)
      }
      match node.node_type {
        GroupNode(children) => {
          for i = children.length() - 1; i >= 0; i = i - 1 {
            if hit_test_node(doc, children[i], point) {
              return true
            }
          }
          false
        }
        ShapeNode(shape) => {
          let path = shape.geometry.to_path()
          let fill_hit = match shape.style.fill {
            None => false
            _ => hit_test_geometry(shape.geometry, local_point, 0.25)
          }
          let stroke_hit = match shape.style.stroke {
            None => false
            Some(stroke) =>
              @vshapes.path_distance_to_point(path, local_point, 0.25) <=
              stroke.width * 0.5 + 0.25
          }
          fill_hit || stroke_hit
        }
        _ => node.local_bounds().contains_point(local_point)
      }
    }
  }
}

///|
pub fn hit_test_document(
  doc : @scenegraph.ArtboardDocument,
  point : @math.Vec2,
) -> @scenegraph.NodeID? {
  let entries = doc.traverse()
  for i = entries.length() - 1; i >= 0; i = i - 1 {
    let entry = entries[i]
    if entry.world_bounds.contains_point(point) &&
      hit_test_node(doc, entry.id, point) {
      return Some(entry.id)
    }
  }
  None
}
