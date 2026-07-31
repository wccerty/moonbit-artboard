// Interactive Pen Tool State Machine & Bezier Curve Controller.

///|
pub(all) enum PenHandleMode {
  Corner
  Symmetric
  Smooth
} derive(Eq, Debug)

///|
pub(all) struct PathControlPoint {
  position : @math.Vec2
  handle_in : @math.Vec2
  handle_out : @math.Vec2
  mode : PenHandleMode
} derive(Eq, Debug)

///|
pub(all) struct PenToolState {
  points : Array[PathControlPoint]
  is_closed : Bool
  mut active_index : Int
  mut is_dragging_handle : Bool
} derive(Debug)

///|
pub fn PenToolState::new() -> PenToolState {
  { points: [], is_closed: false, active_index: -1, is_dragging_handle: false }
}

///|
pub fn PenToolState::add_point(self : PenToolState, pos : @math.Vec2) -> Unit {
  let cp = { position: pos, handle_in: pos, handle_out: pos, mode: Smooth }
  self.points.push(cp)
  self.active_index = self.points.length() - 1
}

///|
pub fn PenToolState::drag_handle(
  self : PenToolState,
  drag_pos : @math.Vec2,
) -> Unit {
  if self.active_index >= 0 && self.active_index < self.points.length() {
    let cp = self.points[self.active_index]
    let delta = drag_pos.sub(cp.position)
    let handle_out = drag_pos
    let handle_in = match cp.mode {
      Symmetric => cp.position.sub(delta)
      Smooth => {
        let len_in = cp.handle_in.distance(cp.position)
        let dir = delta.normalize().negate()
        cp.position.add(dir.scale(len_in))
      }
      Corner => cp.handle_in
    }
    self.points[self.active_index] = { ..cp, handle_in, handle_out }
    self.is_dragging_handle = true
  }
}

///|
pub fn PenToolState::to_path(self : PenToolState) -> @shapes.Path {
  let builder = @shapes.PathBuilder::new()
  let len = self.points.length()
  if len > 0 {
    ignore(builder.move_to(self.points[0].position))
    for i = 0; i < len - 1; i = i + 1 {
      let p1 = self.points[i]
      let p2 = self.points[i + 1]
      ignore(builder.cubic_to(p1.handle_out, p2.handle_in, p2.position))
    }
    if self.is_closed && len > 2 {
      let p_last = self.points[len - 1]
      let p_first = self.points[0]
      ignore(
        builder.cubic_to(p_last.handle_out, p_first.handle_in, p_first.position),
      )
      ignore(builder.close_path())
    }
  }
  builder.build()
}
