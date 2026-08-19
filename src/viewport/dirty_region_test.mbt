///|
test "dirty region tracks empty, overlapping, and disjoint changes" {
  let region = DirtyRegion::empty()
  assert_false(region.needs_redraw())
  region.mark(@math.Rect2D::new(0.0, 0.0, 10.0, 10.0))
  assert_true(region.needs_redraw())
  region.mark(@math.Rect2D::new(5.0, 5.0, 20.0, 20.0))
  assert_true(region.bounds.contains_point(@math.Vec2::new(19.0, 19.0)))
  region.mark(@math.Rect2D::new(100.0, 100.0, 110.0, 110.0))
  assert_false(region.full_redraw)
}

///|
test "dirty region escalates after too many disjoint regions" {
  let region = DirtyRegion::empty()
  for i = 0; i < 10; i = i + 1 {
    let x = i.to_double() * 100.0
    region.mark(@math.Rect2D::new(x, 0.0, x + 10.0, 10.0))
  }
  assert_true(region.full_redraw)
  let other = DirtyRegion::empty()
  other.mark(@math.Rect2D::new(-5.0, -5.0, 5.0, 5.0))
  region.merge(other)
  assert_true(region.needs_redraw())
}
