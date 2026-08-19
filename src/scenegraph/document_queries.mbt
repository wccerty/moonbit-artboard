// Read-only scene graph queries used by inspectors, selection and layout tools.

///|
pub(all) struct DocumentMetrics {
  node_count : Int
  root_count : Int
  leaf_count : Int
  group_count : Int
  shape_count : Int
  text_count : Int
  image_count : Int
  artboard_count : Int
  visible_count : Int
  locked_count : Int
  max_depth : Int
  total_bounds : @math.Rect2D
  total_area : Double
} derive(Eq, Debug)

///|
pub fn ArtboardDocument::metrics(self : ArtboardDocument) -> DocumentMetrics {
  let entries = self.traverse()
  let mut leaf_count = 0
  let mut group_count = 0
  let mut shape_count = 0
  let mut text_count = 0
  let mut image_count = 0
  let mut artboard_count = 0
  let mut visible_count = 0
  let mut locked_count = 0
  let mut max_depth = 0
  let mut total_bounds = @math.Rect2D::empty()
  for i = 0; i < entries.length(); i = i + 1 {
    let entry = entries[i]
    if entry.depth > max_depth {
      max_depth = entry.depth
    }
    total_bounds = total_bounds.union(entry.world_bounds)
    match self.nodes.get(entry.id.value) {
      None => ()
      Some(node) => {
        if node.visible {
          visible_count = visible_count + 1
        }
        if node.locked {
          locked_count = locked_count + 1
        }
        match node.node_type {
          GroupNode(_) => group_count = group_count + 1
          ShapeNode(_) => {
            shape_count = shape_count + 1
            leaf_count = leaf_count + 1
          }
          TextNode(_) => {
            text_count = text_count + 1
            leaf_count = leaf_count + 1
          }
          ImageNode(_) => {
            image_count = image_count + 1
            leaf_count = leaf_count + 1
          }
          ArtboardNode(_) => {
            artboard_count = artboard_count + 1
            leaf_count = leaf_count + 1
          }
        }
      }
    }
  }
  {
    node_count: entries.length(),
    root_count: self.root_ids.length(),
    leaf_count,
    group_count,
    shape_count,
    text_count,
    image_count,
    artboard_count,
    visible_count,
    locked_count,
    max_depth,
    total_bounds,
    total_area: total_bounds.width() * total_bounds.height(),
  }
}

///|
pub fn ArtboardDocument::ordered_node_ids(
  self : ArtboardDocument,
) -> Array[NodeID] {
  let entries = self.traverse()
  let result : Array[NodeID] = []
  for i = 0; i < entries.length(); i = i + 1 {
    result.push(entries[i].id)
  }
  result
}

///|
pub fn ArtboardDocument::leaf_node_ids(
  self : ArtboardDocument,
) -> Array[NodeID] {
  let result : Array[NodeID] = []
  let ordered = self.ordered_node_ids()
  for i = 0; i < ordered.length(); i = i + 1 {
    match self.nodes.get(ordered[i].value) {
      Some(node) =>
        match node.node_type {
          GroupNode(_) => ()
          _ => result.push(node.id)
        }
      None => ()
    }
  }
  result
}

///|
pub fn ArtboardDocument::find_by_name(
  self : ArtboardDocument,
  name : String,
) -> Array[NodeID] {
  let result : Array[NodeID] = []
  let ordered = self.ordered_node_ids()
  for i = 0; i < ordered.length(); i = i + 1 {
    match self.nodes.get(ordered[i].value) {
      Some(node) if node.name == name => result.push(node.id)
      _ => ()
    }
  }
  result
}

///|
pub fn ArtboardDocument::find_name_contains(
  self : ArtboardDocument,
  fragment : String,
) -> Array[NodeID] {
  let result : Array[NodeID] = []
  let ordered = self.ordered_node_ids()
  for i = 0; i < ordered.length(); i = i + 1 {
    match self.nodes.get(ordered[i].value) {
      Some(node) if node.name.contains(fragment) => result.push(node.id)
      _ => ()
    }
  }
  result
}

///|
pub fn ArtboardDocument::descendants(
  self : ArtboardDocument,
  id : NodeID,
) -> Array[NodeID] {
  let result : Array[NodeID] = []
  let pending : Array[NodeID] = []
  let visited : Map[String, Bool] = Map([])
  pending.push(id)
  while !pending.is_empty() {
    let current = pending.unsafe_pop()
    match visited.get(current.value) {
      Some(_) => ()
      None => {
        visited[current.value] = true
        match self.nodes.get(current.value) {
          Some(node) =>
            match node.node_type {
              GroupNode(children) =>
                for i = children.length() - 1; i >= 0; i = i - 1 {
                  let child = children[i]
                  result.push(child)
                  pending.push(child)
                }
              _ => ()
            }
          None => ()
        }
      }
    }
  }
  result
}

///|
pub fn ArtboardDocument::ancestors(
  self : ArtboardDocument,
  id : NodeID,
) -> Array[NodeID] {
  let result : Array[NodeID] = []
  let visited : Map[String, Bool] = Map([])
  let mut current = id
  while true {
    match self.nodes.get(current.value) {
      None => break
      Some(node) =>
        match node.parent_id {
          None => break
          Some(parent) =>
            match visited.get(parent.value) {
              Some(_) => break
              None => {
                visited[parent.value] = true
                result.push(parent)
                current = parent
              }
            }
        }
    }
  }
  result
}

///|
pub fn ArtboardDocument::is_ancestor(
  self : ArtboardDocument,
  ancestor : NodeID,
  descendant : NodeID,
) -> Bool {
  self.ancestors(descendant).contains(ancestor)
}

///|
pub fn ArtboardDocument::depth_of(self : ArtboardDocument, id : NodeID) -> Int {
  let entries = self.traverse()
  for i = 0; i < entries.length(); i = i + 1 {
    if entries[i].id == id {
      return entries[i].depth
    }
  }
  -1
}

///|
pub fn ArtboardDocument::nodes_intersecting(
  self : ArtboardDocument,
  rect : @math.Rect2D,
) -> Array[NodeID] {
  let result : Array[NodeID] = []
  let entries = self.traverse()
  for i = 0; i < entries.length(); i = i + 1 {
    if entries[i].world_bounds.intersects(rect) {
      result.push(entries[i].id)
    }
  }
  result
}

///|
pub fn ArtboardDocument::visible_bounds(
  self : ArtboardDocument,
) -> @math.Rect2D {
  let mut result = @math.Rect2D::empty()
  let entries = self.traverse()
  for i = 0; i < entries.length(); i = i + 1 {
    match self.nodes.get(entries[i].id.value) {
      Some(node) if node.visible =>
        result = result.union(entries[i].world_bounds)
      _ => ()
    }
  }
  result
}

///|
pub fn ArtboardDocument::node_type_name(
  self : ArtboardDocument,
  id : NodeID,
) -> String? {
  match self.nodes.get(id.value) {
    None => None
    Some(node) =>
      Some(
        match node.node_type {
          ArtboardNode(_) => "artboard"
          GroupNode(_) => "group"
          ShapeNode(_) => "shape"
          TextNode(_) => "text"
          ImageNode(_) => "image"
        },
      )
  }
}

///|
pub fn ArtboardDocument::count_visible(self : ArtboardDocument) -> Int {
  self.metrics().visible_count
}

///|
pub fn ArtboardDocument::count_locked(self : ArtboardDocument) -> Int {
  self.metrics().locked_count
}
