// Checked JSON document decoder. The compatibility decoder is kept below for
// callers that cannot handle a Result yet.

///|
fn required_field(
  object : JsonValue,
  key : String,
) -> Result[JsonValue, JsonDecodeError] {
  match object.get_field(key) {
    Some(value) => Ok(value)
    None => Err(JsonDecodeError::new(0, "missing required field '" + key + "'"))
  }
}

///|
fn field_string(
  object : JsonValue,
  key : String,
) -> Result[String, JsonDecodeError] {
  match required_field(object, key) {
    Ok(JsonValue::JString(value)) => Ok(value)
    Ok(_) =>
      Err(JsonDecodeError::new(0, "field '" + key + "' must be a string"))
    Err(error) => Err(error)
  }
}

///|
fn field_number(
  object : JsonValue,
  key : String,
) -> Result[Double, JsonDecodeError] {
  match required_field(object, key) {
    Ok(JsonValue::JNumber(value)) => Ok(value)
    Ok(_) =>
      Err(JsonDecodeError::new(0, "field '" + key + "' must be a number"))
    Err(error) => Err(error)
  }
}

///|
fn field_bool_or(
  object : JsonValue,
  key : String,
  fallback : Bool,
) -> Result[Bool, JsonDecodeError] {
  match object.get_field(key) {
    None => Ok(fallback)
    Some(JsonValue::JBool(value)) => Ok(value)
    Some(_) =>
      Err(JsonDecodeError::new(0, "field '" + key + "' must be a boolean"))
  }
}

///|
fn field_number_or(
  object : JsonValue,
  key : String,
  fallback : Double,
) -> Result[Double, JsonDecodeError] {
  match object.get_field(key) {
    None => Ok(fallback)
    Some(JsonValue::JNumber(value)) => Ok(value)
    Some(_) =>
      Err(JsonDecodeError::new(0, "field '" + key + "' must be a number"))
  }
}

///|
fn field_string_or(
  object : JsonValue,
  key : String,
  fallback : String,
) -> Result[String, JsonDecodeError] {
  match object.get_field(key) {
    None => Ok(fallback)
    Some(JsonValue::JString(value)) => Ok(value)
    Some(_) =>
      Err(JsonDecodeError::new(0, "field '" + key + "' must be a string"))
  }
}

///|
fn decode_vec2(value : JsonValue) -> Result[@math.Vec2, JsonDecodeError] {
  let x = match field_number(value, "x") {
    Ok(number) => number
    Err(error) => return Err(error)
  }
  let y = match field_number(value, "y") {
    Ok(number) => number
    Err(error) => return Err(error)
  }
  Ok(@math.Vec2::new(x, y))
}

///|
fn decode_matrix(value : JsonValue) -> Result[@math.Matrix2D, JsonDecodeError] {
  let a = match field_number(value, "a") {
    Ok(number) => number
    Err(error) => return Err(error)
  }
  let b = match field_number(value, "b") {
    Ok(number) => number
    Err(error) => return Err(error)
  }
  let c = match field_number(value, "c") {
    Ok(number) => number
    Err(error) => return Err(error)
  }
  let d = match field_number(value, "d") {
    Ok(number) => number
    Err(error) => return Err(error)
  }
  let tx = match field_number(value, "tx") {
    Ok(number) => number
    Err(error) => return Err(error)
  }
  let ty = match field_number(value, "ty") {
    Ok(number) => number
    Err(error) => return Err(error)
  }
  Ok(@math.Matrix2D::new(a, b, c, d, tx, ty))
}

///|
fn decode_children(
  value : JsonValue,
) -> Result[Array[@scenegraph.NodeID], JsonDecodeError] {
  match value {
    JsonValue::JArray(values) => {
      let children : Array[@scenegraph.NodeID] = []
      for i = 0; i < values.length(); i = i + 1 {
        match values[i] {
          JsonValue::JString(id) => children.push(@scenegraph.NodeID::new(id))
          _ =>
            return Err(
              JsonDecodeError::new(0, "group children must be strings"),
            )
        }
      }
      Ok(children)
    }
    _ => Err(JsonDecodeError::new(0, "group children must be an array"))
  }
}

///|
fn decode_geometry(
  value : JsonValue,
) -> Result[@shapes.ShapeGeometry, JsonDecodeError] {
  let kind = match field_string(value, "geometryType") {
    Ok(name) => name
    Err(error) => return Err(error)
  }
  match kind {
    "rectangle" => {
      let width = match field_number(value, "width") {
        Ok(number) => number
        Err(error) => return Err(error)
      }
      let height = match field_number(value, "height") {
        Ok(number) => number
        Err(error) => return Err(error)
      }
      let rx = match field_number_or(value, "rx", 0.0) {
        Ok(number) => number
        Err(error) => return Err(error)
      }
      let ry = match field_number_or(value, "ry", 0.0) {
        Ok(number) => number
        Err(error) => return Err(error)
      }
      Ok(@shapes.ShapeGeometry::rectangle(width, height, rx, ry))
    }
    "ellipse" => {
      let rx = match field_number(value, "radiusX") {
        Ok(number) => number
        Err(error) => return Err(error)
      }
      let ry = match field_number(value, "radiusY") {
        Ok(number) => number
        Err(error) => return Err(error)
      }
      Ok(@shapes.ShapeGeometry::ellipse(rx, ry))
    }
    "polygon" => {
      let sides = match field_number(value, "sides") {
        Ok(number) => number.to_int()
        Err(error) => return Err(error)
      }
      let radius = match field_number(value, "radius") {
        Ok(number) => number
        Err(error) => return Err(error)
      }
      Ok(@shapes.ShapeGeometry::polygon(sides, radius))
    }
    "star" => {
      let points = match field_number(value, "points") {
        Ok(number) => number.to_int()
        Err(error) => return Err(error)
      }
      let inner = match field_number(value, "innerRadius") {
        Ok(number) => number
        Err(error) => return Err(error)
      }
      let outer = match field_number(value, "outerRadius") {
        Ok(number) => number
        Err(error) => return Err(error)
      }
      Ok(@shapes.ShapeGeometry::star(points, inner, outer))
    }
    "line" => {
      let start_value = match required_field(value, "start") {
        Ok(item) => item
        Err(error) => return Err(error)
      }
      let start = match decode_vec2(start_value) {
        Ok(point) => point
        Err(error) => return Err(error)
      }
      let end_value = match required_field(value, "end") {
        Ok(item) => item
        Err(error) => return Err(error)
      }
      let end = match decode_vec2(end_value) {
        Ok(point) => point
        Err(error) => return Err(error)
      }
      Ok(@shapes.ShapeGeometry::line(start, end))
    }
    "polyline" => {
      let points_value = match required_field(value, "points") {
        Ok(item) => item
        Err(error) => return Err(error)
      }
      let points : Array[@math.Vec2] = []
      match points_value {
        JsonValue::JArray(items) =>
          for i = 0; i < items.length(); i = i + 1 {
            match decode_vec2(items[i]) {
              Ok(point) => points.push(point)
              Err(error) => return Err(error)
            }
          }
        _ =>
          return Err(
            JsonDecodeError::new(0, "polyline points must be an array"),
          )
      }
      let closed = match field_bool_or(value, "closed", false) {
        Ok(flag) => flag
        Err(error) => return Err(error)
      }
      Ok(@shapes.ShapeGeometry::polyline(points, closed))
    }
    "path" => {
      let path_data = match field_string(value, "pathData") {
        Ok(data) => data
        Err(error) => return Err(error)
      }
      Ok(@shapes.ShapeGeometry::path(@shapes.parse_svg_path(path_data)))
    }
    _ =>
      Err(JsonDecodeError::new(0, "unsupported geometry type '" + kind + "'"))
  }
}

///|
fn decode_node(value : JsonValue) -> Result[@scenegraph.Node, JsonDecodeError] {
  let id = match field_string(value, "id") {
    Ok(name) => @scenegraph.NodeID::new(name)
    Err(error) => return Err(error)
  }
  let name = match field_string_or(value, "name", id.value) {
    Ok(text) => text
    Err(error) => return Err(error)
  }
  let kind = match field_string(value, "type") {
    Ok(text) => text
    Err(error) => return Err(error)
  }
  let node = match kind {
    "artboard" => {
      let width = match field_number(value, "width") {
        Ok(number) => number
        Err(error) => return Err(error)
      }
      let height = match field_number(value, "height") {
        Ok(number) => number
        Err(error) => return Err(error)
      }
      let background = match field_string(value, "background") {
        Ok(color) => @shapes.RGBA::from_hex(color)
        Err(error) => return Err(error)
      }
      @scenegraph.Node::create_artboard(id, name, width, height, background)
    }
    "group" => {
      let children_value = match required_field(value, "children") {
        Ok(item) => item
        Err(error) => return Err(error)
      }
      let children = match decode_children(children_value) {
        Ok(items) => items
        Err(error) => return Err(error)
      }
      @scenegraph.Node::create_group(id, name, children)
    }
    "shape" => {
      let geometry = match decode_geometry(value) {
        Ok(shape) => shape
        Err(error) => return Err(error)
      }
      let style = match decode_style_or_default(value) {
        Ok(value) => value
        Err(error) => return Err(error)
      }
      @scenegraph.Node::create_shape(id, name, geometry, style)
    }
    "text" => {
      let text = match field_string(value, "text") {
        Ok(content) => content
        Err(error) => return Err(error)
      }
      let font_size = match field_number(value, "fontSize") {
        Ok(number) => number
        Err(error) => return Err(error)
      }
      let font_family = match
        field_string_or(value, "fontFamily", "sans-serif") {
        Ok(font) => font
        Err(error) => return Err(error)
      }
      let style = match decode_style_or_default(value) {
        Ok(value) => value
        Err(error) => return Err(error)
      }
      @scenegraph.Node::create_text(
        id, name, text, font_size, font_family, style,
      )
    }
    "image" => {
      let src = match field_string(value, "src") {
        Ok(path) => path
        Err(error) => return Err(error)
      }
      let width = match field_number(value, "width") {
        Ok(number) => number
        Err(error) => return Err(error)
      }
      let height = match field_number(value, "height") {
        Ok(number) => number
        Err(error) => return Err(error)
      }
      @scenegraph.Node::create_image(id, name, src, width, height)
    }
    _ =>
      return Err(
        JsonDecodeError::new(0, "unsupported node type '" + kind + "'"),
      )
  }
  let transform = match value.get_field("transform") {
    None => @math.Matrix2D::identity()
    Some(matrix) =>
      match decode_matrix(matrix) {
        Ok(value) => value
        Err(error) => return Err(error)
      }
  }
  let visible = match field_bool_or(value, "visible", true) {
    Ok(flag) => flag
    Err(error) => return Err(error)
  }
  let locked = match field_bool_or(value, "locked", false) {
    Ok(flag) => flag
    Err(error) => return Err(error)
  }
  let opacity = match field_number_or(value, "opacity", 1.0) {
    Ok(number) => number
    Err(error) => return Err(error)
  }
  let parent_id = match value.get_field("parentId") {
    None | Some(JsonValue::JNull) => None
    Some(JsonValue::JString(parent)) => Some(@scenegraph.NodeID::new(parent))
    Some(_) =>
      return Err(JsonDecodeError::new(0, "parentId must be a string or null"))
  }
  let z_index = match field_number_or(value, "zIndex", 0.0) {
    Ok(number) => number.to_int()
    Err(error) => return Err(error)
  }
  Ok({ ..node, transform, visible, locked, opacity, parent_id, z_index })
}

///|
pub fn decode_document_checked(
  json_str : String,
) -> Result[@scenegraph.ArtboardDocument, JsonDecodeError] {
  let root = match parse_json(json_str) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let title = match field_string(root, "title") {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let width = match field_number(root, "width") {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let height = match field_number(root, "height") {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let document = @scenegraph.ArtboardDocument::new(title, width, height)
  let nodes_value = match required_field(root, "nodes") {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  match nodes_value {
    JsonValue::JArray(nodes) =>
      for i = 0; i < nodes.length(); i = i + 1 {
        let node = match decode_node(nodes[i]) {
          Ok(value) => value
          Err(error) => return Err(error)
        }
        document.nodes[node.id.value] = node
      }
    _ => return Err(JsonDecodeError::new(0, "nodes must be an array"))
  }
  document.root_ids.clear()
  for _key, node in document.nodes {
    match node.parent_id {
      None => document.root_ids.push(node.id)
      Some(_) => ()
    }
  }
  Ok(document)
}

///|
pub fn decode_document(json_str : String) -> @scenegraph.ArtboardDocument {
  match decode_document_checked(json_str) {
    Ok(document) => document
    Err(_) => @scenegraph.ArtboardDocument::new("Invalid Artboard", 0.0, 0.0)
  }
}
