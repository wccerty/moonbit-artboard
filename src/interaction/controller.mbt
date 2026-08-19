// State machine for editor pointer interactions.

///|
pub(all) struct InteractionController {
  mut current_mode : InteractionMode
  mut last_screen_position : @math.Vec2
  mut drag_start_world : @math.Vec2
  mut drag_node : @scenegraph.NodeID?
  mut drag_transform : @math.Matrix2D
  mut marquee_start : @math.Vec2?
  mut last_marquee : @math.Rect2D?
  mut selection : @selection.SelectionManager
  mut viewport_state : @viewport.Viewport
} derive(Debug)

///|
pub fn InteractionController::new(
  viewport : @viewport.Viewport,
) -> InteractionController {
  {
    current_mode: Idle,
    last_screen_position: @math.Vec2::zero(),
    drag_start_world: @math.Vec2::zero(),
    drag_node: None,
    drag_transform: @math.Matrix2D::identity(),
    marquee_start: None,
    last_marquee: None,
    selection: @selection.SelectionManager::new(),
    viewport_state: viewport,
  }
}

///|
pub fn InteractionController::mode(
  self : InteractionController,
) -> InteractionMode {
  self.current_mode
}

///|
pub fn InteractionController::viewport(
  self : InteractionController,
) -> @viewport.Viewport {
  self.viewport_state
}

///|
pub fn InteractionController::selection_count(
  self : InteractionController,
) -> Int {
  self.selection.count()
}

///|
pub fn InteractionController::is_selected(
  self : InteractionController,
  id : @scenegraph.NodeID,
) -> Bool {
  self.selection.is_selected(id)
}

///|
pub fn InteractionController::marquee(
  self : InteractionController,
) -> @math.Rect2D? {
  self.last_marquee
}

///|
fn InteractionController::finish(
  self : InteractionController,
  consumed : Bool,
  hit : @scenegraph.NodeID?,
  marquee : @math.Rect2D?,
  selection_changed : Bool,
  viewport_changed : Bool,
) -> InteractionResult {
  interaction_result(
    consumed,
    hit,
    marquee,
    selection_changed,
    viewport_changed,
    self.current_mode,
  )
}

///|
pub fn InteractionController::pointer_down(
  self : InteractionController,
  document : @scenegraph.ArtboardDocument,
  event : PointerEvent,
) -> InteractionResult {
  self.last_screen_position = event.screen_position
  let world_position = self.viewport_state.screen_to_world(
    event.screen_position,
  )
  match event.button {
    Middle => {
      self.current_mode = Panning
      self.finish(true, None, None, false, false)
    }
    Secondary => self.finish(false, None, None, false, false)
    Primary =>
      match @spatial.document_hit_test(document, world_position) {
        Some(id) => {
          let mut selection_changed = false
          if event.modifiers.shift {
            self.selection.toggle(id)
            selection_changed = true
          } else if !self.selection.is_selected(id) {
            self.selection.clear()
            self.selection.select(id)
            selection_changed = true
          }
          self.current_mode = Translating
          self.drag_start_world = world_position
          self.drag_node = Some(id)
          self.drag_transform = match document.get_node(id) {
            Some(node) => node.transform
            None => @math.Matrix2D::identity()
          }
          self.finish(true, Some(id), None, selection_changed, false)
        }
        None => {
          if !event.modifiers.shift {
            self.selection.clear()
          }
          self.current_mode = Marquee
          self.marquee_start = Some(world_position)
          self.last_marquee = None
          self.finish(true, None, None, !event.modifiers.shift, false)
        }
      }
  }
}

///|
pub fn InteractionController::pointer_move(
  self : InteractionController,
  document : @scenegraph.ArtboardDocument,
  event : PointerEvent,
) -> InteractionResult {
  let previous = self.last_screen_position
  self.last_screen_position = event.screen_position
  match self.current_mode {
    Idle => self.finish(false, None, None, false, false)
    Panning => {
      self.viewport_state.pan_by(event.screen_position.sub(previous))
      self.finish(true, None, None, false, true)
    }
    Marquee =>
      match self.marquee_start {
        Some(start) => {
          let current = self.viewport_state.screen_to_world(
            event.screen_position,
          )
          let rect = normalized_marquee(start, current)
          self.last_marquee = Some(rect)
          self.finish(true, None, Some(rect), false, false)
        }
        None => self.finish(true, None, None, false, false)
      }
    Translating =>
      match self.drag_node {
        None => self.finish(true, None, None, false, false)
        Some(id) => {
          let current = self.viewport_state.screen_to_world(
            event.screen_position,
          )
          let delta = current.sub(self.drag_start_world)
          match document.get_node(id) {
            Some(node) =>
              document.update_node({
                ..node,
                transform: translated_matrix(self.drag_transform, delta),
              })
            None => ()
          }
          self.finish(true, Some(id), None, false, false)
        }
      }
  }
}

///|
pub fn InteractionController::pointer_up(
  self : InteractionController,
  document : @scenegraph.ArtboardDocument,
  event : PointerEvent,
) -> InteractionResult {
  let world_position = self.viewport_state.screen_to_world(
    event.screen_position,
  )
  match self.current_mode {
    Marquee => {
      let rect = match self.marquee_start {
        Some(start) => normalized_marquee(start, world_position)
        None => @math.Rect2D::empty()
      }
      self.last_marquee = Some(rect)
      self.selection.clear()
      let entries = document.traverse()
      for i = 0; i < entries.length(); i = i + 1 {
        let entry = entries[i]
        match document.get_node(entry.id) {
          Some(node) =>
            match node.node_type {
              @scenegraph.GroupNode(_) => ()
              _ =>
                if node.visible &&
                  !node.locked &&
                  marquee_contains_or_intersects(
                    rect,
                    entry.world_bounds,
                    false,
                  ) {
                  self.selection.select(entry.id)
                }
            }
          None => ()
        }
      }
      self.current_mode = Idle
      self.marquee_start = None
      self.finish(true, None, Some(rect), true, false)
    }
    Translating => {
      let hit = self.drag_node
      self.current_mode = Idle
      self.drag_node = None
      self.marquee_start = None
      self.finish(true, hit, None, false, false)
    }
    Panning => {
      self.current_mode = Idle
      self.finish(true, None, None, false, false)
    }
    Idle => self.finish(false, None, None, false, false)
  }
}

///|
pub fn InteractionController::wheel(
  self : InteractionController,
  event : WheelEvent,
) -> InteractionResult {
  if event.delta_y == 0.0 {
    self.finish(false, None, None, false, false)
  } else {
    let factor = if event.delta_y > 0.0 { 1.1 } else { 0.9 }
    self.viewport_state.zoom_at(factor, event.screen_position)
    self.finish(true, None, None, false, true)
  }
}

///|
pub fn InteractionController::cancel(self : InteractionController) -> Unit {
  self.current_mode = Idle
  self.drag_node = None
  self.marquee_start = None
  self.last_marquee = None
}
