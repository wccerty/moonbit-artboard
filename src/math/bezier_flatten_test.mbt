///|
test "cubic flattening preserves endpoints and produces a bounded polyline" {
  let start = Vec2::new(0.0, 0.0)
  let end = Vec2::new(10.0, 0.0)
  let curve = CubicBezier::new(
    start,
    Vec2::new(0.0, 12.0),
    Vec2::new(10.0, 12.0),
    end,
  )
  let points = flatten_cubic(curve, 0.25, 8)
  assert_eq(points[0], start)
  assert_eq(points[points.length() - 1], end)
  assert_true(points.length() > 2)
  assert_true(points.length() <= 257)
}

///|
test "quadratic flattening preserves endpoints" {
  let start = Vec2::new(0.0, 0.0)
  let end = Vec2::new(8.0, 0.0)
  let points = flatten_quadratic(
    QuadraticBezier::new(start, Vec2::new(4.0, 10.0), end),
    0.5,
    6,
  )
  assert_eq(points[0], start)
  assert_eq(points[points.length() - 1], end)
  assert_true(points.length() > 2)
}
