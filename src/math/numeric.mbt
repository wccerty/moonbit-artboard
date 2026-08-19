// Shared scalar tolerance and bounded arithmetic helpers.

///|
pub fn nearly_equal(left : Double, right : Double, tolerance : Double) -> Bool {
  (left - right).abs() <= tolerance.abs()
}

///|
pub fn clamp_double(
  value : Double,
  minimum : Double,
  maximum : Double,
) -> Double {
  let low = if minimum <= maximum { minimum } else { maximum }
  let high = if minimum <= maximum { maximum } else { minimum }
  if value < low {
    low
  } else if value > high {
    high
  } else {
    value
  }
}

///|
pub fn signed_area(points : Array[Vec2]) -> Double {
  if points.length() < 3 {
    0.0
  } else {
    let mut area = 0.0
    for i = 0; i < points.length(); i = i + 1 {
      let current = points[i]
      let next = points[(i + 1) % points.length()]
      area = area + current.x * next.y - next.x * current.y
    }
    area * 0.5
  }
}
