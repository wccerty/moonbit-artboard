// Deterministic scene traversal with cycle-safe world calculations.

///|
pub(all) struct TraversalEntry {
  id : NodeID
  parent_id : NodeID?
  world_transform : @math.Matrix2D
  world_bounds : @math.Rect2D
  depth : Int
  inherited_opacity : Double
} derive(Debug)

///|
fn world_matrix_safe(
  doc : ArtboardDocument,
  id : NodeID,
  visiting : Map[String, Bool],
) -> @math.Matrix2D {
  match visiting.get(id.value) {
    Some(_) => @math.Matrix2D::identity()
    None => {
      visiting[id.value] = true
      let result = match doc.nodes.get(id.value) {
        None => @math.Matrix2D::identity()
        Some(node) =>
          match node.parent_id {
            None => node.transform
            Some(parent_id) =>
              world_matrix_safe(doc, parent_id, visiting).multiply(
                node.transform,
              )
          }
      }
      visiting.remove(id.value)
      result
    }
  }
}

///|
fn world_bounds_safe(
  doc : ArtboardDocument,
  id : NodeID,
  visiting : Map[String, Bool],
) -> @math.Rect2D {
  match visiting.get(id.value) {
    Some(_) => @math.Rect2D::empty()
    None => {
      visiting[id.value] = true
      let result = match doc.nodes.get(id.value) {
        None => @math.Rect2D::empty()
        Some(node) =>
          match node.node_type {
            GroupNode(children) => {
              let mut bounds = @math.Rect2D::empty()
              for i = 0; i < children.length(); i = i + 1 {
                bounds = bounds.union(
                  world_bounds_safe(doc, children[i], visiting),
                )
              }
              bounds
            }
            _ => {
              let matrix = world_matrix_safe(doc, id, Map([]))
              matrix.transform_bounds(node.local_bounds())
            }
          }
      }
      visiting.remove(id.value)
      result
    }
  }
}

///|
fn append_traversal_entry(
  doc : ArtboardDocument,
  id : NodeID,
  depth : Int,
  parent_opacity : Double,
  visited : Map[String, Bool],
  output : Array[TraversalEntry],
) -> Unit {
  match visited.get(id.value) {
    Some(_) => ()
    None =>
      match doc.nodes.get(id.value) {
        None => ()
        Some(node) => {
          visited[id.value] = true
          let opacity = @math.clamp_double(
            parent_opacity * node.opacity,
            0.0,
            1.0,
          )
          output.push({
            id,
            parent_id: node.parent_id,
            world_transform: world_matrix_safe(doc, id, Map([])),
            world_bounds: world_bounds_safe(doc, id, Map([])),
            depth,
            inherited_opacity: opacity,
          })
          match node.node_type {
            GroupNode(children) =>
              for i = 0; i < children.length(); i = i + 1 {
                append_traversal_entry(
                  doc,
                  children[i],
                  depth + 1,
                  opacity,
                  visited,
                  output,
                )
              }
            _ => ()
          }
        }
      }
  }
}

///|
pub fn ArtboardDocument::traverse(
  self : ArtboardDocument,
) -> Array[TraversalEntry] {
  let output : Array[TraversalEntry] = []
  let visited : Map[String, Bool] = Map([])
  for i = 0; i < self.root_ids.length(); i = i + 1 {
    append_traversal_entry(self, self.root_ids[i], 0, 1.0, visited, output)
  }
  output
}
