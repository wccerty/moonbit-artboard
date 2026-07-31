// UndoManager stack management for document history tracking.

///|
pub(all) struct UndoManager {
  undo_stack : Array[EditCommand]
  redo_stack : Array[EditCommand]
  max_depth : Int
} derive(Debug)

///|
pub fn UndoManager::new(max_depth? : Int = 100) -> UndoManager {
  { undo_stack: [], redo_stack: [], max_depth }
}

///|
pub fn UndoManager::push(
  self : UndoManager,
  cmd : EditCommand,
  doc : @scenegraph.ArtboardDocument,
) -> Unit {
  cmd.execute(doc)
  self.undo_stack.push(cmd)
  self.redo_stack.clear()
  if self.undo_stack.length() > self.max_depth {
    ignore(self.undo_stack.remove(0))
  }
}

///|
pub fn UndoManager::can_undo(self : UndoManager) -> Bool {
  !self.undo_stack.is_empty()
}

///|
pub fn UndoManager::can_redo(self : UndoManager) -> Bool {
  !self.redo_stack.is_empty()
}

///|
pub fn UndoManager::undo(
  self : UndoManager,
  doc : @scenegraph.ArtboardDocument,
) -> Bool {
  if self.undo_stack.is_empty() {
    false
  } else {
    let cmd = self.undo_stack.unsafe_pop()
    cmd.undo(doc)
    self.redo_stack.push(cmd)
    true
  }
}

///|
pub fn UndoManager::redo(
  self : UndoManager,
  doc : @scenegraph.ArtboardDocument,
) -> Bool {
  if self.redo_stack.is_empty() {
    false
  } else {
    let cmd = self.redo_stack.unsafe_pop()
    cmd.execute(doc)
    self.undo_stack.push(cmd)
    true
  }
}

///|
pub fn UndoManager::clear(self : UndoManager) -> Unit {
  self.undo_stack.clear()
  self.redo_stack.clear()
}
