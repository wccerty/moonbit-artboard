// ArtboardDocument scene graph engine and tree transformation manager.

///|
pub(all) struct ArtboardDocument {
  title : String
  nodes : Map[String, Node]
  root_ids : Array[NodeID]
  mut width : Double
  mut height : Double
} derive(Debug)

///|
pub fn ArtboardDocument::new(
  title : String,
  w : Double,
  h : Double,
) -> ArtboardDocument {
  { title, nodes: Map([]), root_ids: [], width: w, height: h }
}

///|
pub fn ArtboardDocument::add_node(
  self : ArtboardDocument,
  node : Node,
  parent_id : NodeID?,
) -> Unit {
  let n = { ..node, parent_id, }
  self.nodes[n.id.value] = n

  match parent_id {
    None => self.root_ids.push(n.id)
    Some(pid) =>
      match self.nodes.get(pid.value) {
        Some(parent_node) =>
          match parent_node.node_type {
            GroupNode(children) => children.push(n.id)
            _ => ()
          }
        None => self.root_ids.push(n.id)
      }
  }
}

///|
pub fn ArtboardDocument::get_node(
  self : ArtboardDocument,
  id : NodeID,
) -> Node? {
  self.nodes.get(id.value)
}

///|
pub fn ArtboardDocument::update_node(
  self : ArtboardDocument,
  node : Node,
) -> Unit {
  self.nodes[node.id.value] = node
}

///|
pub fn ArtboardDocument::remove_node(
  self : ArtboardDocument,
  id : NodeID,
) -> Bool {
  match self.nodes.get(id.value) {
    None => false
    Some(node) => {
      // Remove from parent children if any
      match node.parent_id {
        Some(pid) =>
          match self.nodes.get(pid.value) {
            Some(parent_node) =>
              match parent_node.node_type {
                GroupNode(children) => {
                  let new_c : Array[NodeID] = []
                  for i = 0; i < children.length(); i = i + 1 {
                    if !(children[i] == id) {
                      new_c.push(children[i])
                    }
                  }
                  self.nodes[pid.value] = {
                    ..parent_node,
                    node_type: GroupNode(new_c),
                  }
                }
                _ => ()
              }
            None => ()
          }
        None => {
          let new_roots : Array[NodeID] = []
          for i = 0; i < self.root_ids.length(); i = i + 1 {
            if !(self.root_ids[i] == id) {
              new_roots.push(self.root_ids[i])
            }
          }
          self.root_ids.clear()
          for i = 0; i < new_roots.length(); i = i + 1 {
            self.root_ids.push(new_roots[i])
          }
        }
      }

      // If group, recursively remove children
      match node.node_type {
        GroupNode(children) =>
          for i = 0; i < children.length(); i = i + 1 {
            ignore(self.remove_node(children[i]))
          }
        _ => ()
      }

      self.nodes.remove(id.value)
      true
    }
  }
}

///|
pub fn ArtboardDocument::get_world_matrix(
  self : ArtboardDocument,
  id : NodeID,
) -> @math.Matrix2D {
  match self.nodes.get(id.value) {
    None => @math.Matrix2D::identity()
    Some(node) =>
      match node.parent_id {
        None => node.transform
        Some(pid) => self.get_world_matrix(pid).multiply(node.transform)
      }
  }
}

///|
pub fn ArtboardDocument::get_world_bounds(
  self : ArtboardDocument,
  id : NodeID,
) -> @math.Rect2D {
  match self.nodes.get(id.value) {
    None => @math.Rect2D::empty()
    Some(node) =>
      match node.node_type {
        GroupNode(children) => {
          let mut rect = @math.Rect2D::empty()
          for i = 0; i < children.length(); i = i + 1 {
            rect = rect.union(self.get_world_bounds(children[i]))
          }
          rect
        }
        _ => {
          let local_b = node.local_bounds()
          let world_m = self.get_world_matrix(id)
          world_m.transform_bounds(local_b)
        }
      }
  }
}

///|
pub fn ArtboardDocument::group_nodes(
  self : ArtboardDocument,
  node_ids : Array[NodeID],
) -> NodeID? {
  if node_ids.length() < 2 {
    None
  } else {
    let group_id = NodeID::generate("group")
    let group_node = Node::create_group(group_id, "Group", node_ids)
    self.add_node(group_node, None)

    for i = 0; i < node_ids.length(); i = i + 1 {
      let nid = node_ids[i]
      match self.nodes.get(nid.value) {
        Some(child) =>
          self.nodes[nid.value] = { ..child, parent_id: Some(group_id) }
        None => ()
      }
    }
    Some(group_id)
  }
}

///|
pub fn ArtboardDocument::ungroup_node(
  self : ArtboardDocument,
  group_id : NodeID,
) -> Array[NodeID] {
  match self.nodes.get(group_id.value) {
    None => []
    Some(group_node) =>
      match group_node.node_type {
        GroupNode(children) => {
          for i = 0; i < children.length(); i = i + 1 {
            let cid = children[i]
            match self.nodes.get(cid.value) {
              Some(child) =>
                self.nodes[cid.value] = {
                  ..child,
                  parent_id: group_node.parent_id,
                }
              None => ()
            }
          }
          ignore(self.remove_node(group_id))
          children
        }
        _ => []
      }
  }
}
