// Document-aware spatial queries with visibility and lock filtering.

///|
pub(all) struct SpatialQueryOptions {
  include_invisible : Bool
  include_locked : Bool
  exact_bounds : Bool
} derive(Eq, Debug)

///|
pub fn SpatialQueryOptions::default() -> SpatialQueryOptions {
  { include_invisible: false, include_locked: false, exact_bounds: true }
}

///|
pub fn SpatialQueryOptions::visible_only() -> SpatialQueryOptions {
  SpatialQueryOptions::default()
}

///|
pub fn SpatialQueryOptions::including_hidden() -> SpatialQueryOptions {
  { ..SpatialQueryOptions::default(), include_invisible: true }
}

///|
pub fn SpatialQueryOptions::including_locked() -> SpatialQueryOptions {
  { ..SpatialQueryOptions::default(), include_locked: true }
}

///|
fn query_candidate_allowed(
  document : @scenegraph.ArtboardDocument,
  id : @scenegraph.NodeID,
  query : @math.Rect2D,
  options : SpatialQueryOptions,
) -> Bool {
  match document.get_node(id) {
    None => false
    Some(node) => {
      if !options.include_invisible && !node.visible {
        return false
      }
      if !options.include_locked && node.locked {
        return false
      }
      if options.exact_bounds {
        document.get_world_bounds(id).intersects(query)
      } else {
        true
      }
    }
  }
}

///|
pub fn query_document(
  index : GridSpatialIndex,
  document : @scenegraph.ArtboardDocument,
  query : @math.Rect2D,
  options : SpatialQueryOptions,
) -> Array[@scenegraph.NodeID] {
  let candidates = index.query_rect(query)
  let candidate_set : Map[String, Bool] = Map([])
  for i = 0; i < candidates.length(); i = i + 1 {
    candidate_set[candidates[i].value] = true
  }
  let result : Array[@scenegraph.NodeID] = []
  let ordered = document.ordered_node_ids()
  for i = 0; i < ordered.length(); i = i + 1 {
    let id = ordered[i]
    if candidate_set.get(id.value) is Some(_) &&
      query_candidate_allowed(document, id, query, options) {
      result.push(id)
    }
  }
  result
}

///|
fn distance_to_rect(point : @math.Vec2, rect : @math.Rect2D) -> Double {
  let corners = rect.corners()
  let min_x = corners[0].x
  let min_y = corners[0].y
  let max_x = corners[2].x
  let max_y = corners[2].y
  let dx = if point.x < min_x {
    min_x - point.x
  } else if point.x > max_x {
    point.x - max_x
  } else {
    0.0
  }
  let dy = if point.y < min_y {
    min_y - point.y
  } else if point.y > max_y {
    point.y - max_y
  } else {
    0.0
  }
  (dx * dx + dy * dy).sqrt()
}

///|
pub fn nearest_document_node(
  index : GridSpatialIndex,
  document : @scenegraph.ArtboardDocument,
  point : @math.Vec2,
  max_distance : Double,
  options : SpatialQueryOptions,
) -> @scenegraph.NodeID? {
  let radius = if max_distance < 0.0 { 0.0 } else { max_distance }
  let query = @math.Rect2D::new(
    point.x - radius,
    point.y - radius,
    point.x + radius,
    point.y + radius,
  )
  let candidates = query_document(index, document, query, options)
  let mut best_distance = radius
  let mut best : @scenegraph.NodeID? = None
  for i = 0; i < candidates.length(); i = i + 1 {
    let id = candidates[i]
    let distance = distance_to_rect(point, document.get_world_bounds(id))
    if distance <= best_distance {
      best_distance = distance
      best = Some(id)
    }
  }
  best
}

///|
pub fn query_visible_document(
  index : GridSpatialIndex,
  document : @scenegraph.ArtboardDocument,
  query : @math.Rect2D,
) -> Array[@scenegraph.NodeID] {
  query_document(index, document, query, SpatialQueryOptions::visible_only())
}

///|
pub fn query_editable_document(
  index : GridSpatialIndex,
  document : @scenegraph.ArtboardDocument,
  query : @math.Rect2D,
) -> Array[@scenegraph.NodeID] {
  query_document(index, document, query, SpatialQueryOptions::visible_only())
}

///|
pub fn query_all_document(
  index : GridSpatialIndex,
  document : @scenegraph.ArtboardDocument,
  query : @math.Rect2D,
) -> Array[@scenegraph.NodeID] {
  query_document(
    index,
    document,
    query,
    SpatialQueryOptions::including_hidden(),
  )
}
