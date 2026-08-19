// Backend-neutral drawing operations.

///|
pub(all) enum RenderOp {
  Save
  Restore
  SetTransform(@math.Matrix2D)
  SetOpacity(Double)
  DrawPath(@shapes.Path, @shapes.Style)
  DrawText(String, @math.Vec2, Double, String, @shapes.Style)
  DrawImage(String, @math.Rect2D, Double)
} derive(Eq, Debug)
