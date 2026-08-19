// Transform composition utilities for interactive editing and interpolation.

///|
pub(all) struct TransformComponents {
  translation : Vec2
  scale : Vec2
  rotation : Double
  skew : Vec2
} derive(Eq, Debug)

///|
pub fn TransformComponents::new(
  translation : Vec2,
  scale : Vec2,
  rotation : Double,
  skew : Vec2,
) -> TransformComponents {
  { translation, scale, rotation, skew }
}

///|
pub fn TransformComponents::identity() -> TransformComponents {
  TransformComponents::new(Vec2::zero(), Vec2::new(1.0, 1.0), 0.0, Vec2::zero())
}

///|
pub fn TransformComponents::to_matrix(self : TransformComponents) -> Matrix2D {
  Matrix2D::translation(self.translation.x, self.translation.y)
  .multiply(Matrix2D::rotation(self.rotation))
  .multiply(Matrix2D::shearing(self.skew.x, self.skew.y))
  .multiply(Matrix2D::scaling(self.scale.x, self.scale.y))
}

///|
pub fn TransformComponents::lerp(
  self : TransformComponents,
  target : TransformComponents,
  amount : Double,
) -> TransformComponents {
  let t = clamp_double(amount, 0.0, 1.0)
  {
    translation: self.translation.lerp(target.translation, t),
    scale: self.scale.lerp(target.scale, t),
    rotation: self.rotation + (target.rotation - self.rotation) * t,
    skew: self.skew.lerp(target.skew, t),
  }
}

///|
pub fn Matrix2D::components(self : Matrix2D) -> TransformComponents {
  let decomposition = self.decompose()
  TransformComponents::new(
    decomposition.translation,
    decomposition.scale,
    decomposition.rotation,
    decomposition.skew,
  )
}

///|
pub fn Matrix2D::lerp(
  self : Matrix2D,
  target : Matrix2D,
  amount : Double,
) -> Matrix2D {
  self.components().lerp(target.components(), amount).to_matrix()
}

///|
pub fn Matrix2D::is_identity(self : Matrix2D, tolerance : Double) -> Bool {
  self.approximately_equal(Matrix2D::identity(), tolerance)
}

///|
pub fn Matrix2D::approximately_equal(
  self : Matrix2D,
  target : Matrix2D,
  tolerance : Double,
) -> Bool {
  nearly_equal(self.a, target.a, tolerance) &&
  nearly_equal(self.b, target.b, tolerance) &&
  nearly_equal(self.c, target.c, tolerance) &&
  nearly_equal(self.d, target.d, tolerance) &&
  nearly_equal(self.tx, target.tx, tolerance) &&
  nearly_equal(self.ty, target.ty, tolerance)
}

///|
pub fn Matrix2D::transform_points(
  self : Matrix2D,
  points : Array[Vec2],
) -> Array[Vec2] {
  let result : Array[Vec2] = []
  for i = 0; i < points.length(); i = i + 1 {
    result.push(self.transform_point(points[i]))
  }
  result
}

///|
pub fn Matrix2D::around(self : Matrix2D, center : Vec2) -> Matrix2D {
  Matrix2D::translation(center.x, center.y)
  .multiply(self)
  .multiply(Matrix2D::translation(-center.x, -center.y))
}

///|
pub fn Matrix2D::with_translation(
  self : Matrix2D,
  translation : Vec2,
) -> Matrix2D {
  { ..self, tx: translation.x, ty: translation.y }
}

///|
pub fn Matrix2D::reflection_x() -> Matrix2D {
  Matrix2D::scaling(-1.0, 1.0)
}

///|
pub fn Matrix2D::reflection_y() -> Matrix2D {
  Matrix2D::scaling(1.0, -1.0)
}

///|
pub fn Matrix2D::uniform_scale(self : Matrix2D) -> Double {
  let x = Vec2::new(self.a, self.b).length()
  let y = Vec2::new(self.c, self.d).length()
  (x + y) * 0.5
}

///|
pub fn Matrix2D::maximum_scale(self : Matrix2D) -> Double {
  let x = Vec2::new(self.a, self.b).length()
  let y = Vec2::new(self.c, self.d).length()
  if x > y {
    x
  } else {
    y
  }
}

///|
pub fn Matrix2D::minimum_scale(self : Matrix2D) -> Double {
  let x = Vec2::new(self.a, self.b).length()
  let y = Vec2::new(self.c, self.d).length()
  if x < y {
    x
  } else {
    y
  }
}

///|
pub fn interpolate_transform(
  start : Matrix2D,
  target : Matrix2D,
  amount : Double,
) -> Matrix2D {
  start.lerp(target, amount)
}
