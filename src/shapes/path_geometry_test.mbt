///|
test "path flattening preserves separate closed subpaths" {
  let outer = PathBuilder::new()
    .move_to(@math.Vec2::new(0.0, 0.0))
    .line_to(@math.Vec2::new(20.0, 0.0))
    .line_to(@math.Vec2::new(20.0, 20.0))
    .line_to(@math.Vec2::new(0.0, 20.0))
    .close_path()
    .build()
  let inner = PathBuilder::new()
    .move_to(@math.Vec2::new(5.0, 5.0))
    .line_to(@math.Vec2::new(10.0, 5.0))
    .line_to(@math.Vec2::new(10.0, 10.0))
    .close_path()
    .build()
  let path = Path::new(outer.segments + inner.segments)
  let subpaths = flatten_path(path, 0.1, 32)
  assert_eq(subpaths.length(), 2)
  assert_true(subpaths[0].length() >= 4)
  assert_true(subpaths[1].length() >= 3)
}

///|
test "closed path contains interior points but open path does not fill" {
  let closed = PathBuilder::new()
    .move_to(@math.Vec2::new(0.0, 0.0))
    .line_to(@math.Vec2::new(20.0, 0.0))
    .line_to(@math.Vec2::new(20.0, 20.0))
    .line_to(@math.Vec2::new(0.0, 20.0))
    .close_path()
    .build()
  let open = PathBuilder::new()
    .move_to(@math.Vec2::new(0.0, 0.0))
    .line_to(@math.Vec2::new(20.0, 0.0))
    .line_to(@math.Vec2::new(20.0, 20.0))
    .build()
  assert_true(path_contains_point(closed, @math.Vec2::new(10.0, 10.0), 0.1))
  assert_false(path_contains_point(closed, @math.Vec2::new(30.0, 10.0), 0.1))
  assert_false(path_contains_point(open, @math.Vec2::new(10.0, 5.0), 0.1))
}

///|
test "path distance finds a nearby line and handles a zero radius arc" {
  let line = PathBuilder::new()
    .move_to(@math.Vec2::new(0.0, 0.0))
    .line_to(@math.Vec2::new(10.0, 0.0))
    .build()
  let arc = PathBuilder::new()
    .move_to(@math.Vec2::new(0.0, 0.0))
    .arc_to(0.0, 0.0, 0.0, false, false, @math.Vec2::new(5.0, 5.0))
    .build()
  assert_true(
    path_distance_to_point(line, @math.Vec2::new(5.0, 2.0), 0.1) < 2.1,
  )
  let arc_points = flatten_path(arc, 0.1, 32)
  assert_eq(arc_points.length(), 1)
  assert_eq(
    arc_points[0][arc_points[0].length() - 1],
    @math.Vec2::new(5.0, 5.0),
  )
}

///|
test "shape geometry hit uses its path conversion" {
  let rectangle = @shapes.ShapeGeometry::rectangle(10.0, 8.0, 0.0, 0.0)
  assert_true(
    geometry_contains_point(rectangle, @math.Vec2::new(5.0, 4.0), 0.1),
  )
  assert_false(
    geometry_contains_point(rectangle, @math.Vec2::new(11.0, 4.0), 0.1),
  )
}
