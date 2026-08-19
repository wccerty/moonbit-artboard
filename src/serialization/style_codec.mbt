// Stable JSON representation for fills, strokes, shadows, and blend modes.

///|
fn encode_gradient_stop(stop : @shapes.GradientStop) -> String {
  "{\"offset\":" +
  stop.offset.to_string() +
  ",\"color\":\"" +
  stop.color.to_hex() +
  "\"}"
}

///|
fn encode_gradient_stops(stops : Array[@shapes.GradientStop]) -> String {
  let mut result = "["
  for i = 0; i < stops.length(); i = i + 1 {
    if i > 0 {
      result = result + ","
    }
    result = result + encode_gradient_stop(stops[i])
  }
  result + "]"
}

///|
fn encode_fill(fill : @shapes.Fill) -> String {
  match fill {
    None => "{\"kind\":\"none\"}"
    Solid(color) => "{\"kind\":\"solid\",\"color\":\"" + color.to_hex() + "\"}"
    LinearGradient(start, end, stops) =>
      "{\"kind\":\"linear\",\"start\":" +
      encode_vec2(start) +
      ",\"end\":" +
      encode_vec2(end) +
      ",\"stops\":" +
      encode_gradient_stops(stops) +
      "}"
    RadialGradient(center, radius, focal, stops) =>
      "{\"kind\":\"radial\",\"center\":" +
      encode_vec2(center) +
      ",\"radius\":" +
      radius.to_string() +
      ",\"focal\":" +
      encode_vec2(focal) +
      ",\"stops\":" +
      encode_gradient_stops(stops) +
      "}"
  }
}

///|
fn encode_stroke(stroke : @shapes.Stroke) -> String {
  "{\"color\":\"" +
  stroke.color.to_hex() +
  "\",\"width\":" +
  stroke.width.to_string() +
  ",\"cap\":\"" +
  stroke.cap.to_string() +
  "\",\"join\":\"" +
  stroke.join.to_string() +
  "\",\"miterLimit\":" +
  stroke.miter_limit.to_string() +
  ",\"dashOffset\":" +
  stroke.dash_offset.to_string() +
  ",\"dashArray\":[" +
  stroke.dash_array.map(fn(value) { value.to_string() }).join(",") +
  "]}"
}

///|
fn encode_shadow(shadow : @shapes.Shadow) -> String {
  "{\"offsetX\":" +
  shadow.offset_x.to_string() +
  ",\"offsetY\":" +
  shadow.offset_y.to_string() +
  ",\"blur\":" +
  shadow.blur.to_string() +
  ",\"color\":\"" +
  shadow.color.to_hex() +
  "\"}"
}

///|
pub fn encode_style(style : @shapes.Style) -> String {
  let stroke = match style.stroke {
    None => "null"
    Some(value) => encode_stroke(value)
  }
  let shadow = match style.shadow {
    None => "null"
    Some(value) => encode_shadow(value)
  }
  "{\"fill\":" +
  encode_fill(style.fill) +
  ",\"stroke\":" +
  stroke +
  ",\"opacity\":" +
  style.opacity.to_string() +
  ",\"blendMode\":\"" +
  style.blend_mode.to_string() +
  "\",\"shadow\":" +
  shadow +
  "}"
}

///|
fn decode_cap(value : String) -> @shapes.StrokeCap {
  match value {
    "round" => @shapes.StrokeCap::Round
    "square" => @shapes.StrokeCap::Square
    _ => @shapes.StrokeCap::Butt
  }
}

///|
fn decode_join(value : String) -> @shapes.StrokeJoin {
  match value {
    "round" => @shapes.StrokeJoin::Round
    "bevel" => @shapes.StrokeJoin::Bevel
    _ => @shapes.StrokeJoin::Miter
  }
}

///|
fn decode_blend(value : String) -> @shapes.BlendMode {
  match value {
    "multiply" => @shapes.BlendMode::Multiply
    "screen" => @shapes.BlendMode::Screen
    "overlay" => @shapes.BlendMode::Overlay
    "darken" => @shapes.BlendMode::Darken
    "lighten" => @shapes.BlendMode::Lighten
    "color-dodge" => @shapes.BlendMode::ColorDodge
    "color-burn" => @shapes.BlendMode::ColorBurn
    "soft-light" => @shapes.BlendMode::SoftLight
    "hard-light" => @shapes.BlendMode::HardLight
    "difference" => @shapes.BlendMode::Difference
    "exclusion" => @shapes.BlendMode::Exclusion
    _ => @shapes.BlendMode::Normal
  }
}

///|
fn decode_stops(
  value : JsonValue,
) -> Result[Array[@shapes.GradientStop], JsonDecodeError] {
  match value {
    JArray(items) => {
      let result : Array[@shapes.GradientStop] = []
      for i = 0; i < items.length(); i = i + 1 {
        let offset = match field_number(items[i], "offset") {
          Ok(number) => number
          Err(error) => return Err(error)
        }
        let color = match field_string(items[i], "color") {
          Ok(hex) => @shapes.RGBA::from_hex(hex)
          Err(error) => return Err(error)
        }
        result.push(@shapes.GradientStop::new(offset, color))
      }
      Ok(result)
    }
    _ => Err(JsonDecodeError::new(0, "gradient stops must be an array"))
  }
}

///|
fn decode_fill(value : JsonValue) -> Result[@shapes.Fill, JsonDecodeError] {
  let kind = match field_string(value, "kind") {
    Ok(text) => text
    Err(error) => return Err(error)
  }
  match kind {
    "none" => Ok(@shapes.Fill::None)
    "solid" => {
      let color = match field_string(value, "color") {
        Ok(hex) => @shapes.RGBA::from_hex(hex)
        Err(error) => return Err(error)
      }
      Ok(@shapes.Fill::Solid(color))
    }
    "linear" => {
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
      let stops_value = match required_field(value, "stops") {
        Ok(item) => item
        Err(error) => return Err(error)
      }
      let stops = match decode_stops(stops_value) {
        Ok(items) => items
        Err(error) => return Err(error)
      }
      Ok(@shapes.Fill::LinearGradient(start, end, stops))
    }
    "radial" => {
      let center_value = match required_field(value, "center") {
        Ok(item) => item
        Err(error) => return Err(error)
      }
      let center = match decode_vec2(center_value) {
        Ok(point) => point
        Err(error) => return Err(error)
      }
      let radius = match field_number(value, "radius") {
        Ok(number) => number
        Err(error) => return Err(error)
      }
      let focal_value = match required_field(value, "focal") {
        Ok(item) => item
        Err(error) => return Err(error)
      }
      let focal = match decode_vec2(focal_value) {
        Ok(point) => point
        Err(error) => return Err(error)
      }
      let stops_value = match required_field(value, "stops") {
        Ok(item) => item
        Err(error) => return Err(error)
      }
      let stops = match decode_stops(stops_value) {
        Ok(items) => items
        Err(error) => return Err(error)
      }
      Ok(@shapes.Fill::RadialGradient(center, radius, focal, stops))
    }
    _ => Err(JsonDecodeError::new(0, "unsupported fill kind '" + kind + "'"))
  }
}

///|
fn decode_stroke(value : JsonValue) -> Result[@shapes.Stroke, JsonDecodeError] {
  let color = match field_string(value, "color") {
    Ok(hex) => @shapes.RGBA::from_hex(hex)
    Err(error) => return Err(error)
  }
  let width = match field_number(value, "width") {
    Ok(number) => number
    Err(error) => return Err(error)
  }
  let cap_name = match field_string_or(value, "cap", "butt") {
    Ok(text) => text
    Err(error) => return Err(error)
  }
  let cap = decode_cap(cap_name)
  let join_name = match field_string_or(value, "join", "miter") {
    Ok(text) => text
    Err(error) => return Err(error)
  }
  let join = decode_join(join_name)
  let miter_limit = match field_number_or(value, "miterLimit", 4.0) {
    Ok(number) => number
    Err(error) => return Err(error)
  }
  let dash_offset = match field_number_or(value, "dashOffset", 0.0) {
    Ok(number) => number
    Err(error) => return Err(error)
  }
  let dash_array = match value.get_field("dashArray") {
    None => []
    Some(JNull) => []
    Some(JArray(items)) => {
      let values : Array[Double] = []
      for i = 0; i < items.length(); i = i + 1 {
        match items[i] {
          JNumber(number) => values.push(number)
          _ =>
            return Err(
              JsonDecodeError::new(0, "stroke dashArray must contain numbers"),
            )
        }
      }
      values
    }
    Some(_) =>
      return Err(JsonDecodeError::new(0, "stroke dashArray must be an array"))
  }
  let mut stroke = @shapes.Stroke::new(color, width, cap, join)
  stroke = { ..stroke, miter_limit, dash_offset, dash_array }
  Ok(stroke)
}

///|
fn decode_shadow(value : JsonValue) -> Result[@shapes.Shadow, JsonDecodeError] {
  let offset_x = match field_number(value, "offsetX") {
    Ok(number) => number
    Err(error) => return Err(error)
  }
  let offset_y = match field_number(value, "offsetY") {
    Ok(number) => number
    Err(error) => return Err(error)
  }
  let blur = match field_number(value, "blur") {
    Ok(number) => number
    Err(error) => return Err(error)
  }
  let color = match field_string(value, "color") {
    Ok(hex) => @shapes.RGBA::from_hex(hex)
    Err(error) => return Err(error)
  }
  Ok(@shapes.Shadow::new(offset_x, offset_y, blur, color))
}

///|
pub fn decode_style(
  value : JsonValue,
) -> Result[@shapes.Style, JsonDecodeError] {
  let fill_value = match required_field(value, "fill") {
    Ok(item) => item
    Err(error) => return Err(error)
  }
  let fill = match decode_fill(fill_value) {
    Ok(result) => result
    Err(error) => return Err(error)
  }
  let stroke = match value.get_field("stroke") {
    None | Some(JNull) => None
    Some(item) => {
      let decoded = match decode_stroke(item) {
        Ok(result) => result
        Err(error) => return Err(error)
      }
      Some(decoded)
    }
  }
  let opacity = match field_number_or(value, "opacity", 1.0) {
    Ok(number) => number
    Err(error) => return Err(error)
  }
  let blend_name = match field_string_or(value, "blendMode", "normal") {
    Ok(text) => text
    Err(error) => return Err(error)
  }
  let blend = decode_blend(blend_name)
  let shadow = match value.get_field("shadow") {
    None | Some(JNull) => None
    Some(item) => {
      let decoded = match decode_shadow(item) {
        Ok(result) => result
        Err(error) => return Err(error)
      }
      Some(decoded)
    }
  }
  Ok({ fill, stroke, opacity, blend_mode: blend, shadow })
}

///|
fn decode_style_or_default(
  value : JsonValue,
) -> Result[@shapes.Style, JsonDecodeError] {
  match value.get_field("style") {
    Some(style) => decode_style(style)
    None => Ok(@shapes.Style::default())
  }
}
