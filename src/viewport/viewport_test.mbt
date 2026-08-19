///|
test "viewport starts centered and round trips coordinates" {
  let viewport = Viewport::new(1000.0, 600.0, 500.0, 300.0)
  assert_eq(viewport.center, @math.Vec2::new(500.0, 300.0))
  let world = @math.Vec2::new(125.0, 210.0)
  let screen = viewport.world_to_screen(world)
  assert_true(@math.nearly_equal(screen.x, -125.0, 0.000001))
  assert_true(@math.nearly_equal(screen.y, 60.0, 0.000001))
  let recovered = viewport.screen_to_world(screen)
  assert_true(@math.nearly_equal(recovered.x, world.x, 0.000001))
  assert_true(@math.nearly_equal(recovered.y, world.y, 0.000001))
}

///|
test "viewport pan and zoom preserve cursor world point" {
  let viewport = Viewport::new(1000.0, 600.0, 500.0, 300.0)
  viewport.pan_by(@math.Vec2::new(50.0, -20.0))
  let cursor = @math.Vec2::new(320.0, 140.0)
  let before = viewport.screen_to_world(cursor)
  viewport.zoom_at(2.0, cursor)
  let after = viewport.screen_to_world(cursor)
  assert_true(@math.nearly_equal(before.x, after.x, 0.000001))
  assert_true(@math.nearly_equal(before.y, after.y, 0.000001))
  assert_eq(viewport.zoom, 2.0)
}

///|
test "viewport clamps zoom and normalizes dimensions" {
  let viewport = Viewport::new(-100.0, 0.0, -20.0, 0.0)
  assert_eq(viewport.world_rect(), @math.Rect2D::new(0.0, 0.0, 1.0, 1.0))
  viewport.zoom_at(0.0, @math.Vec2::zero())
  assert_eq(viewport.zoom, 0.01)
  viewport.zoom_at(10000.0, @math.Vec2::zero())
  assert_eq(viewport.zoom, 64.0)
}

///|
test "viewport pan direction follows screen movement" {
  let viewport = Viewport::new(100.0, 100.0, 100.0, 100.0)
  let before = viewport.screen_to_world(@math.Vec2::new(50.0, 50.0))
  viewport.pan_by(@math.Vec2::new(10.0, 0.0))
  let after = viewport.screen_to_world(@math.Vec2::new(50.0, 50.0))
  assert_true(after.x < before.x)
}
