///|
test "numeric helpers clamp and compare with explicit tolerance" {
  assert_true(nearly_equal(1.0, 1.0000005, 0.000001))
  assert_false(nearly_equal(1.0, 1.00001, 0.000001))
  assert_eq(clamp_double(-2.0, 0.0, 10.0), 0.0)
  assert_eq(clamp_double(12.0, 0.0, 10.0), 10.0)
  assert_eq(clamp_double(4.0, 0.0, 10.0), 4.0)
}

///|
test "signed area distinguishes polygon winding" {
  let ccw = [
    Vec2::new(0.0, 0.0),
    Vec2::new(10.0, 0.0),
    Vec2::new(10.0, 10.0),
    Vec2::new(0.0, 10.0),
  ]
  let cw = [
    Vec2::new(0.0, 0.0),
    Vec2::new(0.0, 10.0),
    Vec2::new(10.0, 10.0),
    Vec2::new(10.0, 0.0),
  ]
  assert_eq(signed_area(ccw), 100.0)
  assert_eq(signed_area(cw), -100.0)
}

///|
test "projection clamps to an ordinary segment" {
  let result = project_point_to_segment(
    Vec2::new(6.0, 4.0),
    Vec2::new(0.0, 0.0),
    Vec2::new(10.0, 0.0),
  )
  assert_eq(result.point, Vec2::new(6.0, 0.0))
  assert_eq(result.parameter, 0.6)
  assert_eq(result.distance_squared, 16.0)
}

///|
test "projection handles a zero length segment" {
  let result = project_point_to_segment(
    Vec2::new(4.0, 3.0),
    Vec2::new(1.0, 1.0),
    Vec2::new(1.0, 1.0),
  )
  assert_eq(result.point, Vec2::new(1.0, 1.0))
  assert_eq(result.parameter, 0.0)
  assert_eq(result.distance_squared, 13.0)
}
