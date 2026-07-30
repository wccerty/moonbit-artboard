// Bezier curve evaluation and geometry utilities.

///|
pub struct CubicBezier {
  p0 : Vec2
  p1 : Vec2
  p2 : Vec2
  p3 : Vec2
} derive(Eq, Debug)

///|
pub fn CubicBezier::new(
  p0 : Vec2,
  p1 : Vec2,
  p2 : Vec2,
  p3 : Vec2,
) -> CubicBezier {
  { p0, p1, p2, p3 }
}

///|
pub fn CubicBezier::evaluate(self : CubicBezier, t : Double) -> Vec2 {
  let u = 1.0 - t
  let tt = t * t
  let uu = u * u
  let uuu = uu * u
  let ttt = tt * t

  let x = uuu * self.p0.x +
    3.0 * uu * t * self.p1.x +
    3.0 * u * tt * self.p2.x +
    ttt * self.p3.x
  let y = uuu * self.p0.y +
    3.0 * uu * t * self.p1.y +
    3.0 * u * tt * self.p2.y +
    ttt * self.p3.y
  Vec2::new(x, y)
}

///|
pub fn CubicBezier::tangent(self : CubicBezier, t : Double) -> Vec2 {
  let u = 1.0 - t
  let uu = u * u
  let tt = t * t

  let dx = 3.0 * uu * (self.p1.x - self.p0.x) +
    6.0 * u * t * (self.p2.x - self.p1.x) +
    3.0 * tt * (self.p3.x - self.p2.x)
  let dy = 3.0 * uu * (self.p1.y - self.p0.y) +
    6.0 * u * t * (self.p2.y - self.p1.y) +
    3.0 * tt * (self.p3.y - self.p2.y)
  Vec2::new(dx, dy).normalize()
}

///|
pub fn CubicBezier::split(
  self : CubicBezier,
  t : Double,
) -> (CubicBezier, CubicBezier) {
  let p01 = self.p0.lerp(self.p1, t)
  let p12 = self.p1.lerp(self.p2, t)
  let p23 = self.p2.lerp(self.p3, t)
  let p012 = p01.lerp(p12, t)
  let p123 = p12.lerp(p23, t)
  let p0123 = p012.lerp(p123, t)

  let left = CubicBezier::new(self.p0, p01, p012, p0123)
  let right = CubicBezier::new(p0123, p123, p23, self.p3)
  (left, right)
}

///|
pub fn CubicBezier::bounds(self : CubicBezier) -> Rect2D {
  let points = [self.p0, self.p3]

  let find_roots = fn(
    p0 : Double,
    p1 : Double,
    p2 : Double,
    p3 : Double,
    acc : Array[Double],
  ) {
    let a = 3.0 * (-p0 + 3.0 * p1 - 3.0 * p2 + p3)
    let b = 6.0 * (p0 - 2.0 * p1 + p2)
    let c = 3.0 * (-p0 + p1)
    if a.abs() < 0.000000001 {
      if b.abs() > 0.000000001 {
        let t = -c / b
        if t > 0.0 && t < 1.0 {
          acc.push(t)
        }
      }
    } else {
      let discr = b * b - 4.0 * a * c
      if discr >= 0.0 {
        let sqrt_d = discr.sqrt()
        let t1 = (-b + sqrt_d) / (2.0 * a)
        let t2 = (-b - sqrt_d) / (2.0 * a)
        if t1 > 0.0 && t1 < 1.0 {
          acc.push(t1)
        }
        if t2 > 0.0 && t2 < 1.0 {
          acc.push(t2)
        }
      }
    }
  }

  let ts : Array[Double] = []
  find_roots(self.p0.x, self.p1.x, self.p2.x, self.p3.x, ts)
  find_roots(self.p0.y, self.p1.y, self.p2.y, self.p3.y, ts)

  let eval_points = points
  for i = 0; i < ts.length(); i = i + 1 {
    eval_points.push(self.evaluate(ts[i]))
  }
  Rect2D::from_points(eval_points)
}

///|
pub fn CubicBezier::approximate_length(
  self : CubicBezier,
  samples : Int,
) -> Double {
  let mut total = 0.0
  let mut prev = self.p0
  let n = if samples < 4 { 10 } else { samples }
  let step = 1.0 / n.to_double()
  for i = 1; i <= n; i = i + 1 {
    let curr = self.evaluate(i.to_double() * step)
    total = total + prev.distance(curr)
    prev = curr
  }
  total
}

///|
pub struct QuadraticBezier {
  p0 : Vec2
  p1 : Vec2
  p2 : Vec2
} derive(Eq, Debug)

///|
pub fn QuadraticBezier::new(p0 : Vec2, p1 : Vec2, p2 : Vec2) -> QuadraticBezier {
  { p0, p1, p2 }
}

///|
pub fn QuadraticBezier::evaluate(self : QuadraticBezier, t : Double) -> Vec2 {
  let u = 1.0 - t
  let uu = u * u
  let tt = t * t
  let x = uu * self.p0.x + 2.0 * u * t * self.p1.x + tt * self.p2.x
  let y = uu * self.p0.y + 2.0 * u * t * self.p1.y + tt * self.p2.y
  Vec2::new(x, y)
}

///|
pub fn QuadraticBezier::to_cubic(self : QuadraticBezier) -> CubicBezier {
  let c1 = self.p0.add(self.p1.sub(self.p0).scale(2.0 / 3.0))
  let c2 = self.p2.add(self.p1.sub(self.p2).scale(2.0 / 3.0))
  CubicBezier::new(self.p0, c1, c2, self.p2)
}
