// Catmull-Rom & Uniform B-Spline Curve Interpolation Engine.

///|
pub fn evaluate_catmull_rom(
  p0 : Vec2,
  p1 : Vec2,
  p2 : Vec2,
  p3 : Vec2,
  t : Double,
) -> Vec2 {
  let t2 = t * t
  let t3 = t2 * t

  let f0 = -0.5 * t3 + t2 - 0.5 * t
  let f1 = 1.5 * t3 - 2.5 * t2 + 1.0
  let f2 = -1.5 * t3 + 2.0 * t2 + 0.5 * t
  let f3 = 0.5 * t3 - 0.5 * t2

  let x = p0.x * f0 + p1.x * f1 + p2.x * f2 + p3.x * f3
  let y = p0.y * f0 + p1.y * f1 + p2.y * f2 + p3.y * f3

  Vec2::new(x, y)
}

///|
pub fn evaluate_b_spline(
  p0 : Vec2,
  p1 : Vec2,
  p2 : Vec2,
  p3 : Vec2,
  t : Double,
) -> Vec2 {
  let t2 = t * t
  let t3 = t2 * t

  let f0 = (1.0 - t) * (1.0 - t) * (1.0 - t) / 6.0
  let f1 = (3.0 * t3 - 6.0 * t2 + 4.0) / 6.0
  let f2 = (-3.0 * t3 + 3.0 * t2 + 3.0 * t + 1.0) / 6.0
  let f3 = t3 / 6.0

  let x = p0.x * f0 + p1.x * f1 + p2.x * f2 + p3.x * f3
  let y = p0.y * f0 + p1.y * f1 + p2.y * f2 + p3.y * f3

  Vec2::new(x, y)
}

///|
pub fn interpolate_catmull_rom_spline(
  points : Array[Vec2],
  segments_per_span : Int,
) -> Array[Vec2] {
  let n = points.length()
  if n < 4 {
    points
  } else {
    let result : Array[Vec2] = []
    let step = 1.0 / segments_per_span.to_double()

    for i = 0; i < n - 3; i = i + 1 {
      let p0 = points[i]
      let p1 = points[i + 1]
      let p2 = points[i + 2]
      let p3 = points[i + 3]

      for j = 0; j < segments_per_span; j = j + 1 {
        let t = j.to_double() * step
        result.push(evaluate_catmull_rom(p0, p1, p2, p3, t))
      }
    }

    result.push(points[n - 2])
    result
  }
}
