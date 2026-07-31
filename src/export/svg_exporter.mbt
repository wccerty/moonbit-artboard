// SVG Exporter Adapter converting SceneGraph into standalone SVG document strings.

///|
fn matrix_to_svg_transform(m : @math.Matrix2D) -> String {
  "matrix(" +
  m.a.to_string() +
  "," +
  m.b.to_string() +
  "," +
  m.c.to_string() +
  "," +
  m.d.to_string() +
  "," +
  m.tx.to_string() +
  "," +
  m.ty.to_string() +
  ")"
}

///|
fn style_to_svg_attributes(style : @shapes.Style) -> String {
  let mut attr = ""
  match style.fill {
    None => attr = attr + " fill=\"none\""
    Solid(color) => attr = attr + " fill=\"" + color.to_hex() + "\""
    LinearGradient(_, _, _) => attr = attr + " fill=\"url(#lin-grad)\""
    RadialGradient(_, _, _, _) => attr = attr + " fill=\"url(#rad-grad)\""
  }

  match style.stroke {
    None => attr = attr + " stroke=\"none\""
    Some(s) => {
      attr = attr + " stroke=\"" + s.color.to_hex() + "\""
      attr = attr + " stroke-width=\"" + s.width.to_string() + "\""
      attr = attr + " stroke-linecap=\"" + s.cap.to_string() + "\""
      attr = attr + " stroke-linejoin=\"" + s.join.to_string() + "\""
    }
  }

  if style.opacity < 1.0 {
    attr = attr + " opacity=\"" + style.opacity.to_string() + "\""
  }

  attr
}

///|
fn export_node_svg(
  doc : @scenegraph.ArtboardDocument,
  id : @scenegraph.NodeID,
) -> String {
  match doc.get_node(id) {
    None => ""
    Some(node) => {
      if !node.visible {
        return ""
      }
      let mut svg = ""
      let transform_attr = " transform=\"" +
        matrix_to_svg_transform(node.transform) +
        "\""

      match node.node_type {
        GroupNode(children) => {
          svg = svg + "<g id=\"" + node.id.value + "\"" + transform_attr + ">\n"
          for i = 0; i < children.length(); i = i + 1 {
            svg = svg + export_node_svg(doc, children[i])
          }
          svg = svg + "</g>\n"
        }
        ShapeNode(s) => {
          let style_attr = style_to_svg_attributes(s.style)
          match s.geometry {
            Rectangle(rect) =>
              svg = svg +
                "<rect x=\"0\" y=\"0\" width=\"" +
                rect.width.to_string() +
                "\" height=\"" +
                rect.height.to_string() +
                "\" rx=\"" +
                rect.rx.to_string() +
                "\" ry=\"" +
                rect.ry.to_string() +
                "\"" +
                transform_attr +
                style_attr +
                "/>\n"
            Ellipse(ell) =>
              svg = svg +
                "<ellipse cx=\"0\" cy=\"0\" rx=\"" +
                ell.radius_x.to_string() +
                "\" ry=\"" +
                ell.radius_y.to_string() +
                "\"" +
                transform_attr +
                style_attr +
                "/>\n"
            _ => {
              let path_data = s.geometry.to_path().to_string()
              svg = svg +
                "<path d=\"" +
                path_data +
                "\"" +
                transform_attr +
                style_attr +
                "/>\n"
            }
          }
        }
        TextNode(t) =>
          svg = svg +
            "<text x=\"0\" y=\"" +
            t.font_size.to_string() +
            "\" font-size=\"" +
            t.font_size.to_string() +
            "\" font-family=\"" +
            t.font_family +
            "\"" +
            transform_attr +
            style_to_svg_attributes(t.style) +
            ">" +
            t.text +
            "</text>\n"
        ImageNode(img) =>
          svg = svg +
            "<image href=\"" +
            img.src +
            "\" width=\"" +
            img.width.to_string() +
            "\" height=\"" +
            img.height.to_string() +
            "\"" +
            transform_attr +
            "/>\n"
        ArtboardNode(_) => ()
      }

      svg
    }
  }
}

///|
pub fn export_to_svg(doc : @scenegraph.ArtboardDocument) -> String {
  let mut svg = "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 " +
    doc.width.to_string() +
    " " +
    doc.height.to_string() +
    "\" width=\"" +
    doc.width.to_string() +
    "\" height=\"" +
    doc.height.to_string() +
    "\">\n"

  for i = 0; i < doc.root_ids.length(); i = i + 1 {
    svg = svg + export_node_svg(doc, doc.root_ids[i])
  }

  svg = svg + "</svg>"
  svg
}
