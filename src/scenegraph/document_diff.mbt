// Deterministic, non-mutating document comparison for history and syncing.

///|
pub(all) struct DocumentDiff {
  added : Array[NodeID]
  removed : Array[NodeID]
  modified : Array[NodeID]
  metadata_changed : Bool
} derive(Eq, Debug)

///|
pub fn DocumentDiff::empty() -> DocumentDiff {
  { added: [], removed: [], modified: [], metadata_changed: false }
}

///|
pub fn DocumentDiff::has_changes(self : DocumentDiff) -> Bool {
  self.metadata_changed ||
  !self.added.is_empty() ||
  !self.removed.is_empty() ||
  !self.modified.is_empty()
}

///|
pub fn DocumentDiff::changed_count(self : DocumentDiff) -> Int {
  self.added.length() + self.removed.length() + self.modified.length()
}

///|
pub fn DocumentDiff::contains(self : DocumentDiff, id : NodeID) -> Bool {
  self.added.contains(id) ||
  self.removed.contains(id) ||
  self.modified.contains(id)
}

///|
fn append_if_missing(ids : Array[NodeID], id : NodeID) -> Unit {
  if !ids.contains(id) {
    ids.push(id)
  }
}

///|
pub fn ArtboardDocument::diff(
  self : ArtboardDocument,
  target : ArtboardDocument,
) -> DocumentDiff {
  let added : Array[NodeID] = []
  let removed : Array[NodeID] = []
  let modified : Array[NodeID] = []
  let target_order = target.ordered_node_ids()
  let source_order = self.ordered_node_ids()
  for i = 0; i < target_order.length(); i = i + 1 {
    let id = target_order[i]
    match self.nodes.get(id.value) {
      None => added.push(id)
      Some(source_node) =>
        match target.nodes.get(id.value) {
          Some(target_node) if source_node != target_node => modified.push(id)
          _ => ()
        }
    }
  }
  for i = 0; i < source_order.length(); i = i + 1 {
    let id = source_order[i]
    if target.nodes.get(id.value) is None {
      removed.push(id)
    }
  }
  for key, node in target.nodes {
    match self.nodes.get(key) {
      None => append_if_missing(added, node.id)
      Some(source_node) if source_node != node =>
        append_if_missing(modified, node.id)
      _ => ()
    }
  }
  for key, node in self.nodes {
    if target.nodes.get(key) is None {
      append_if_missing(removed, node.id)
    }
  }
  {
    added,
    removed,
    modified,
    metadata_changed: self.title != target.title ||
    self.width != target.width ||
    self.height != target.height,
  }
}

///|
pub fn ArtboardDocument::same_content(
  self : ArtboardDocument,
  other : ArtboardDocument,
) -> Bool {
  !self.diff(other).has_changes()
}

///|
pub fn ArtboardDocument::added_since(
  self : ArtboardDocument,
  baseline : ArtboardDocument,
) -> Array[NodeID] {
  baseline.diff(self).added
}

///|
pub fn ArtboardDocument::removed_since(
  self : ArtboardDocument,
  baseline : ArtboardDocument,
) -> Array[NodeID] {
  baseline.diff(self).removed
}

///|
pub fn ArtboardDocument::modified_since(
  self : ArtboardDocument,
  baseline : ArtboardDocument,
) -> Array[NodeID] {
  baseline.diff(self).modified
}
