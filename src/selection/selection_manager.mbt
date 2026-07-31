// Selection state management and multi-selection bounding box computation.

///|
pub(all) struct SelectionManager {
  selected_ids : Array[@scenegraph.NodeID]
} derive(Debug)

///|
pub fn SelectionManager::new() -> SelectionManager {
  { selected_ids: [] }
}

///|
pub fn SelectionManager::clear(self : SelectionManager) -> Unit {
  self.selected_ids.clear()
}

///|
pub fn SelectionManager::is_selected(
  self : SelectionManager,
  id : @scenegraph.NodeID,
) -> Bool {
  for i = 0; i < self.selected_ids.length(); i = i + 1 {
    if self.selected_ids[i] == id {
      return true
    }
  }
  false
}

///|
pub fn SelectionManager::select(
  self : SelectionManager,
  id : @scenegraph.NodeID,
) -> Unit {
  if !self.is_selected(id) {
    self.selected_ids.push(id)
  }
}

///|
pub fn SelectionManager::deselect(
  self : SelectionManager,
  id : @scenegraph.NodeID,
) -> Unit {
  let new_ids : Array[@scenegraph.NodeID] = []
  for i = 0; i < self.selected_ids.length(); i = i + 1 {
    if !(self.selected_ids[i] == id) {
      new_ids.push(self.selected_ids[i])
    }
  }
  self.selected_ids.clear()
  for i = 0; i < new_ids.length(); i = i + 1 {
    self.selected_ids.push(new_ids[i])
  }
}

///|
pub fn SelectionManager::toggle(
  self : SelectionManager,
  id : @scenegraph.NodeID,
) -> Unit {
  if self.is_selected(id) {
    self.deselect(id)
  } else {
    self.select(id)
  }
}

///|
pub fn SelectionManager::count(self : SelectionManager) -> Int {
  self.selected_ids.length()
}

///|
pub fn SelectionManager::get_bounding_box(
  self : SelectionManager,
  doc : @scenegraph.ArtboardDocument,
) -> @math.Rect2D {
  if self.selected_ids.is_empty() {
    @math.Rect2D::empty()
  } else {
    let mut rect = @math.Rect2D::empty()
    for i = 0; i < self.selected_ids.length(); i = i + 1 {
      rect = rect.union(doc.get_world_bounds(self.selected_ids[i]))
    }
    rect
  }
}
