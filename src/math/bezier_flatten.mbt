// Adaptive curve subdivision for deterministic polyline consumers.

///|
fn cubic_is_flat(curve : CubicBezier, tolerance_squared : Double) -> Bool {
  let first = distance_squared_to_segment(curve.p1, curve.p0, curve.p3)
  let second = distance_squared_to_segment(curve.p2, curve.p0, curve.p3)
  first <= tolerance_squared && second <= tolerance_squared
}

///|
fn append_cubic_points(
  curve : CubicBezier,
  tolerance_squared : Double,
  depth : Int,
  max_depth : Int,
  output : Array[Vec2],
) -> Unit {
  if depth >= max_depth || cubic_is_flat(curve, tolerance_squared) {
    output.push(curve.p3)
  } else {
    let (left, right) = curve.split(0.5)
    append_cubic_points(left, tolerance_squared, depth + 1, max_depth, output)
    append_cubic_points(right, tolerance_squared, depth + 1, max_depth, output)
  }
}

///|
pub fn flatten_cubic(
  curve : CubicBezier,
  tolerance : Double,
  max_depth : Int,
) -> Array[Vec2] {
  let output = [curve.p0]
  let effective_tolerance = if tolerance <= 0.0 { 0.000001 } else { tolerance }
  let effective_depth = if max_depth < 1 { 1 } else { max_depth }
  append_cubic_points(
    curve,
    effective_tolerance * effective_tolerance,
    0,
    effective_depth,
    output,
  )
  output
}

///|
pub fn flatten_quadratic(
  curve : QuadraticBezier,
  tolerance : Double,
  max_depth : Int,
) -> Array[Vec2] {
  flatten_cubic(curve.to_cubic(), tolerance, max_depth)
}
