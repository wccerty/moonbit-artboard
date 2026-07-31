// 2D Mesh Gradient Color Interpolation Engine.

///|
pub(all) struct MeshVertex {
  position : @math.Vec2
  color : RGBA
} derive(Eq, Debug)

///|
pub(all) struct MeshPatch {
  v00 : MeshVertex
  v10 : MeshVertex
  v01 : MeshVertex
  v11 : MeshVertex
} derive(Eq, Debug)

///|
pub fn MeshPatch::sample(self : MeshPatch, u : Double, v : Double) -> RGBA {
  let c0 = self.v00.color.lerp(self.v10.color, u)
  let c1 = self.v01.color.lerp(self.v11.color, u)
  c0.lerp(c1, v)
}

///|
pub(all) struct GradientMesh {
  columns : Int
  rows : Int
  patches : Array[MeshPatch]
} derive(Eq, Debug)

///|
pub fn GradientMesh::create_grid(
  cols : Int,
  rows : Int,
  w : Double,
  h : Double,
) -> GradientMesh {
  let patches : Array[MeshPatch] = []
  let dx = w / cols.to_double()
  let dy = h / rows.to_double()

  for r = 0; r < rows; r = r + 1 {
    for c = 0; c < cols; c = c + 1 {
      let x0 = c.to_double() * dx
      let y0 = r.to_double() * dy
      let x1 = x0 + dx
      let y1 = y0 + dy

      let v00 = { position: @math.Vec2::new(x0, y0), color: RGBA::red() }
      let v10 = { position: @math.Vec2::new(x1, y0), color: RGBA::green() }
      let v01 = { position: @math.Vec2::new(x0, y1), color: RGBA::blue() }
      let v11 = { position: @math.Vec2::new(x1, y1), color: RGBA::white() }

      patches.push({ v00, v10, v01, v11 })
    }
  }

  { columns: cols, rows, patches }
}
