// Document JSON Encoder implementation in pure MoonBit.

///|
fn escape_json_string(s : String) -> String {
  let mut res = ""
  for i = 0; i < s.length(); i = i + 1 {
    let ch = s[i].to_int().unsafe_to_char()
    match ch {
      '"' => res = res + "\\\""
      '\\' => res = res + "\\\\"
      '\n' => res = res + "\\n"
      '\r' => res = res + "\\r"
      '\t' => res = res + "\\t"
      _ => res = res + ch.to_string()
    }
  }
  res
}

///|
fn encode_vec2(v : @math.Vec2) -> String {
  "{\"x\":" + v.x.to_string() + ",\"y\":" + v.y.to_string() + "}"
}

///|
fn encode_matrix2d(m : @math.Matrix2D) -> String {
  "{\"a\":" +
  m.a.to_string() +
  ",\"b\":" +
  m.b.to_string() +
  ",\"c\":" +
  m.c.to_string() +
  ",\"d\":" +
  m.d.to_string() +
  ",\"tx\":" +
  m.tx.to_string() +
  ",\"ty\":" +
  m.ty.to_string() +
  "}"
}

///|
fn encode_rgba(c : @shapes.RGBA) -> String {
  "\"" + c.to_hex() + "\""
}

///|
fn encode_node(node : @scenegraph.Node) -> String {
  let mut s = "{"
  s = s + "\"id\":\"" + escape_json_string(node.id.value) + "\","
  s = s + "\"name\":\"" + escape_json_string(node.name) + "\","
  s = s + "\"visible\":" + node.visible.to_string() + ","
  s = s + "\"locked\":" + node.locked.to_string() + ","
  s = s + "\"opacity\":" + node.opacity.to_string() + ","
  s = s + "\"transform\":" + encode_matrix2d(node.transform) + ","

  match node.parent_id {
    Some(pid) =>
      s = s + "\"parentId\":\"" + escape_json_string(pid.value) + "\","
    None => s = s + "\"parentId\":null,"
  }

  match node.node_type {
    ArtboardNode(art) => {
      s = s + "\"type\":\"artboard\","
      s = s + "\"width\":" + art.width.to_string() + ","
      s = s + "\"height\":" + art.height.to_string() + ","
      s = s + "\"background\":" + encode_rgba(art.background)
    }
    GroupNode(children) => {
      s = s + "\"type\":\"group\","
      s = s + "\"children\":["
      for i = 0; i < children.length(); i = i + 1 {
        if i > 0 {
          s = s + ","
        }
        s = s + "\"" + escape_json_string(children[i].value) + "\""
      }
      s = s + "]"
    }
    ShapeNode(shape_data) => {
      s = s + "\"type\":\"shape\","
      match shape_data.geometry {
        Rectangle(rect) => {
          s = s + "\"geometryType\":\"rectangle\","
          s = s + "\"width\":" + rect.width.to_string() + ","
          s = s + "\"height\":" + rect.height.to_string() + ","
          s = s + "\"rx\":" + rect.rx.to_string() + ","
          s = s + "\"ry\":" + rect.ry.to_string()
        }
        Ellipse(ell) => {
          s = s + "\"geometryType\":\"ellipse\","
          s = s + "\"radiusX\":" + ell.radius_x.to_string() + ","
          s = s + "\"radiusY\":" + ell.radius_y.to_string()
        }
        Polygon(poly) => {
          s = s + "\"geometryType\":\"polygon\","
          s = s + "\"sides\":" + poly.sides.to_string() + ","
          s = s + "\"radius\":" + poly.radius.to_string()
        }
        Star(star) => {
          s = s + "\"geometryType\":\"star\","
          s = s + "\"points\":" + star.points.to_string() + ","
          s = s + "\"innerRadius\":" + star.inner_radius.to_string() + ","
          s = s + "\"outerRadius\":" + star.outer_radius.to_string()
        }
        Line(line) => {
          s = s + "\"geometryType\":\"line\","
          s = s + "\"start\":" + encode_vec2(line.start) + ","
          s = s + "\"end\":" + encode_vec2(line.end)
        }
        Polyline(poly) => {
          s = s + "\"geometryType\":\"polyline\","
          s = s + "\"closed\":" + poly.closed.to_string() + ","
          s = s + "\"points\":["
          for i = 0; i < poly.points.length(); i = i + 1 {
            if i > 0 {
              s = s + ","
            }
            s = s + encode_vec2(poly.points[i])
          }
          s = s + "]"
        }
        Path(p) => {
          s = s + "\"geometryType\":\"path\","
          s = s + "\"pathData\":\"" + escape_json_string(p.to_string()) + "\""
        }
      }
      s = s + ",\"style\":" + encode_style(shape_data.style)
    }
    TextNode(t) => {
      s = s + "\"type\":\"text\","
      s = s + "\"text\":\"" + escape_json_string(t.text) + "\","
      s = s + "\"fontSize\":" + t.font_size.to_string() + ","
      s = s + "\"fontFamily\":\"" + escape_json_string(t.font_family) + "\","
      s = s + "\"style\":" + encode_style(t.style)
    }
    ImageNode(img) => {
      s = s + "\"type\":\"image\","
      s = s + "\"src\":\"" + escape_json_string(img.src) + "\","
      s = s + "\"width\":" + img.width.to_string() + ","
      s = s + "\"height\":" + img.height.to_string()
    }
  }

  s = s + "}"
  s
}

///|
pub fn encode_document(doc : @scenegraph.ArtboardDocument) -> String {
  let mut s = "{"
  s = s + "\"title\":\"" + escape_json_string(doc.title) + "\","
  s = s + "\"width\":" + doc.width.to_string() + ","
  s = s + "\"height\":" + doc.height.to_string() + ","
  s = s + "\"nodes\":["

  let mut first = true
  for _k, v in doc.nodes {
    if !first {
      s = s + ","
    }
    s = s + encode_node(v)
    first = false
  }

  s = s + "]}"
  s
}
