// Shape-aware hit helper kept at the spatial package boundary.

///|
pub fn hit_test_geometry(
  geometry : @vshapes.ShapeGeometry,
  point : @math.Vec2,
  tolerance : Double,
) -> Bool {
  @vshapes.geometry_contains_point(geometry, point, tolerance)
}
