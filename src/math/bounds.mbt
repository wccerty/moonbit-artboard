// BoundingBox library for 2D bounding boxes and spatial intersection tests.

///|
pub struct Rect2D {
  min_x : Double
  min_y : Double
  max_x : Double
  max_y : Double
} derive(Eq, Debug)

///|
pub impl Show for Rect2D with fn output(self, logger) {
  logger.write_string("{min_x: ")
  logger.write_string(self.min_x.to_string())
  logger.write_string(", min_y: ")
  logger.write_string(self.min_y.to_string())
  logger.write_string(", max_x: ")
  logger.write_string(self.max_x.to_string())
  logger.write_string(", max_y: ")
  logger.write_string(self.max_y.to_string())
  logger.write_string("}")
}

///|
pub fn Rect2D::new(
  min_x : Double,
  min_y : Double,
  max_x : Double,
  max_y : Double,
) -> Rect2D {
  { min_x, min_y, max_x, max_y }
}

///|
pub fn Rect2D::empty() -> Rect2D {
  {
    min_x: 1000000000.0,
    min_y: 1000000000.0,
    max_x: -1000000000.0,
    max_y: -1000000000.0,
  }
}

///|
pub fn Rect2D::from_point(p : Vec2) -> Rect2D {
  { min_x: p.x, min_y: p.y, max_x: p.x, max_y: p.y }
}

///|
pub fn Rect2D::from_points(points : Array[Vec2]) -> Rect2D {
  if points.is_empty() {
    Rect2D::empty()
  } else {
    let mut min_x = points[0].x
    let mut min_y = points[0].y
    let mut max_x = points[0].x
    let mut max_y = points[0].y
    for i = 1; i < points.length(); i = i + 1 {
      let p = points[i]
      if p.x < min_x {
        min_x = p.x
      }
      if p.y < min_y {
        min_y = p.y
      }
      if p.x > max_x {
        max_x = p.x
      }
      if p.y > max_y {
        max_y = p.y
      }
    }
    { min_x, min_y, max_x, max_y }
  }
}

///|
pub fn Rect2D::width(self : Rect2D) -> Double {
  if self.max_x < self.min_x {
    0.0
  } else {
    self.max_x - self.min_x
  }
}

///|
pub fn Rect2D::height(self : Rect2D) -> Double {
  if self.max_y < self.min_y {
    0.0
  } else {
    self.max_y - self.min_y
  }
}

///|
pub fn Rect2D::center(self : Rect2D) -> Vec2 {
  { x: (self.min_x + self.max_x) * 0.5, y: (self.min_y + self.max_y) * 0.5 }
}

///|
pub fn Rect2D::union(self : Rect2D, other : Rect2D) -> Rect2D {
  if self.is_empty() {
    other
  } else if other.is_empty() {
    self
  } else {
    {
      min_x: if self.min_x < other.min_x {
        self.min_x
      } else {
        other.min_x
      },
      min_y: if self.min_y < other.min_y {
        self.min_y
      } else {
        other.min_y
      },
      max_x: if self.max_x > other.max_x {
        self.max_x
      } else {
        other.max_x
      },
      max_y: if self.max_y > other.max_y {
        self.max_y
      } else {
        other.max_y
      },
    }
  }
}

///|
pub fn Rect2D::intersection(self : Rect2D, other : Rect2D) -> Rect2D {
  let min_x = if self.min_x > other.min_x { self.min_x } else { other.min_x }
  let min_y = if self.min_y > other.min_y { self.min_y } else { other.min_y }
  let max_x = if self.max_x < other.max_x { self.max_x } else { other.max_x }
  let max_y = if self.max_y < other.max_y { self.max_y } else { other.max_y }
  if min_x > max_x || min_y > max_y {
    Rect2D::empty()
  } else {
    { min_x, min_y, max_x, max_y }
  }
}

///|
pub fn Rect2D::intersects(self : Rect2D, other : Rect2D) -> Bool {
  !(self.max_x < other.min_x ||
  self.min_x > other.max_x ||
  self.max_y < other.min_y ||
  self.min_y > other.max_y)
}

///|
pub fn Rect2D::contains_point(self : Rect2D, p : Vec2) -> Bool {
  p.x >= self.min_x &&
  p.x <= self.max_x &&
  p.y >= self.min_y &&
  p.y <= self.max_y
}

///|
pub fn Rect2D::contains_rect(self : Rect2D, other : Rect2D) -> Bool {
  other.min_x >= self.min_x &&
  other.max_x <= self.max_x &&
  other.min_y >= self.min_y &&
  other.max_y <= self.max_y
}

///|
pub fn Rect2D::expand(self : Rect2D, amount : Double) -> Rect2D {
  {
    min_x: self.min_x - amount,
    min_y: self.min_y - amount,
    max_x: self.max_x + amount,
    max_y: self.max_y + amount,
  }
}

///|
pub fn Rect2D::corners(self : Rect2D) -> Array[Vec2] {
  [
    Vec2::new(self.min_x, self.min_y),
    Vec2::new(self.max_x, self.min_y),
    Vec2::new(self.max_x, self.max_y),
    Vec2::new(self.min_x, self.max_y),
  ]
}

///|
pub fn Rect2D::is_empty(self : Rect2D) -> Bool {
  self.min_x > self.max_x || self.min_y > self.max_y
}
