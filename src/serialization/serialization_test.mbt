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
