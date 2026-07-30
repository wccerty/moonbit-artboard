// 4x4 3D Matrix & Perspective Transformation Engine.

///|
pub(all) struct Matrix4x4 {
  m00 : Double
  m01 : Double
  m02 : Double
  m03 : Double
  m10 : Double
  m11 : Double
  m12 : Double
  m13 : Double
  m20 : Double
  m21 : Double
  m22 : Double
  m23 : Double
  m30 : Double
  m31 : Double
  m32 : Double
  m33 : Double
} derive(Eq, Debug)

///|
pub fn Matrix4x4::identity() -> Matrix4x4 {
  {
    m00: 1.0,
    m01: 0.0,
    m02: 0.0,
    m03: 0.0,
    m10: 0.0,
    m11: 1.0,
    m12: 0.0,
    m13: 0.0,
    m20: 0.0,
    m21: 0.0,
    m22: 1.0,
    m23: 0.0,
    m30: 0.0,
    m31: 0.0,
    m32: 0.0,
    m33: 1.0,
  }
}

///|
pub fn Matrix4x4::translation(x : Double, y : Double, z : Double) -> Matrix4x4 {
  {
    m00: 1.0,
    m01: 0.0,
    m02: 0.0,
    m03: x,
    m10: 0.0,
    m11: 1.0,
    m12: 0.0,
    m13: y,
    m20: 0.0,
    m21: 0.0,
    m22: 1.0,
    m23: z,
    m30: 0.0,
    m31: 0.0,
    m32: 0.0,
    m33: 1.0,
  }
}

///|
pub fn Matrix4x4::scaling(sx : Double, sy : Double, sz : Double) -> Matrix4x4 {
  {
    m00: sx,
    m01: 0.0,
    m02: 0.0,
    m03: 0.0,
    m10: 0.0,
    m11: sy,
    m12: 0.0,
    m13: 0.0,
    m20: 0.0,
    m21: 0.0,
    m22: sz,
    m23: 0.0,
    m30: 0.0,
    m31: 0.0,
    m32: 0.0,
    m33: 1.0,
  }
}

///|
pub fn Matrix4x4::rotation_x(angle_rad : Double) -> Matrix4x4 {
  let c = @cmath.cos(angle_rad)
  let s = @cmath.sin(angle_rad)
  {
    m00: 1.0,
    m01: 0.0,
    m02: 0.0,
    m03: 0.0,
    m10: 0.0,
    m11: c,
    m12: -s,
    m13: 0.0,
    m20: 0.0,
    m21: s,
    m22: c,
    m23: 0.0,
    m30: 0.0,
    m31: 0.0,
    m32: 0.0,
    m33: 1.0,
  }
}

///|
pub fn Matrix4x4::rotation_y(angle_rad : Double) -> Matrix4x4 {
  let c = @cmath.cos(angle_rad)
  let s = @cmath.sin(angle_rad)
  {
    m00: c,
    m01: 0.0,
    m02: s,
    m03: 0.0,
    m10: 0.0,
    m11: 1.0,
    m12: 0.0,
    m13: 0.0,
    m20: -s,
    m21: 0.0,
    m22: c,
    m23: 0.0,
    m30: 0.0,
    m31: 0.0,
    m32: 0.0,
    m33: 1.0,
  }
}

///|
pub fn Matrix4x4::rotation_z(angle_rad : Double) -> Matrix4x4 {
  let c = @cmath.cos(angle_rad)
  let s = @cmath.sin(angle_rad)
  {
    m00: c,
    m01: -s,
    m02: 0.0,
    m03: 0.0,
    m10: s,
    m11: c,
    m12: 0.0,
    m13: 0.0,
    m20: 0.0,
    m21: 0.0,
    m22: 1.0,
    m23: 0.0,
    m30: 0.0,
    m31: 0.0,
    m32: 0.0,
    m33: 1.0,
  }
}

///|
pub fn Matrix4x4::multiply(self : Matrix4x4, other : Matrix4x4) -> Matrix4x4 {
  {
    m00: self.m00 * other.m00 +
    self.m01 * other.m10 +
    self.m02 * other.m20 +
    self.m03 * other.m30,
    m01: self.m00 * other.m01 +
    self.m01 * other.m11 +
    self.m02 * other.m21 +
    self.m03 * other.m31,
    m02: self.m00 * other.m02 +
    self.m01 * other.m12 +
    self.m02 * other.m22 +
    self.m03 * other.m32,
    m03: self.m00 * other.m03 +
    self.m01 * other.m13 +
    self.m02 * other.m23 +
    self.m03 * other.m33,
    m10: self.m10 * other.m00 +
    self.m11 * other.m10 +
    self.m12 * other.m20 +
    self.m13 * other.m30,
    m11: self.m10 * other.m01 +
    self.m11 * other.m11 +
    self.m12 * other.m21 +
    self.m13 * other.m31,
    m12: self.m10 * other.m02 +
    self.m11 * other.m12 +
    self.m12 * other.m22 +
    self.m13 * other.m32,
    m13: self.m10 * other.m03 +
    self.m11 * other.m13 +
    self.m12 * other.m23 +
    self.m13 * other.m33,
    m20: self.m20 * other.m00 +
    self.m21 * other.m10 +
    self.m22 * other.m20 +
    self.m23 * other.m30,
    m21: self.m20 * other.m01 +
    self.m21 * other.m11 +
    self.m22 * other.m21 +
    self.m23 * other.m31,
    m22: self.m20 * other.m02 +
    self.m21 * other.m12 +
    self.m22 * other.m22 +
    self.m23 * other.m32,
    m23: self.m20 * other.m03 +
    self.m21 * other.m13 +
    self.m22 * other.m23 +
    self.m23 * other.m33,
    m30: self.m30 * other.m00 +
    self.m31 * other.m10 +
    self.m32 * other.m20 +
    self.m33 * other.m30,
    m31: self.m30 * other.m01 +
    self.m31 * other.m11 +
    self.m32 * other.m21 +
    self.m33 * other.m31,
    m32: self.m30 * other.m02 +
    self.m31 * other.m12 +
    self.m32 * other.m22 +
    self.m33 * other.m32,
    m33: self.m30 * other.m03 +
    self.m31 * other.m13 +
    self.m32 * other.m23 +
    self.m33 * other.m33,
  }
}
