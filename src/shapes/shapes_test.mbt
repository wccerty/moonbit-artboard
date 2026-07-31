// Shapes unit tests

///|
test "RGBA hex parsing and blending" {
  let c1 = RGBA::from_hex("#FF0000")
  inspect(c1.r, content="1")
  inspect(c1.g, content="0")
  inspect(c1.b, content="0")

  let hex = c1.to_hex()
  inspect(hex, content="#ff0000")

  let blended = c1.blend(RGBA::new(0.0, 0.0, 1.0, 0.5))
  inspect(blended.to_hex(), content="#800080")
}

///|
test "Primitive shapes path generation" {
  let rect = ShapeGeometry::Rectangle({
    width: 100.0,
    height: 50.0,
    rx: 0.0,
    ry: 0.0,
  })
  let ellipse = ShapeGeometry::Ellipse({ radius_x: 40.0, radius_y: 30.0 })
  let poly = ShapeGeometry::Polygon({ sides: 5, radius: 50.0 })
  let star = ShapeGeometry::Star({
    points: 5,
    inner_radius: 20.0,
    outer_radius: 50.0,
  })
  let line = ShapeGeometry::Line({
    start: @math.Vec2::zero(),
    end: @math.Vec2::new(10.0, 10.0),
  })
  let polyline = ShapeGeometry::Polyline({
    points: [@math.Vec2::zero(), @math.Vec2::new(5.0, 5.0)],
    closed: true,
  })
  let custom = ShapeGeometry::Path(Path::empty())

  inspect(rect.to_path().bounds().width(), content="100")
  inspect(ellipse.to_path().bounds().width(), content="80")
  inspect(poly.to_path().bounds().is_empty(), content="false")
  inspect(star.to_path().bounds().is_empty(), content="false")
  inspect(line.to_path().bounds().is_empty(), content="false")
  inspect(polyline.to_path().bounds().is_empty(), content="false")
  inspect(custom.to_path().bounds().is_empty(), content="true")
}

///|
test "Styles and stroke caps/joins" {
  let s1 = StrokeCap::Butt
  let s2 = StrokeCap::Round
  let s3 = StrokeCap::Square
  inspect(s1.to_string(), content="butt")
  inspect(s2.to_string(), content="round")
  inspect(s3.to_string(), content="square")

  let j1 = StrokeJoin::Miter
  let j2 = StrokeJoin::Round
  let j3 = StrokeJoin::Bevel
  inspect(j1.to_string(), content="miter")
  inspect(j2.to_string(), content="round")
  inspect(j3.to_string(), content="bevel")

  let stop = GradientStop::{ offset: 0.5, color: RGBA::white() }
  let fill_none = Fill::None
  let fill_lin = Fill::LinearGradient(
    @math.Vec2::zero(),
    @math.Vec2::new(1.0, 1.0),
    [stop],
  )
  let fill_rad = Fill::RadialGradient(
    @math.Vec2::zero(),
    10.0,
    @math.Vec2::zero(),
    [stop],
  )

  inspect(fill_none.to_string(), content="none")
  inspect(fill_lin.to_string(), content="linear-gradient(1 stops)")
  inspect(fill_rad.to_string(), content="radial-gradient(1 stops)")

  let blend_modes = [
    BlendMode::Normal,
    BlendMode::Multiply,
    BlendMode::Screen,
    BlendMode::Overlay,
    BlendMode::Darken,
    BlendMode::Lighten,
    BlendMode::ColorDodge,
    BlendMode::ColorBurn,
    BlendMode::SoftLight,
    BlendMode::HardLight,
    BlendMode::Difference,
    BlendMode::Exclusion,
  ]
  inspect(blend_modes.length(), content="12")

  let shadow = Shadow::new(2.0, 4.0, 8.0, RGBA::black())
  inspect(shadow.blur, content="8")
}

///|
test "SVG Path Parser" {
  let path_str = "M 10 20 L 30 40 C 50 60 70 80 90 100 Z"
  let parsed = parse_svg_path(path_str)
  let bounds = parsed.bounds()
  inspect(bounds.min_x, content="10")
  inspect(bounds.max_x, content="90")
  inspect(bounds.min_y, content="20")
  inspect(bounds.max_y, content="100")
}

///|
test "Boolean operations models" {
  let p1 = PathBuilder::new()
    .move_to(@math.Vec2::zero())
    .line_to(@math.Vec2::new(10.0, 10.0))
    .build()
  let p2 = PathBuilder::new()
    .move_to(@math.Vec2::new(10.0, 10.0))
    .line_to(@math.Vec2::new(20.0, 20.0))
    .build()
  let combined = combine_paths(Union, p1, p2)
  inspect(combined.segments.length(), content="4")
}

///|
test "Text Layout Engine" {
  let res = compute_text_layout(
    "Hello MoonBit Artboard Vector Engine World", 16.0, 200.0, 1.2,
  )
  inspect(res.lines.length() > 1, content="true")
}

///|
test "Gradient Mesh 2D Interpolation" {
  let mesh = GradientMesh::create_grid(2, 2, 200.0, 200.0)
  inspect(mesh.patches.length(), content="4")
  let color = mesh.patches[0].sample(0.5, 0.5)
  inspect(color.a, content="1")
}
