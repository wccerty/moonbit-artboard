// PathSegment, Path, and PathBuilder vector path representation.

///|
pub enum PathSegment {
  MoveTo(@math.Vec2)
  LineTo(@math.Vec2)
  QuadTo(@math.Vec2, @math.Vec2)
  CubicTo(@math.Vec2, @math.Vec2, @math.Vec2)
  ArcTo(Double, Double, Double, Bool, Bool, @math.Vec2)
  Close
} derive(Eq, Debug)

///|
pub impl Show for PathSegment with fn output(self, logger) {
  match self {
    MoveTo(p) =>
      logger.write_string("M " + p.x.to_string() + " " + p.y.to_string())
    LineTo(p) =>
      logger.write_string("L " + p.x.to_string() + " " + p.y.to_string())
    QuadTo(control, end) =>
      logger.write_string(
        "Q " +
        control.x.to_string() +
        " " +
        control.y.to_string() +
        " " +
        end.x.to_string() +
        " " +
        end.y.to_string(),
      )
    CubicTo(control1, control2, end) =>
      logger.write_string(
        "C " +
        control1.x.to_string() +
        " " +
        control1.y.to_string() +
        " " +
        control2.x.to_string() +
        " " +
        control2.y.to_string() +
        " " +
        end.x.to_string() +
        " " +
        end.y.to_string(),
      )
    ArcTo(radius_x, radius_y, _, _, _, end) =>
      logger.write_string(
        "A " +
        radius_x.to_string() +
        " " +
        radius_y.to_string() +
        " " +
        end.x.to_string() +
        " " +
        end.y.to_string(),
      )
    Close => logger.write_string("Z")
  }
}

///|
pub struct Path {
  segments : Array[PathSegment]
} derive(Eq, Debug)

///|
pub impl Show for Path with fn output(self, logger) {
  let mut first = true
  for i = 0; i < self.segments.length(); i = i + 1 {
    if !first {
      logger.write_string(" ")
    }
    logger.write_string(self.segments[i].to_string())
    first = false
  }
}

///|
pub fn Path::empty() -> Path {
  { segments: [] }
}

///|
pub fn Path::new(segments : Array[PathSegment]) -> Path {
  { segments, }
}

///|
pub fn Path::bounds(self : Path) -> @math.Rect2D {
  let mut curr = @math.Vec2::zero()
  let mut start_p = @math.Vec2::zero()
  let mut rect = @math.Rect2D::empty()

  for i = 0; i < self.segments.length(); i = i + 1 {
    match self.segments[i] {
      MoveTo(p) => {
        curr = p
        start_p = p
        rect = rect.union(@math.Rect2D::from_point(p))
      }
      LineTo(p) => {
        rect = rect
          .union(@math.Rect2D::from_point(curr))
          .union(@math.Rect2D::from_point(p))
        curr = p
      }
      QuadTo(control, end) => {
        let quad = @math.QuadraticBezier::new(curr, control, end)
        let cb = quad.to_cubic()
        rect = rect.union(cb.bounds())
        curr = end
      }
      CubicTo(control1, control2, end) => {
        let cb = @math.CubicBezier::new(curr, control1, control2, end)
        rect = rect.union(cb.bounds())
        curr = end
      }
      ArcTo(_, _, _, _, _, end) => {
        rect = rect
          .union(@math.Rect2D::from_point(curr))
          .union(@math.Rect2D::from_point(end))
        curr = end
      }
      Close => curr = start_p
    }
  }
  rect
}

///|
pub struct PathBuilder {
  segments : Array[PathSegment]
} derive(Eq, Debug)

///|
pub fn PathBuilder::new() -> PathBuilder {
  { segments: [] }
}

///|
pub fn PathBuilder::move_to(self : PathBuilder, p : @math.Vec2) -> PathBuilder {
  self.segments.push(MoveTo(p))
  self
}

///|
pub fn PathBuilder::line_to(self : PathBuilder, p : @math.Vec2) -> PathBuilder {
  self.segments.push(LineTo(p))
  self
}

///|
pub fn PathBuilder::quad_to(
  self : PathBuilder,
  control : @math.Vec2,
  end : @math.Vec2,
) -> PathBuilder {
  self.segments.push(QuadTo(control, end))
  self
}

///|
pub fn PathBuilder::cubic_to(
  self : PathBuilder,
  control1 : @math.Vec2,
  control2 : @math.Vec2,
  end : @math.Vec2,
) -> PathBuilder {
  self.segments.push(CubicTo(control1, control2, end))
  self
}

///|
pub fn PathBuilder::arc_to(
  self : PathBuilder,
  rx : Double,
  ry : Double,
  rot : Double,
  large : Bool,
  sweep : Bool,
  end : @math.Vec2,
) -> PathBuilder {
  self.segments.push(ArcTo(rx, ry, rot, large, sweep, end))
  self
}

///|
pub fn PathBuilder::close_path(self : PathBuilder) -> PathBuilder {
  self.segments.push(Close)
  self
}

///|
pub fn PathBuilder::build(self : PathBuilder) -> Path {
  Path::new(self.segments)
}
