// Serialization unit tests

///|
test "Document JSON Encoder" {
  let doc = @scenegraph.ArtboardDocument::new("Test Canvas", 1920.0, 1080.0)

  let rect_id = @scenegraph.NodeID::new("rect-01")
  let rect_shape = @shapes.ShapeGeometry::rectangle(200.0, 100.0, 10.0, 10.0)
  let rect_node = @scenegraph.Node::create_shape(
    rect_id,
    "My Rectangle",
    rect_shape,
    @shapes.Style::default(),
  )

  doc.add_node(rect_node, None)

  let json_str = encode_document(doc)
  inspect(json_str.has_prefix("{\"title\":\"Test Canvas\""), content="true")
  inspect(json_str.contains("My Rectangle"), content="true")
  inspect(json_str.contains("\"width\":1920"), content="true")
}

///|
test "SVG Importer AST Parser" {
  let svg = "<svg><path d=\"M 0 0 L 10 10 Z\"/></svg>"
  let doc = parse_svg_to_document(svg, "Imported SVG")
  inspect(doc.root_ids.length(), content="1")
}

///|
test "JsonValue AST Representation" {
  let obj : Map[String, JsonValue] = Map([])
  obj["name"] = JsonValue::JString("MoonBit")
  obj["version"] = JsonValue::JNumber(1.0)
  let j_obj = JsonValue::JObject(obj)

  inspect(
    j_obj.get_field("name") is Some(JsonValue::JString("MoonBit")),
    content="true",
  )
}

///|
test "Style codec preserves stroke dash arrays and shadows" {
  let stroke = {
    ..@shapes.Stroke::default(),
    dash_array: [2.0, 3.5],
    dash_offset: 1.25,
  }
  let style = {
    ..@shapes.Style::default(),
    stroke: Some(stroke),
    shadow: Some(
      @shapes.Shadow::new(2.0, -3.0, 8.0, @shapes.RGBA::from_hex("#11223380")),
    ),
  }
  let json = encode_style(style)
  let decoded = decode_style(parse_json(json).unwrap()).unwrap()
  assert_true(decoded.stroke is Some(_))
  assert_true(decoded.shadow is Some(_))
}

///|
test "checked document decoder rejects malformed style fields" {
  let json = "{\"title\":\"Invalid style\",\"width\":100,\"height\":100,\"nodes\":[" +
    "{\"id\":\"shape\",\"type\":\"shape\",\"geometryType\":\"rectangle\",\"width\":10,\"height\":10," +
    "\"style\":{\"fill\":{\"kind\":\"none\"},\"stroke\":12}}]}"
  assert_true(decode_document_checked(json) is Err(_))
}
