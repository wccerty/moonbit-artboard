///|
test "path measurement computes length, area, and centroid" {
  let path = @shapes.PathBuilder::new()
    .move_to(@math.Vec2::new(0.0, 0.0))
    .line_to(@math.Vec2::new(10.0, 0.0))
    .line_to(@math.Vec2::new(10.0, 10.0))
    .line_to(@math.Vec2::new(0.0, 10.0))
    .close_path()
    .build()
  let measurement = measure_path(path, 0.01, 64)
  assert_true(@math.nearly_equal(measurement.length, 40.0, 0.01))
  assert_true(@math.nearly_equal(measurement.area.abs(), 100.0, 0.01))
  assert_true(@math.nearly_equal(measurement.centroid.x, 5.0, 0.01))
  assert_true(@math.nearly_equal(measurement.centroid.y, 5.0, 0.01))
}

///|
test "path sampling returns stable points and tangents" {
  let path = @shapes.PathBuilder::new()
    .move_to(@math.Vec2::new(0.0, 0.0))
    .line_to(@math.Vec2::new(10.0, 0.0))
    .build()
  let start = point_at_length(path, 0.0, 0.01, 16)
  let middle = point_at_length(path, 5.0, 0.01, 16)
  let tangent = tangent_at_length(path, 5.0, 0.01, 16)
  assert_true(@math.nearly_equal(start.x, 0.0, 0.01))
  assert_true(@math.nearly_equal(middle.x, 5.0, 0.01))
  assert_true(@math.nearly_equal(tangent.x, 1.0, 0.01))
  assert_true(@math.nearly_equal(tangent.y, 0.0, 0.01))
}
