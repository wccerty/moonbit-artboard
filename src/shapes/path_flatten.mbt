// Path segment flattening for fill, stroke, export and hit testing.

///|
priv struct FlattenedSubpath {
  points : Array[@math.Vec2]
  closed : Bool
}

///|
fn append_without_first(
  destination : Array[@math.Vec2],
  source : Array[@math.Vec2],
) -> Unit {
  for i = 1; i < source.length(); i = i + 1 {
    destination.push(source[i])
  }
}

///|
fn append_arc_points(
  start : @math.Vec2,
  radius_x : Double,
  radius_y : Double,
  rotation_degrees : Double,
  large_arc : Bool,
  sweep : Bool,
  end : @math.Vec2,
  output : Array[@math.Vec2],
) -> Unit {
  let rx_input = radius_x.abs()
  let ry_input = radius_y.abs()
  if rx_input <= 0.000000000001 || ry_input <= 0.000000000001 {
    output.push(end)
  } else if start.distance_sq(end) <= 0.000000000001 {
    output.push(end)
  } else {
    let pi = 3.141592653589793
    let phi = rotation_degrees * pi / 180.0
    let cos_phi = @cmath.cos(phi)
    let sin_phi = @cmath.sin(phi)
    let dx = (start.x - end.x) * 0.5
    let dy = (start.y - end.y) * 0.5
    let x1_prime = cos_phi * dx + sin_phi * dy
    let y1_prime = -sin_phi * dx + cos_phi * dy
    let mut rx = rx_input
    let mut ry = ry_input
    let lambda = x1_prime * x1_prime / (rx * rx) +
      y1_prime * y1_prime / (ry * ry)
    if lambda > 1.0 {
      let scale = lambda.sqrt()
      rx = rx * scale
      ry = ry * scale
    }
    let rx_sq = rx * rx
    let ry_sq = ry * ry
    let x1_sq = x1_prime * x1_prime
    let y1_sq = y1_prime * y1_prime
    let numerator = rx_sq * ry_sq - rx_sq * y1_sq - ry_sq * x1_sq
    let denominator = rx_sq * y1_sq + ry_sq * x1_sq
    let ratio = if denominator <= 0.000000000001 {
      0.0
    } else {
      let raw_ratio = numerator / denominator
      if raw_ratio < 0.0 {
        0.0
      } else {
        raw_ratio
      }
    }
    let sign = if large_arc == sweep { -1.0 } else { 1.0 }
    let coefficient = sign * ratio.sqrt()
    let cx_prime = coefficient * (rx * y1_prime / ry)
    let cy_prime = coefficient * (-ry * x1_prime / rx)
    let center_x = cos_phi * cx_prime -
      sin_phi * cy_prime +
      (start.x + end.x) * 0.5
    let center_y = sin_phi * cx_prime +
      cos_phi * cy_prime +
      (start.y + end.y) * 0.5
    let unit_start = @math.Vec2::new(
      (x1_prime - cx_prime) / rx,
      (y1_prime - cy_prime) / ry,
    )
    let unit_end = @math.Vec2::new(
      (-x1_prime - cx_prime) / rx,
      (-y1_prime - cy_prime) / ry,
    )
    let start_angle = @cmath.atan2(unit_start.y, unit_start.x)
    let mut delta_angle = @cmath.atan2(
      unit_start.cross(unit_end),
      unit_start.dot(unit_end),
    )
    if !sweep && delta_angle > 0.0 {
      delta_angle = delta_angle - 2.0 * pi
    } else if sweep && delta_angle < 0.0 {
      delta_angle = delta_angle + 2.0 * pi
    }
    let magnitude = delta_angle.abs()
    let segments = if magnitude <= pi * 0.5 {
      1
    } else if magnitude <= pi {
      2
    } else if magnitude <= pi * 1.5 {
      3
    } else {
      4
    }
    for i = 1; i <= segments; i = i + 1 {
      let angle = start_angle +
        delta_angle * i.to_double() / segments.to_double()
      let cos_angle = @cmath.cos(angle)
      let sin_angle = @cmath.sin(angle)
      output.push(
        @math.Vec2::new(
          center_x + cos_phi * rx * cos_angle - sin_phi * ry * sin_angle,
          center_y + sin_phi * rx * cos_angle + cos_phi * ry * sin_angle,
        ),
      )
    }
  }
}

///|
fn flatten_path_internal(
  path : Path,
  tolerance : Double,
  max_segments : Int,
) -> Array[FlattenedSubpath] {
  let result : Array[FlattenedSubpath] = []
  let mut points : Array[@math.Vec2] = []
  let mut current = @math.Vec2::zero()
  let mut subpath_start = @math.Vec2::zero()
  let mut has_current = false
  let mut closed = false
  let depth = if max_segments < 1 { 1 } else { max_segments }

  let flush = fn() {
    if points.length() > 0 {
      result.push({ points, closed })
    }
    points = []
    closed = false
  }

  for i = 0; i < path.segments.length(); i = i + 1 {
    match path.segments[i] {
      MoveTo(point) => {
        flush()
        points.push(point)
        current = point
        subpath_start = point
        has_current = true
      }
      LineTo(point) => {
        if !has_current {
          points.push(point)
          subpath_start = point
          has_current = true
        } else {
          points.push(point)
        }
        current = point
      }
      QuadTo(control, end) => {
        let start = if has_current { current } else { @math.Vec2::zero() }
        if !has_current {
          points.push(start)
          subpath_start = start
          has_current = true
        }
        append_without_first(
          points,
          @math.flatten_quadratic(
            @math.QuadraticBezier::new(start, control, end),
            tolerance,
            depth,
          ),
        )
        current = end
      }
      CubicTo(control1, control2, end) => {
        let start = if has_current { current } else { @math.Vec2::zero() }
        if !has_current {
          points.push(start)
          subpath_start = start
          has_current = true
        }
        append_without_first(
          points,
          @math.flatten_cubic(
            @math.CubicBezier::new(start, control1, control2, end),
            tolerance,
            depth,
          ),
        )
        current = end
      }
      ArcTo(rx, ry, rotation, large_arc, sweep, end) => {
        let start = if has_current { current } else { @math.Vec2::zero() }
        if !has_current {
          points.push(start)
          subpath_start = start
          has_current = true
        }
        append_arc_points(
          start, rx, ry, rotation, large_arc, sweep, end, points,
        )
        current = end
      }
      Close =>
        if has_current {
          if current.distance_sq(subpath_start) > 0.000000000001 {
            points.push(subpath_start)
          }
          current = subpath_start
          closed = true
        }
    }
  }
  flush()
  result
}

///|
pub fn flatten_path(
  path : Path,
  tolerance : Double,
  max_segments : Int,
) -> Array[Array[@math.Vec2]] {
  let internal = flatten_path_internal(path, tolerance, max_segments)
  let result : Array[Array[@math.Vec2]] = []
  for i = 0; i < internal.length(); i = i + 1 {
    result.push(internal[i].points)
  }
  result
}
