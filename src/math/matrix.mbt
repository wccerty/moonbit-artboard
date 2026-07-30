// Matrix2D affine transform engine for 2D graphics kernel.

///|
pub struct Matrix2D {
  a : Double
  b : Double
  c : Double
  d : Double
  tx : Double
  ty : Double
} derive(Eq, Debug)

///|
pub fn Matrix2D::identity() -> Matrix2D {
  { a: 1.0, b: 0.0, c: 0.0, d: 1.0, tx: 0.0, ty: 0.0 }
}

///|
pub fn Matrix2D::new(
  a : Double,
  b : Double,
  c : Double,
  d : Double,
  tx : Double,
  ty : Double,
) -> Matrix2D {
  { a, b, c, d, tx, ty }
}

///|
pub fn Matrix2D::translation(x : Double, y : Double) -> Matrix2D {
  { a: 1.0, b: 0.0, c: 0.0, d: 1.0, tx: x, ty: y }
}

///|
pub fn Matrix2D::scaling(sx : Double, sy : Double) -> Matrix2D {
  { a: sx, b: 0.0, c: 0.0, d: sy, tx: 0.0, ty: 0.0 }
}

///|
pub fn Matrix2D::scaling_at(
  sx : Double,
  sy : Double,
  center : Vec2,
) -> Matrix2D {
  Matrix2D::translation(center.x, center.y)
  .multiply(Matrix2D::scaling(sx, sy))
  .multiply(Matrix2D::translation(-center.x, -center.y))
}

///|
pub fn Matrix2D::rotation(angle_radians : Double) -> Matrix2D {
  let cos_a = @cmath.cos(angle_radians)
  let sin_a = @cmath.sin(angle_radians)
  { a: cos_a, b: sin_a, c: -sin_a, d: cos_a, tx: 0.0, ty: 0.0 }
}

///|
pub fn Matrix2D::rotation_at(angle_radians : Double, center : Vec2) -> Matrix2D {
  Matrix2D::translation(center.x, center.y)
  .multiply(Matrix2D::rotation(angle_radians))
  .multiply(Matrix2D::translation(-center.x, -center.y))
}

///|
pub fn Matrix2D::shearing(kx : Double, ky : Double) -> Matrix2D {
  { a: 1.0, b: ky, c: kx, d: 1.0, tx: 0.0, ty: 0.0 }
}

///|
pub fn Matrix2D::multiply(self : Matrix2D, other : Matrix2D) -> Matrix2D {
  {
    a: self.a * other.a + self.c * other.b,
    b: self.b * other.a + self.d * other.b,
    c: self.a * other.c + self.c * other.d,
    d: self.b * other.c + self.d * other.d,
    tx: self.a * other.tx + self.c * other.ty + self.tx,
    ty: self.b * other.tx + self.d * other.ty + self.ty,
  }
}

///|
pub fn Matrix2D::determinant(self : Matrix2D) -> Double {
  self.a * self.d - self.b * self.c
}

///|
pub fn Matrix2D::invert(self : Matrix2D) -> Matrix2D? {
  let det = self.determinant()
  if det.abs() < 0.000000000001 {
    None
  } else {
    let inv_det = 1.0 / det
    Some({
      a: self.d * inv_det,
      b: -self.b * inv_det,
      c: -self.c * inv_det,
      d: self.a * inv_det,
      tx: (self.c * self.ty - self.d * self.tx) * inv_det,
      ty: (self.b * self.tx - self.a * self.ty) * inv_det,
    })
  }
}

///|
pub fn Matrix2D::transform_point(self : Matrix2D, p : Vec2) -> Vec2 {
  {
    x: self.a * p.x + self.c * p.y + self.tx,
    y: self.b * p.x + self.d * p.y + self.ty,
  }
}

///|
pub fn Matrix2D::transform_vector(self : Matrix2D, v : Vec2) -> Vec2 {
  { x: self.a * v.x + self.c * v.y, y: self.b * v.x + self.d * v.y }
}

///|
pub fn Matrix2D::transform_bounds(self : Matrix2D, rect : Rect2D) -> Rect2D {
  if rect.is_empty() {
    rect
  } else {
    let c1 = self.transform_point(Vec2::new(rect.min_x, rect.min_y))
    let c2 = self.transform_point(Vec2::new(rect.max_x, rect.min_y))
    let c3 = self.transform_point(Vec2::new(rect.max_x, rect.max_y))
    let c4 = self.transform_point(Vec2::new(rect.min_x, rect.max_y))
    Rect2D::from_points([c1, c2, c3, c4])
  }
}

///|
pub struct MatrixDecomposition {
  translation : Vec2
  scale : Vec2
  rotation : Double
  skew : Vec2
} derive(Eq, Debug)

///|
pub fn Matrix2D::decompose(self : Matrix2D) -> MatrixDecomposition {
  let tx = self.tx
  let ty = self.ty
  let scale_x = (self.a * self.a + self.b * self.b).sqrt()
  let scale_y = (self.c * self.c + self.d * self.d).sqrt()
  let rotation = @cmath.atan2(self.b, self.a)
  let skew_x = @cmath.atan2(
    self.a * self.c + self.b * self.d,
    scale_x * scale_x,
  )
  {
    translation: Vec2::new(tx, ty),
    scale: Vec2::new(scale_x, scale_y),
    rotation,
    skew: Vec2::new(skew_x, 0.0),
  }
}
