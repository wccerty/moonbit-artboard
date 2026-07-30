// Fill, Stroke, Shadow, and Style data structures.

///|
pub(all) enum StrokeCap {
  Butt
  Round
  Square
} derive(Eq, Debug)

///|
pub impl Show for StrokeCap with fn output(self, logger) {
  match self {
    Butt => logger.write_string("butt")
    Round => logger.write_string("round")
    Square => logger.write_string("square")
  }
}

///|
pub(all) enum StrokeJoin {
  Miter
  Round
  Bevel
} derive(Eq, Debug)

///|
pub impl Show for StrokeJoin with fn output(self, logger) {
  match self {
    Miter => logger.write_string("miter")
    Round => logger.write_string("round")
    Bevel => logger.write_string("bevel")
  }
}

///|
pub(all) struct GradientStop {
  offset : Double
  color : RGBA
} derive(Eq, Debug)

///|
pub fn GradientStop::new(offset : Double, color : RGBA) -> GradientStop {
  { offset, color }
}

///|
pub impl Show for GradientStop with fn output(self, logger) {
  logger.write_string(
    "{offset: " +
    self.offset.to_string() +
    ", color: " +
    self.color.to_hex() +
    "}",
  )
}

///|
pub(all) enum Fill {
  None
  Solid(RGBA)
  LinearGradient(@math.Vec2, @math.Vec2, Array[GradientStop])
  RadialGradient(@math.Vec2, Double, @math.Vec2, Array[GradientStop])
} derive(Eq, Debug)

///|
pub fn Fill::none() -> Fill {
  None
}

///|
pub fn Fill::solid(color : RGBA) -> Fill {
  Solid(color)
}

///|
pub fn Fill::linear(
  start : @math.Vec2,
  end : @math.Vec2,
  stops : Array[GradientStop],
) -> Fill {
  LinearGradient(start, end, stops)
}

///|
pub fn Fill::radial(
  center : @math.Vec2,
  radius : Double,
  focal : @math.Vec2,
  stops : Array[GradientStop],
) -> Fill {
  RadialGradient(center, radius, focal, stops)
}

///|
pub impl Show for Fill with fn output(self, logger) {
  match self {
    None => logger.write_string("none")
    Solid(color) => logger.write_string(color.to_hex())
    LinearGradient(_, _, stops) =>
      logger.write_string(
        "linear-gradient(" + stops.length().to_string() + " stops)",
      )
    RadialGradient(_, _, _, stops) =>
      logger.write_string(
        "radial-gradient(" + stops.length().to_string() + " stops)",
      )
  }
}

///|
pub(all) struct Stroke {
  color : RGBA
  width : Double
  cap : StrokeCap
  join : StrokeJoin
  miter_limit : Double
  dash_array : Array[Double]
  dash_offset : Double
} derive(Eq, Debug)

///|
pub fn Stroke::new(
  color : RGBA,
  width : Double,
  cap : StrokeCap,
  join : StrokeJoin,
) -> Stroke {
  {
    color,
    width,
    cap,
    join,
    miter_limit: 4.0,
    dash_array: [],
    dash_offset: 0.0,
  }
}

///|
pub impl Show for Stroke with fn output(self, logger) {
  logger.write_string(
    "{color: " +
    self.color.to_hex() +
    ", width: " +
    self.width.to_string() +
    "}",
  )
}

///|
pub fn Stroke::default() -> Stroke {
  {
    color: RGBA::black(),
    width: 1.0,
    cap: Butt,
    join: Miter,
    miter_limit: 4.0,
    dash_array: [],
    dash_offset: 0.0,
  }
}

///|
pub(all) enum BlendMode {
  Normal
  Multiply
  Screen
  Overlay
  Darken
  Lighten
  ColorDodge
  ColorBurn
  SoftLight
  HardLight
  Difference
  Exclusion
} derive(Eq, Debug)

///|
pub fn BlendMode::from_int(v : Int) -> BlendMode {
  match v {
    1 => Multiply
    2 => Screen
    3 => Overlay
    4 => Darken
    5 => Lighten
    6 => ColorDodge
    7 => ColorBurn
    8 => SoftLight
    9 => HardLight
    10 => Difference
    11 => Exclusion
    _ => Normal
  }
}

///|
pub impl Show for BlendMode with fn output(self, logger) {
  match self {
    Normal => logger.write_string("normal")
    Multiply => logger.write_string("multiply")
    Screen => logger.write_string("screen")
    Overlay => logger.write_string("overlay")
    Darken => logger.write_string("darken")
    Lighten => logger.write_string("lighten")
    ColorDodge => logger.write_string("color-dodge")
    ColorBurn => logger.write_string("color-burn")
    SoftLight => logger.write_string("soft-light")
    HardLight => logger.write_string("hard-light")
    Difference => logger.write_string("difference")
    Exclusion => logger.write_string("exclusion")
  }
}

///|
pub(all) struct Shadow {
  offset_x : Double
  offset_y : Double
  blur : Double
  color : RGBA
} derive(Eq, Debug)

///|
pub fn Shadow::new(
  offset_x : Double,
  offset_y : Double,
  blur : Double,
  color : RGBA,
) -> Shadow {
  { offset_x, offset_y, blur, color }
}

///|
pub impl Show for Shadow with fn output(self, logger) {
  logger.write_string(
    "{x: " +
    self.offset_x.to_string() +
    ", y: " +
    self.offset_y.to_string() +
    ", blur: " +
    self.blur.to_string() +
    "}",
  )
}

///|
pub(all) struct Style {
  fill : Fill
  stroke : Stroke?
  opacity : Double
  blend_mode : BlendMode
  shadow : Shadow?
} derive(Eq, Debug)

///|
pub impl Show for Style with fn output(self, logger) {
  logger.write_string(
    "{opacity: " +
    self.opacity.to_string() +
    ", blend: " +
    self.blend_mode.to_string() +
    "}",
  )
}

///|
pub fn Style::default() -> Style {
  {
    fill: Solid(RGBA::from_hex("#3B82F6")),
    stroke: Some(Stroke::default()),
    opacity: 1.0,
    blend_mode: Normal,
    shadow: None,
  }
}
