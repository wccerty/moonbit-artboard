// Polygon Triangulation Engine (Ear Clipping algorithm).

///|
pub(all) struct Triangle2D {
  p0 : Vec2
  p1 : Vec2
  p2 : Vec2
} derive(Eq, Debug)

///|
fn point_in_triangle(p : Vec2, a : Vec2, b : Vec2, c : Vec2) -> Bool {
  let cross1 = (b.x - a.x) * (p.y - a.y) - (b.y - a.y) * (p.x - a.x)
  let cross2 = (c.x - b.x) * (p.y - b.y) - (c.y - b.y) * (p.x - b.x)
  let cross3 = (a.x - c.x) * (p.y - c.y) - (a.y - c.y) * (p.x - c.x)
  let has_neg = cross1 < 0.0 || cross2 < 0.0 || cross3 < 0.0
  let has_pos = cross1 > 0.0 || cross2 > 0.0 || cross3 > 0.0
  !(has_neg && has_pos)
}

///|
fn is_convex(a : Vec2, b : Vec2, c : Vec2) -> Bool {
  (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x) >= 0.0
}

///|
pub fn triangulate_polygon(vertices : Array[Vec2]) -> Array[Triangle2D] {
  let n = vertices.length()
  if n < 3 {
    []
  } else {
    let triangles : Array[Triangle2D] = []
    let indices : Array[Int] = []
    for i = 0; i < n; i = i + 1 {
      indices.push(i)
    }

    let mut curr_count = n
    let mut count_limit = n * 3

    while curr_count > 3 && count_limit > 0 {
      count_limit = count_limit - 1
      let mut ear_found = false

      for i = 0; i < curr_count; i = i + 1 {
        let prev_idx = indices[(i + curr_count - 1) % curr_count]
        let curr_idx = indices[i]
        let next_idx = indices[(i + 1) % curr_count]

        let a = vertices[prev_idx]
        let b = vertices[curr_idx]
        let c = vertices[next_idx]

        if is_convex(a, b, c) {
          let mut contains_other = false
          for j = 0; j < curr_count; j = j + 1 {
            let other_idx = indices[j]
            if !(other_idx == prev_idx ||
              other_idx == curr_idx ||
              other_idx == next_idx) {
              let p = vertices[other_idx]
              if point_in_triangle(p, a, b, c) {
                contains_other = true
                break
              }
            }
          }

          if !contains_other {
            triangles.push({ p0: a, p1: b, p2: c })
            ignore(indices.remove(i))
            curr_count = curr_count - 1
            ear_found = true
            break
          }
        }
      }

      if !ear_found {
        break
      }
    }

    if curr_count == 3 {
      triangles.push({
        p0: vertices[indices[0]],
        p1: vertices[indices[1]],
        p2: vertices[indices[2]],
      })
    }

    triangles
  }
}
