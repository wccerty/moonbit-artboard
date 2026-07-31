// Interactive Selection Handles (Resize 8-points & Rotation Control).

///|
pub(all) enum HandleKind {
  NorthWest
  North
  NorthEast
  East
  SouthEast
  South
  SouthWest
  West
  Rotation
} derive(Eq, Debug)

///|
pub(all) struct TransformHandle {
  kind : HandleKind
  position : @math.Vec2
} derive(Eq, Debug)

///|
pub fn get_transform_handles(bounds : @math.Rect2D) -> Array[TransformHandle] {
  if bounds.is_empty() {
    []
  } else {
    let min_x = bounds.min_x
    let min_y = bounds.min_y
    let max_x = bounds.max_x
    let max_y = bounds.max_y
    let mid_x = (min_x + max_x) * 0.5
    let mid_y = (min_y + max_y) * 0.5

    [
      { kind: NorthWest, position: @math.Vec2::new(min_x, min_y) },
      { kind: North, position: @math.Vec2::new(mid_x, min_y) },
      { kind: NorthEast, position: @math.Vec2::new(max_x, min_y) },
      { kind: East, position: @math.Vec2::new(max_x, mid_y) },
      { kind: SouthEast, position: @math.Vec2::new(max_x, max_y) },
      { kind: South, position: @math.Vec2::new(mid_x, max_y) },
      { kind: SouthWest, position: @math.Vec2::new(min_x, max_y) },
      { kind: West, position: @math.Vec2::new(min_x, mid_y) },
      { kind: Rotation, position: @math.Vec2::new(mid_x, min_y - 25.0) },
    ]
  }
}
