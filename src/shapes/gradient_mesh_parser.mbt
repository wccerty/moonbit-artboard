// Mesh Gradient SVG Path generation & CSS canvas color stops exporter.

///|
pub fn render_mesh_patch_to_svg_path(patch : MeshPatch) -> String {
  let p0 = patch.v00.position
  let p1 = patch.v10.position
  let p2 = patch.v11.position
  let p3 = patch.v01.position

  let path_data = "M " +
    p0.x.to_string() +
    " " +
    p0.y.to_string() +
    " L " +
    p1.x.to_string() +
    " " +
    p1.y.to_string() +
    " L " +
    p2.x.to_string() +
    " " +
    p2.y.to_string() +
    " L " +
    p3.x.to_string() +
    " " +
    p3.y.to_string() +
    " Z"

  "<path d=\"" + path_data + "\" fill=\"" + patch.v00.color.to_hex() + "\"/>"
}

///|
pub fn render_gradient_mesh_svg(mesh : GradientMesh) -> String {
  let mut svg = "<g class=\"gradient-mesh\">\n"
  for i = 0; i < mesh.patches.length(); i = i + 1 {
    svg = svg + render_mesh_patch_to_svg_path(mesh.patches[i]) + "\n"
  }
  svg = svg + "</g>"
  svg
}
