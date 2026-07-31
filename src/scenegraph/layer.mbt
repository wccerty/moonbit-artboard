// Layer models and z-ordering tree utilities.

///|
pub(all) struct Layer {
  id : NodeID
  name : String
  visible : Bool
  locked : Bool
  children : Array[NodeID]
} derive(Eq, Debug)

///|
pub fn Layer::new(id : NodeID, name : String) -> Layer {
  { id, name, visible: true, locked: false, children: [] }
}

///|
pub fn Layer::add_node(self : Layer, node_id : NodeID) -> Unit {
  self.children.push(node_id)
}

///|
pub fn Layer::remove_node(self : Layer, node_id : NodeID) -> Bool {
  let mut found = false
  let new_children : Array[NodeID] = []
  for i = 0; i < self.children.length(); i = i + 1 {
    if self.children[i] == node_id {
      found = true
    } else {
      new_children.push(self.children[i])
    }
  }
  if found {
    self.children.clear()
    for i = 0; i < new_children.length(); i = i + 1 {
      self.children.push(new_children[i])
    }
  }
  found
}

///|
pub fn Layer::move_up(self : Layer, node_id : NodeID) -> Bool {
  let len = self.children.length()
  for i = 0; i < len - 1; i = i + 1 {
    if self.children[i] == node_id {
      let tmp = self.children[i]
      self.children[i] = self.children[i + 1]
      self.children[i + 1] = tmp
      return true
    }
  }
  false
}

///|
pub fn Layer::move_down(self : Layer, node_id : NodeID) -> Bool {
  let len = self.children.length()
  for i = 1; i < len; i = i + 1 {
    if self.children[i] == node_id {
      let tmp = self.children[i]
      self.children[i] = self.children[i - 1]
      self.children[i - 1] = tmp
      return true
    }
  }
  false
}
