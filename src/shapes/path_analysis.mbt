// Measurable path operations for inspectors, snapping, and export tooling.

///|
pub(all) struct PathMeasurement {
  length : Double
  area : Double
  centroid : @math.Vec2
  bounds : @math.Rect2D
  subpath_count : Int
  point_count : Int
} derive(Eq, Debug)

///|
fn polyline_length(points : Array[@math.Vec2]) -> Double {
  let mut result = 0.0
  for i = 1; i < points.length(); i = i + 1 {
    result = result + points[i - 1].distance(points[i])
  }
  result
}

///|
fn polyline_signed_area(points : Array[@math.Vec2]) -> Double {
  if points.length() < 3 {
    0.0
  } else {
    @math.signed_area(points)
  }
}

///|
fn polyline_centroid(points : Array[@math.Vec2], area : Double) -> @math.Vec2 {
  if points.length() < 3 || area.abs() < 0.000000000001 {
    if points.is_empty() {
      @math.Vec2::zero()
    } else {
      let mut sum = @math.Vec2::zero()
      for i = 0; i < points.length(); i = i + 1 {
        sum = sum.add(points[i])
      }
      sum.scale(1.0 / points.length().to_double())
    }
  } else {
    let mut cx = 0.0
    let mut cy = 0.0
    for i = 0; i < points.length(); i = i + 1 {
      let current = points[i]
      let next = points[(i + 1) % points.length()]
      let cross = current.x * next.y - next.x * current.y
      cx = cx + (current.x + next.x) * cross
      cy = cy + (current.y + next.y) * cross
    }
    @math.Vec2::new(cx / (6.0 * area), cy / (6.0 * area))
  }
}

///|
pub fn measure_path(
  path : Path,
  tolerance : Double,
  max_segments : Int,
) -> PathMeasurement {
  let subpaths = flatten_path(path, tolerance, max_segments)
  let mut length = 0.0
  let mut area = 0.0
  let mut weighted_centroid = @math.Vec2::zero()
  let mut bounds = @math.Rect2D::empty()
  let mut point_count = 0
  for i = 0; i < subpaths.length(); i = i + 1 {
    let points = subpaths[i]
    let sub_area = polyline_signed_area(points)
    length = length + polyline_length(points)
    area = area + sub_area
    weighted_centroid = weighted_centroid.add(
      polyline_centroid(points, sub_area).scale(sub_area),
    )
    point_count = point_count + points.length()
    for j = 0; j < points.length(); j = j + 1 {
      bounds = bounds.union(@math.Rect2D::from_point(points[j]))
    }
  }
  let centroid = if area.abs() < 0.000000000001 {
    if point_count == 0 {
      @math.Vec2::zero()
    } else {
      let mut sum = @math.Vec2::zero()
      for i = 0; i < subpaths.length(); i = i + 1 {
        for j = 0; j < subpaths[i].length(); j = j + 1 {
          sum = sum.add(subpaths[i][j])
        }
      }
      sum.scale(1.0 / point_count.to_double())
    }
  } else {
    weighted_centroid.scale(1.0 / area)
  }
  {
    length,
    area,
    centroid,
    bounds,
    subpath_count: subpaths.length(),
    point_count,
  }
}

///|
pub fn ShapeGeometry::measure(
  self : ShapeGeometry,
  tolerance : Double,
  max_segments : Int,
) -> PathMeasurement {
  measure_path(self.to_path(), tolerance, max_segments)
}

///|
fn locate_on_polyline(
  points : Array[@math.Vec2],
  target : Double,
) -> (@math.Vec2, @math.Vec2, Double) {
  if points.is_empty() {
    (@math.Vec2::zero(), @math.Vec2::unit_x(), 0.0)
  } else if points.length() == 1 || target <= 0.0 {
    let direction = if points.length() > 1 {
      points[1].sub(points[0]).normalize()
    } else {
      @math.Vec2::unit_x()
    }
    (points[0], direction, 0.0)
  } else {
    let mut distance_before = 0.0
    for i = 1; i < points.length(); i = i + 1 {
      let start = points[i - 1]
      let end = points[i]
      let segment = start.distance(end)
      if target <= distance_before + segment {
        let t = if segment <= 0.000000000001 {
          0.0
        } else {
          (target - distance_before) / segment
        }
        return (
          start.lerp(end, @math.clamp_double(t, 0.0, 1.0)),
          end.sub(start).normalize(),
          distance_before,
        )
      }
      distance_before = distance_before + segment
    }
    let last = points[points.length() - 1]
    let previous = if points.length() > 1 {
      points[points.length() - 2]
    } else {
      last
    }
    (last, last.sub(previous).normalize(), distance_before)
  }
}

///|
fn locate_on_path(
  path : Path,
  target : Double,
  tolerance : Double,
  max_segments : Int,
) -> (@math.Vec2, @math.Vec2) {
  let subpaths = flatten_path(path, tolerance, max_segments)
  let mut remaining = if target < 0.0 { 0.0 } else { target }
  for i = 0; i < subpaths.length(); i = i + 1 {
    let points = subpaths[i]
    let length = polyline_length(points)
    if remaining <= length || i == subpaths.length() - 1 {
      let located = locate_on_polyline(points, remaining)
      return (located.0, located.1)
    }
    remaining = remaining - length
  }
  (@math.Vec2::zero(), @math.Vec2::unit_x())
}

///|
pub fn point_at_length(
  path : Path,
  distance : Double,
  tolerance : Double,
  max_segments : Int,
) -> @math.Vec2 {
  locate_on_path(path, distance, tolerance, max_segments).0
}

///|
pub fn tangent_at_length(
  path : Path,
  distance : Double,
  tolerance : Double,
  max_segments : Int,
) -> @math.Vec2 {
  locate_on_path(path, distance, tolerance, max_segments).1
}

///|
pub fn path_is_closed(path : Path, tolerance : Double) -> Bool {
  let subpaths = flatten_path(path, tolerance, 64)
  if subpaths.is_empty() {
    false
  } else {
    let first = subpaths[0]
    first.length() > 2 &&
    first[0].distance(first[first.length() - 1]) <= tolerance.abs()
  }
}

///|
pub fn resample_path(
  path : Path,
  spacing : Double,
  tolerance : Double,
  max_segments : Int,
) -> Array[@math.Vec2] {
  let measurement = measure_path(path, tolerance, max_segments)
  let step = if spacing <= 0.000000000001 { 1.0 } else { spacing }
  let result : Array[@math.Vec2] = []
  let mut distance = 0.0
  while distance <= measurement.length {
    result.push(point_at_length(path, distance, tolerance, max_segments))
    distance = distance + step
  }
  if result.is_empty() ||
    result[result.length() - 1].distance(
      point_at_length(path, measurement.length, tolerance, max_segments),
    ) >
    tolerance.abs() {
    result.push(
      point_at_length(path, measurement.length, tolerance, max_segments),
    )
  }
  result
}

///|
fn simplify_polyline_recursive(
  points : Array[@math.Vec2],
  start : Int,
  end : Int,
  tolerance_sq : Double,
  kept : Map[Int, Bool],
) -> Unit {
  if end <= start + 1 {
    return
  }
  let mut best_distance = tolerance_sq
  let mut best_index = -1
  for i = start + 1; i < end; i = i + 1 {
    let distance = @math.distance_squared_to_segment(
      points[i],
      points[start],
      points[end],
    )
    if distance > best_distance {
      best_distance = distance
      best_index = i
    }
  }
  if best_index >= 0 {
    kept[best_index] = true
    simplify_polyline_recursive(points, start, best_index, tolerance_sq, kept)
    simplify_polyline_recursive(points, best_index, end, tolerance_sq, kept)
  }
}

///|
pub fn simplify_polyline(
  points : Array[@math.Vec2],
  tolerance : Double,
) -> Array[@math.Vec2] {
  if points.length() < 3 {
    points.copy()
  } else {
    let kept : Map[Int, Bool] = Map([])
    kept[0] = true
    kept[points.length() - 1] = true
    simplify_polyline_recursive(
      points,
      0,
      points.length() - 1,
      tolerance.abs() * tolerance.abs(),
      kept,
    )
    let result : Array[@math.Vec2] = []
    for i = 0; i < points.length(); i = i + 1 {
      match kept.get(i) {
        Some(_) => result.push(points[i])
        None => ()
      }
    }
    result
  }
}
