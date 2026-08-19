// Pure geometry helpers used by pointer gestures and transform handles.

///|
pub fn normalized_marquee(start : @math.Vec2, end : @math.Vec2) -> @math.Rect2D {
  @math.Rect2D::new(
    if start.x < end.x {
      start.x
    } else {
      end.x
    },
    if start.y < end.y {
      start.y
    } else {
      end.y
    },
    if start.x > end.x {
      start.x
    } else {
      end.x
    },
    if start.y > end.y {
      start.y
    } else {
      end.y
    },
  )
}

///|
pub fn marquee_contains_or_intersects(
  marquee : @math.Rect2D,
  bounds : @math.Rect2D,
  contain : Bool,
) -> Bool {
  if marquee.is_empty() || bounds.is_empty() {
    false
  } else if contain {
    marquee.contains_rect(bounds)
  } else {
    marquee.intersects(bounds)
  }
}

///|
pub fn translated_matrix(
  matrix : @math.Matrix2D,
  delta : @math.Vec2,
) -> @math.Matrix2D {
  matrix.with_translation(
    @math.Vec2::new(matrix.tx + delta.x, matrix.ty + delta.y),
  )
}

///|
pub fn snap_scalar(value : Double, spacing : Double) -> Double {
  let safe_spacing = if spacing.abs() < 0.000000000001 {
    1.0
  } else {
    spacing.abs()
  }
  let normalized = value / safe_spacing
  let bucket = if normalized >= 0.0 {
    (normalized + 0.5).to_int()
  } else {
    (normalized - 0.5).to_int()
  }
  bucket.to_double() * safe_spacing
}

///|
pub fn snapped_delta(delta : @math.Vec2, spacing : Double) -> @math.Vec2 {
  @math.Vec2::new(snap_scalar(delta.x, spacing), snap_scalar(delta.y, spacing))
}

///|
pub fn rotation_delta(
  center : @math.Vec2,
  start : @math.Vec2,
  current : @math.Vec2,
) -> Double {
  let start_vector = start.sub(center)
  let current_vector = current.sub(center)
  current_vector.angle() - start_vector.angle()
}

///|
pub fn resize_bounds(
  bounds : @math.Rect2D,
  handle : @selection.HandleKind,
  delta : @math.Vec2,
  keep_aspect : Bool,
  from_center : Bool,
) -> @math.Rect2D {
  if bounds.is_empty() {
    bounds
  } else {
    let mut min_x = bounds.min_x
    let mut min_y = bounds.min_y
    let mut max_x = bounds.max_x
    let mut max_y = bounds.max_y
    match handle {
      @selection.NorthWest => {
        min_x = min_x + delta.x
        min_y = min_y + delta.y
      }
      @selection.North => min_y = min_y + delta.y
      @selection.NorthEast => {
        max_x = max_x + delta.x
        min_y = min_y + delta.y
      }
      @selection.East => max_x = max_x + delta.x
      @selection.SouthEast => {
        max_x = max_x + delta.x
        max_y = max_y + delta.y
      }
      @selection.South => max_y = max_y + delta.y
      @selection.SouthWest => {
        min_x = min_x + delta.x
        max_y = max_y + delta.y
      }
      @selection.West => min_x = min_x + delta.x
      @selection.Rotation => return bounds
    }
    let normalized = @math.Rect2D::new(
      if min_x < max_x {
        min_x
      } else {
        max_x
      },
      if min_y < max_y {
        min_y
      } else {
        max_y
      },
      if min_x > max_x {
        min_x
      } else {
        max_x
      },
      if min_y > max_y {
        min_y
      } else {
        max_y
      },
    )
    let corrected = if keep_aspect {
      let source_ratio = bounds.width() / bounds.height()
      let width = normalized.width()
      let height = normalized.height()
      if width / height > source_ratio {
        let target_width = height * source_ratio
        @math.Rect2D::new(
          normalized.center().x - target_width * 0.5,
          normalized.min_y,
          normalized.center().x + target_width * 0.5,
          normalized.max_y,
        )
      } else {
        let target_height = width / source_ratio
        @math.Rect2D::new(
          normalized.min_x,
          normalized.center().y - target_height * 0.5,
          normalized.max_x,
          normalized.center().y + target_height * 0.5,
        )
      }
    } else {
      normalized
    }
    if from_center {
      let center = bounds.center()
      let half_width = corrected.width() * 0.5
      let half_height = corrected.height() * 0.5
      @math.Rect2D::new(
        center.x - half_width,
        center.y - half_height,
        center.x + half_width,
        center.y + half_height,
      )
    } else {
      corrected
    }
  }
}
