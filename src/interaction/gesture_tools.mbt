// Additional policy helpers kept separate from the pointer state machine.

///|
pub(all) enum DragAxis {
  Free
  Horizontal
  Vertical
} derive(Eq, Debug)

///|
pub(all) enum HandleCursor {
  Default
  Move
  ResizeNorthWestSouthEast
  ResizeNorthEastSouthWest
  ResizeHorizontal
  ResizeVertical
  Rotate
} derive(Eq, Debug)

///|
pub fn constrain_delta(delta : @math.Vec2, axis : DragAxis) -> @math.Vec2 {
  match axis {
    Free => delta
    Horizontal => @math.Vec2::new(delta.x, 0.0)
    Vertical => @math.Vec2::new(0.0, delta.y)
  }
}

///|
pub fn movement_distance(delta : @math.Vec2) -> Double {
  delta.length()
}

///|
pub fn should_start_drag(
  start : @math.Vec2,
  current : @math.Vec2,
  threshold : Double,
) -> Bool {
  let safe_threshold = if threshold < 0.0 { 0.0 } else { threshold }
  movement_distance(current.sub(start)) >= safe_threshold
}

///|
pub fn clamp_point_to_rect(
  point : @math.Vec2,
  bounds : @math.Rect2D,
) -> @math.Vec2 {
  @math.Vec2::new(
    if point.x < bounds.min_x {
      bounds.min_x
    } else if point.x > bounds.max_x {
      bounds.max_x
    } else {
      point.x
    },
    if point.y < bounds.min_y {
      bounds.min_y
    } else if point.y > bounds.max_y {
      bounds.max_y
    } else {
      point.y
    },
  )
}

///|
pub fn clamp_rect_to_rect(
  rect : @math.Rect2D,
  bounds : @math.Rect2D,
) -> @math.Rect2D {
  if rect.is_empty() || bounds.is_empty() {
    @math.Rect2D::empty()
  } else {
    let width = rect.width()
    let height = rect.height()
    let max_x = bounds.max_x - width
    let max_y = bounds.max_y - height
    let min_x = if rect.min_x < bounds.min_x {
      bounds.min_x
    } else if rect.min_x > max_x {
      max_x
    } else {
      rect.min_x
    }
    let min_y = if rect.min_y < bounds.min_y {
      bounds.min_y
    } else if rect.min_y > max_y {
      max_y
    } else {
      rect.min_y
    }
    @math.Rect2D::new(min_x, min_y, min_x + width, min_y + height)
  }
}

///|
pub fn preserve_aspect_size(
  width : Double,
  height : Double,
  target_width : Double,
  target_height : Double,
) -> @math.Vec2 {
  let safe_width = if width.abs() < 0.000000000001 { 1.0 } else { width.abs() }
  let safe_height = if height.abs() < 0.000000000001 {
    1.0
  } else {
    height.abs()
  }
  let ratio = safe_width / safe_height
  let width_candidate = target_width.abs()
  let height_candidate = target_height.abs()
  if width_candidate / height_candidate > ratio {
    @math.Vec2::new(height_candidate * ratio, height_candidate)
  } else {
    @math.Vec2::new(width_candidate, width_candidate / ratio)
  }
}

///|
pub fn symmetric_resize(
  bounds : @math.Rect2D,
  delta : @math.Vec2,
) -> @math.Rect2D {
  if bounds.is_empty() {
    bounds
  } else {
    let center = bounds.center()
    let half_width = bounds.width() * 0.5 + delta.x.abs()
    let half_height = bounds.height() * 0.5 + delta.y.abs()
    @math.Rect2D::new(
      center.x - half_width,
      center.y - half_height,
      center.x + half_width,
      center.y + half_height,
    )
  }
}

///|
pub fn cursor_for_handle(handle : @selection.HandleKind) -> HandleCursor {
  match handle {
    @selection.NorthWest | @selection.SouthEast => ResizeNorthWestSouthEast
    @selection.NorthEast | @selection.SouthWest => ResizeNorthEastSouthWest
    @selection.North | @selection.South => ResizeVertical
    @selection.East | @selection.West => ResizeHorizontal
    @selection.Rotation => Rotate
  }
}

///|
pub fn safe_zoom_factor(delta_y : Double) -> Double {
  if delta_y == 0.0 {
    1.0
  } else if delta_y > 0.0 {
    1.1
  } else {
    0.9
  }
}
