// Math package unit tests

///|
test "Vector2D operations" {
  let v1 = Vec2::new(3.0, 4.0)
  inspect(v1.length(), content="5")

  let norm = v1.normalize()
  inspect((norm.x - 0.6).abs() < 0.000001, content="true")
  inspect((norm.y - 0.8).abs() < 0.000001, content="true")

  let dot = v1.dot(Vec2::new(1.0, 2.0))
  inspect(dot, content="11")
}

///|
test "Rect2D bounds unions and intersections" {
  let r1 = Rect2D::new(0.0, 0.0, 10.0, 10.0)
  let r2 = Rect2D::new(5.0, 5.0, 15.0, 15.0)

  let inter = r1.intersection(r2)
  inspect(inter.min_x, content="5")
  inspect(inter.min_y, content="5")
  inspect(inter.max_x, content="10")
  inspect(inter.max_y, content="10")

  let un = r1.union(r2)
  inspect(un.min_x, content="0")
  inspect(un.max_x, content="15")
}

///|
test "Matrix2D affine transformations" {
  let t = Matrix2D::translation(10.0, 20.0)
  let p = t.transform_point(Vec2::new(5.0, 5.0))
  inspect(p, content="{x: 15, y: 25}")

  let s = Matrix2D::scaling(2.0, 3.0)
  let p2 = s.transform_point(Vec2::new(5.0, 5.0))
  inspect(p2, content="{x: 10, y: 15}")
}

///|
test "Cubic Bezier curve bounds" {
  let cb = CubicBezier::new(
    Vec2::new(0.0, 0.0),
    Vec2::new(0.0, 10.0),
    Vec2::new(10.0, 10.0),
    Vec2::new(10.0, 0.0),
  )
  let b = cb.bounds()
  inspect(b.min_x, content="0")
  inspect(b.max_x, content="10")
}

///|
test "Matrix4x4 3D transformations" {
  let m1 = Matrix4x4::translation(10.0, 20.0, 30.0)
  let m2 = Matrix4x4::scaling(2.0, 2.0, 2.0)
  let combined = m1.multiply(m2)
  inspect(combined.m03, content="10")
  inspect(combined.m00, content="2")
}

///|
test "Ear Clipping Polygon Triangulation" {
  let poly = [
    Vec2::new(0.0, 0.0),
    Vec2::new(10.0, 0.0),
    Vec2::new(10.0, 10.0),
    Vec2::new(0.0, 10.0),
  ]
  let triangles = triangulate_polygon(poly)
  inspect(triangles.length(), content="2")
}

///|
test "Catmull-Rom Spline Interpolation" {
  let pts = [
    Vec2::new(0.0, 0.0),
    Vec2::new(10.0, 0.0),
    Vec2::new(20.0, 10.0),
    Vec2::new(30.0, 10.0),
  ]
  let interp = interpolate_catmull_rom_spline(pts, 4)
  inspect(interp.length() > 4, content="true")
}
