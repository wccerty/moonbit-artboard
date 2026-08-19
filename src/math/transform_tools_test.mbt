///|
test "transform helpers compose and interpolate matrices" {
  let start = Matrix2D::translation(10.0, 20.0)
  let end = Matrix2D::translation(30.0, 40.0)
  let middle = Matrix2D::lerp(start, end, 0.5)
  assert_true(nearly_equal(middle.tx, 20.0, 0.000001))
  assert_true(nearly_equal(middle.ty, 30.0, 0.000001))
  assert_true(Matrix2D::identity().is_identity(0.000001))
  let points = Matrix2D::translation(5.0, 2.0).transform_points([
    Vec2::zero(),
    Vec2::unit_x(),
  ])
  assert_eq(points[0], Vec2::new(5.0, 2.0))
  assert_eq(points[1], Vec2::new(6.0, 2.0))
}
