// Responsive Layout Constraints Engine (Figma-style Pinning & Scale rules).

///|
pub(all) enum HorizontalConstraint {
  Left
  Right
  Center
  Scale
  LeftRight
} derive(Eq, Debug)

///|
pub(all) enum VerticalConstraint {
  Top
  Bottom
  Center
  Scale
  TopBottom
} derive(Eq, Debug)

///|
pub(all) struct LayoutConstraint {
  horizontal : HorizontalConstraint
  vertical : VerticalConstraint
} derive(Eq, Debug)

///|
pub fn apply_layout_constraints(
  node_bounds : @math.Rect2D,
  old_parent_size : @math.Vec2,
  new_parent_size : @math.Vec2,
  constraint : LayoutConstraint,
) -> @math.Rect2D {
  let dw = new_parent_size.x - old_parent_size.x
  let dh = new_parent_size.y - old_parent_size.y

  let mut min_x = node_bounds.min_x
  let mut max_x = node_bounds.max_x
  let mut min_y = node_bounds.min_y
  let mut max_y = node_bounds.max_y

  match constraint.horizontal {
    Left => ()
    Right => {
      min_x = min_x + dw
      max_x = max_x + dw
    }
    Center => {
      let offset = dw * 0.5
      min_x = min_x + offset
      max_x = max_x + offset
    }
    Scale =>
      if old_parent_size.x > 0.0 {
        let sx = new_parent_size.x / old_parent_size.x
        min_x = min_x * sx
        max_x = max_x * sx
      }
    LeftRight => max_x = max_x + dw
  }

  match constraint.vertical {
    Top => ()
    Bottom => {
      min_y = min_y + dh
      max_y = max_y + dh
    }
    Center => {
      let offset = dh * 0.5
      min_y = min_y + offset
      max_y = max_y + offset
    }
    Scale =>
      if old_parent_size.y > 0.0 {
        let sy = new_parent_size.y / old_parent_size.y
        min_y = min_y * sy
        max_y = max_y * sy
      }
    TopBottom => max_y = max_y + dh
  }

  @math.Rect2D::new(min_x, min_y, max_x, max_y)
}
