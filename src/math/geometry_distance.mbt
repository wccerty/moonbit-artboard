// Point-to-segment projection primitives used by geometry hit testing.

///|
pub(all) struct SegmentProjection {
  point : Vec2
  parameter : Double
  distance_squared : Double
} derive(Eq, Debug)

///|
pub fn project_point_to_segment(
  point : Vec2,
  start : Vec2,
  end : Vec2,
) -> SegmentProjection {
  let direction = end.sub(start)
  let length_squared = direction.length_sq()
  if length_squared <= 0.000000000000000000000001 {
    { point: start, parameter: 0.0, distance_squared: point.distance_sq(start) }
  } else {
    let raw_parameter = point.sub(start).dot(direction) / length_squared
    let parameter = clamp_double(raw_parameter, 0.0, 1.0)
    let projected = start.add(direction.scale(parameter))
    {
      point: projected,
      parameter,
      distance_squared: point.distance_sq(projected),
    }
  }
}

///|
pub fn distance_squared_to_segment(
  point : Vec2,
  start : Vec2,
  end : Vec2,
) -> Double {
  project_point_to_segment(point, start, end).distance_squared
}
