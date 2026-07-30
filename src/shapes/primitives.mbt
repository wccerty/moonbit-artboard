// Primitive vector shape definitions and path conversion routines.

///|
pub(all) struct RectData {
  width : Double
  height : Double
  rx : Double
  ry : Double
} derive(Eq, Debug)

///|
pub fn RectData::new(
  width : Double,
  height : Double,
  rx : Double,
  ry : Double,
) -> RectData {
  { width, height, rx, ry }
}

///|
pub(all) struct EllipseData {
  radius_x : Double
  radius_y : Double
} derive(Eq, Debug)

///|
pub fn EllipseData::new(radius_x : Double, radius_y : Double) -> EllipseData {
  { radius_x, radius_y }
}

///|
pub(all) struct PolygonData {
  sides : Int
  radius : Double
} derive(Eq, Debug)

///|
pub fn PolygonData::new(sides : Int, radius : Double) -> PolygonData {
  { sides, radius }
}

///|
pub(all) struct StarData {
  points : Int
  inner_radius : Double
  outer_radius : Double
} derive(Eq, Debug)

///|
pub fn StarData::new(
  points : Int,
  inner_radius : Double,
  outer_radius : Double,
) -> StarData {
  { points, inner_radius, outer_radius }
}

///|
pub(all) struct LineData {
  start : @math.Vec2
  end : @math.Vec2
} derive(Eq, Debug)

///|
pub fn LineData::new(start : @math.Vec2, end : @math.Vec2) -> LineData {
  { start, end }
}

///|
pub(all) struct PolylineData {
  points : Array[@math.Vec2]
  closed : Bool
} derive(Eq, Debug)

///|
pub fn PolylineData::new(
  points : Array[@math.Vec2],
  closed : Bool,
) -> PolylineData {
  { points, closed }
}

///|
pub(all) enum ShapeGeometry {
  Rectangle(RectData)
  Ellipse(EllipseData)
  Polygon(PolygonData)
  Star(StarData)
  Line(LineData)
  Polyline(PolylineData)
  Path(Path)
} derive(Eq, Debug)

///|
pub fn ShapeGeometry::rectangle(
  w : Double,
  h : Double,
  rx : Double,
  ry : Double,
) -> ShapeGeometry {
  Rectangle(RectData::new(w, h, rx, ry))
}

///|
pub fn ShapeGeometry::ellipse(rx : Double, ry : Double) -> ShapeGeometry {
  Ellipse(EllipseData::new(rx, ry))
}

///|
pub fn ShapeGeometry::polygon(sides : Int, radius : Double) -> ShapeGeometry {
  Polygon(PolygonData::new(sides, radius))
}

///|
pub fn ShapeGeometry::star(
  pts : Int,
  inner : Double,
  outer : Double,
) -> ShapeGeometry {
  Star(StarData::new(pts, inner, outer))
}

///|
pub fn ShapeGeometry::line(
  start : @math.Vec2,
  end : @math.Vec2,
) -> ShapeGeometry {
  Line(LineData::new(start, end))
}

///|
pub fn ShapeGeometry::polyline(
  pts : Array[@math.Vec2],
  closed : Bool,
) -> ShapeGeometry {
  Polyline(PolylineData::new(pts, closed))
}

///|
pub fn ShapeGeometry::path(p : Path) -> ShapeGeometry {
  Path(p)
}

///|
pub fn ShapeGeometry::to_path(self : ShapeGeometry) -> Path {
  match self {
    Rectangle(rect) => {
      let w = rect.width
      let h = rect.height
      let rx = if rect.rx * 2.0 > w { w * 0.5 } else { rect.rx }
      let ry = if rect.ry * 2.0 > h { h * 0.5 } else { rect.ry }

      if rx <= 0.0 || ry <= 0.0 {
        PathBuilder::new()
        .move_to(@math.Vec2::new(0.0, 0.0))
        .line_to(@math.Vec2::new(w, 0.0))
        .line_to(@math.Vec2::new(w, h))
        .line_to(@math.Vec2::new(0.0, h))
        .close_path()
        .build()
      } else {
        let k_x = rx * 0.5522847498
        let k_y = ry * 0.5522847498

        PathBuilder::new()
        .move_to(@math.Vec2::new(rx, 0.0))
        .line_to(@math.Vec2::new(w - rx, 0.0))
        .cubic_to(
          @math.Vec2::new(w - rx + k_x, 0.0),
          @math.Vec2::new(w, ry - k_y),
          @math.Vec2::new(w, ry),
        )
        .line_to(@math.Vec2::new(w, h - ry))
        .cubic_to(
          @math.Vec2::new(w, h - ry + k_y),
          @math.Vec2::new(w - rx + k_x, h),
          @math.Vec2::new(w - rx, h),
        )
        .line_to(@math.Vec2::new(rx, h))
        .cubic_to(
          @math.Vec2::new(rx - k_x, h),
          @math.Vec2::new(0.0, h - ry + k_y),
          @math.Vec2::new(0.0, h - ry),
        )
        .line_to(@math.Vec2::new(0.0, ry))
        .cubic_to(
          @math.Vec2::new(0.0, ry - k_y),
          @math.Vec2::new(rx - k_x, 0.0),
          @math.Vec2::new(rx, 0.0),
        )
        .close_path()
        .build()
      }
    }
    Ellipse(ell) => {
      let rx = ell.radius_x
      let ry = ell.radius_y
      let k_x = rx * 0.5522847498
      let k_y = ry * 0.5522847498

      PathBuilder::new()
      .move_to(@math.Vec2::new(rx, 0.0))
      .cubic_to(
        @math.Vec2::new(rx, k_y),
        @math.Vec2::new(k_x, ry),
        @math.Vec2::new(0.0, ry),
      )
      .cubic_to(
        @math.Vec2::new(-k_x, ry),
        @math.Vec2::new(-rx, k_y),
        @math.Vec2::new(-rx, 0.0),
      )
      .cubic_to(
        @math.Vec2::new(-rx, -k_y),
        @math.Vec2::new(-k_x, -ry),
        @math.Vec2::new(0.0, -ry),
      )
      .cubic_to(
        @math.Vec2::new(k_x, -ry),
        @math.Vec2::new(rx, -k_y),
        @math.Vec2::new(rx, 0.0),
      )
      .close_path()
      .build()
    }
    Polygon(poly) => {
      let n = if poly.sides < 3 { 3 } else { poly.sides }
      let step = 6.283185307179586 / n.to_double()
      let builder = PathBuilder::new()
      let mut first = true
      for i = 0; i < n; i = i + 1 {
        let angle = i.to_double() * step - 1.5707963267948966
        let x = poly.radius * @cmath.cos(angle)
        let y = poly.radius * @cmath.sin(angle)
        let p = @math.Vec2::new(x, y)
        if first {
          ignore(builder.move_to(p))
          first = false
        } else {
          ignore(builder.line_to(p))
        }
      }
      ignore(builder.close_path())
      builder.build()
    }
    Star(star) => {
      let pts = if star.points < 3 { 3 } else { star.points }
      let total_pts = pts * 2
      let step = 6.283185307179586 / total_pts.to_double()
      let builder = PathBuilder::new()
      let mut first = true
      for i = 0; i < total_pts; i = i + 1 {
        let r = if i % 2 == 0 { star.outer_radius } else { star.inner_radius }
        let angle = i.to_double() * step - 1.5707963267948966
        let x = r * @cmath.cos(angle)
        let y = r * @cmath.sin(angle)
        let p = @math.Vec2::new(x, y)
        if first {
          ignore(builder.move_to(p))
          first = false
        } else {
          ignore(builder.line_to(p))
        }
      }
      ignore(builder.close_path())
      builder.build()
    }
    Line(line) =>
      PathBuilder::new().move_to(line.start).line_to(line.end).build()
    Polyline(poly) => {
      let builder = PathBuilder::new()
      if poly.points.is_empty() {
        Path::empty()
      } else {
        ignore(builder.move_to(poly.points[0]))
        for i = 1; i < poly.points.length(); i = i + 1 {
          ignore(builder.line_to(poly.points[i]))
        }
        if poly.closed {
          ignore(builder.close_path())
        }
        builder.build()
      }
    }
    Path(path) => path
  }
}
