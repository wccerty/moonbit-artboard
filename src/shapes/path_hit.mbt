// Fill and stroke queries over flattened vector paths.

///|
fn subpath_winding_number(
  point : @math.Vec2,
  points : Array[@math.Vec2],
) -> Int {
  if points.length() < 3 {
    0
  } else {
    let mut winding = 0
    for i = 0; i < points.length() - 1; i = i + 1 {
      let current = points[i]
      let next = points[i + 1]
      if current.y <= point.y {
        if next.y > point.y && next.sub(current).cross(point.sub(current)) > 0.0 {
          winding = winding + 1
        }
      } else if next.y <= point.y &&
        next.sub(current).cross(point.sub(current)) < 0.0 {
        winding = winding - 1
      }
    }
    winding
  }
}

///|
pub fn path_contains_point(
  path : Path,
  point : @math.Vec2,
  tolerance : Double,
) -> Bool {
  let subpaths = flatten_path_internal(path, tolerance, 12)
  let mut winding = 0
  for i = 0; i < subpaths.length(); i = i + 1 {
    let subpath = subpaths[i]
    if subpath.closed {
      winding = winding + subpath_winding_number(point, subpath.points)
    }
  }
  winding != 0
}

///|
pub fn path_distance_to_point(
  path : Path,
  point : @math.Vec2,
  tolerance : Double,
) -> Double {
  let subpaths = flatten_path_internal(path, tolerance, 12)
  let mut best_squared = 1000000000000000000.0
  for i = 0; i < subpaths.length(); i = i + 1 {
    let points = subpaths[i].points
    for j = 0; j + 1 < points.length(); j = j + 1 {
      let distance_squared = @math.distance_squared_to_segment(
        point,
        points[j],
        points[j + 1],
      )
      if distance_squared < best_squared {
        best_squared = distance_squared
      }
    }
  }
  if best_squared == 1000000000000000000.0 {
    1000000000.0
  } else {
    best_squared.sqrt()
  }
}

///|
pub fn geometry_contains_point(
  geometry : ShapeGeometry,
  point : @math.Vec2,
  tolerance : Double,
) -> Bool {
  path_contains_point(geometry.to_path(), point, tolerance)
}
