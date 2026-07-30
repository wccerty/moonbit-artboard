// Vector2D and Point math library for 2D vector graphic kernel operations.

///|
pub struct Vec2 {
  x : Double
  y : Double
} derive(Eq, Debug)

///|
pub impl Show for Vec2 with fn output(self, logger) {
  logger.write_string("{x: ")
  logger.write_string(self.x.to_string())
  logger.write_string(", y: ")
  logger.write_string(self.y.to_string())
  logger.write_string("}")
}

///|
pub fn Vec2::new(x : Double, y : Double) -> Vec2 {
  { x, y }
}

///|
pub fn Vec2::zero() -> Vec2 {
  { x: 0.0, y: 0.0 }
}

///|
pub fn Vec2::unit_x() -> Vec2 {
  { x: 1.0, y: 0.0 }
}

///|
pub fn Vec2::unit_y() -> Vec2 {
  { x: 0.0, y: 1.0 }
}

///|
pub fn Vec2::add(self : Vec2, other : Vec2) -> Vec2 {
  { x: self.x + other.x, y: self.y + other.y }
}

///|
pub fn Vec2::sub(self : Vec2, other : Vec2) -> Vec2 {
  { x: self.x - other.x, y: self.y - other.y }
}

///|
pub fn Vec2::scale(self : Vec2, scalar : Double) -> Vec2 {
  { x: self.x * scalar, y: self.y * scalar }
}

///|
pub fn Vec2::negate(self : Vec2) -> Vec2 {
  { x: -self.x, y: -self.y }
}

///|
pub fn Vec2::dot(self : Vec2, other : Vec2) -> Double {
  self.x * other.x + self.y * other.y
}

///|
pub fn Vec2::cross(self : Vec2, other : Vec2) -> Double {
  self.x * other.y - self.y * other.x
}

///|
pub fn Vec2::length_sq(self : Vec2) -> Double {
  self.x * self.x + self.y * self.y
}

///|
pub fn Vec2::length(self : Vec2) -> Double {
  self.length_sq().sqrt()
}

///|
pub fn Vec2::normalize(self : Vec2) -> Vec2 {
  let len = self.length()
  if len < 0.000000000001 {
    Vec2::zero()
  } else {
    self.scale(1.0 / len)
  }
}

///|
pub fn Vec2::distance_sq(self : Vec2, other : Vec2) -> Double {
  self.sub(other).length_sq()
}

///|
pub fn Vec2::distance(self : Vec2, other : Vec2) -> Double {
  self.distance_sq(other).sqrt()
}

///|
pub fn Vec2::lerp(self : Vec2, target : Vec2, t : Double) -> Vec2 {
  { x: self.x + (target.x - self.x) * t, y: self.y + (target.y - self.y) * t }
}

///|
pub fn Vec2::angle(self : Vec2) -> Double {
  @cmath.atan2(self.y, self.x)
}

///|
pub fn Vec2::angle_between(self : Vec2, other : Vec2) -> Double {
  let dot_prod = self.dot(other)
  let len_prod = self.length() * other.length()
  if len_prod < 0.000000000001 {
    0.0
  } else {
    let cos_val = dot_prod / len_prod
    let clamped = if cos_val > 1.0 {
      1.0
    } else if cos_val < -1.0 {
      -1.0
    } else {
      cos_val
    }
    @cmath.acos(clamped)
  }
}

///|
pub fn Vec2::rotate(self : Vec2, angle_radians : Double) -> Vec2 {
  let cos_a = @cmath.cos(angle_radians)
  let sin_a = @cmath.sin(angle_radians)
  { x: self.x * cos_a - self.y * sin_a, y: self.x * sin_a + self.y * cos_a }
}

///|
pub fn Vec2::perpendicular(self : Vec2) -> Vec2 {
  { x: -self.y, y: self.x }
}

///|
pub fn Vec2::reflect(self : Vec2, normal : Vec2) -> Vec2 {
  let n = normal.normalize()
  let d = self.dot(n)
  self.sub(n.scale(2.0 * d))
}

///|
pub fn Vec2::min(self : Vec2, other : Vec2) -> Vec2 {
  {
    x: if self.x < other.x {
      self.x
    } else {
      other.x
    },
    y: if self.y < other.y {
      self.y
    } else {
      other.y
    },
  }
}

///|
pub fn Vec2::max(self : Vec2, other : Vec2) -> Vec2 {
  {
    x: if self.x > other.x {
      self.x
    } else {
      other.x
    },
    y: if self.y > other.y {
      self.y
    } else {
      other.y
    },
  }
}
