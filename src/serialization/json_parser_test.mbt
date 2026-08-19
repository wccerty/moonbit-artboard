///|
test "JSON parser handles nested values and escapes" {
  let parsed = parse_json(
    " {\"title\":\"Art\\nboard\",\"items\":[true,null,-2.5,{\"key\":\"value\"}]} ",
  )
  match parsed {
    Ok(JsonValue::JObject(fields)) => {
      assert_true(fields.get("title") is Some(JsonValue::JString("Art\nboard")))
      match fields.get("items") {
        Some(JsonValue::JArray(items)) => {
          assert_eq(items.length(), 4)
          assert_true(items[0] == JsonValue::JBool(true))
          assert_true(items[1] == JsonValue::JNull)
          assert_true(items[2] == JsonValue::JNumber(-2.5))
        }
        _ => assert_true(false)
      }
    }
    _ => assert_true(false)
  }
}

///|
test "JSON parser rejects malformed input" {
  match parse_json("{\"missing\": [1,}") {
    Ok(_) => assert_true(false)
    Err(error) => assert_true(error.position >= 0)
  }
}

///|
test "Document decoder round trips metadata and nodes" {
  let doc = @scenegraph.ArtboardDocument::new("Round Trip", 640.0, 480.0)
  let root = @scenegraph.Node::create_artboard(
    @scenegraph.NodeID::new("artboard"),
    "Canvas",
    640.0,
    480.0,
    @shapes.RGBA::from_hex("#112233"),
  )
  doc.add_node(root, None)
  let shape = @scenegraph.Node::create_shape(
    @scenegraph.NodeID::new("shape"),
    "A \"shape\"",
    @shapes.ShapeGeometry::rectangle(20.0, 10.0, 2.0, 2.0),
    @shapes.Style::default(),
  )
  doc.add_node(shape, None)
  let encoded = encode_document(doc)
  match decode_document_checked(encoded) {
    Ok(decoded) => {
      assert_eq(decoded.title, "Round Trip")
      assert_eq(decoded.width, 640.0)
      assert_eq(decoded.nodes.length(), 2)
      assert_true(decoded.get_node(@scenegraph.NodeID::new("shape")) is Some(_))
    }
    Err(_) => assert_true(false)
  }
}

///|
test "Document decoder reports missing required fields" {
  match decode_document_checked("{\"title\":\"Only title\"}") {
    Ok(_) => assert_true(false)
    Err(error) => assert_true(error.message.contains("width"))
  }
}

///|
test "Document round trip preserves shape style fields" {
  let doc = @scenegraph.ArtboardDocument::new("Styled", 100.0, 100.0)
  let base = @shapes.Style::default()
  let style = {
    ..base,
    fill: @shapes.Fill::solid(@shapes.RGBA::red()),
    stroke: None,
    opacity: 0.42,
    blend_mode: @shapes.BlendMode::Multiply,
  }
  let id = @scenegraph.NodeID::new("styled")
  doc.add_node(
    @scenegraph.Node::create_shape(
      id,
      "Styled",
      @shapes.ShapeGeometry::rectangle(10.0, 10.0, 0.0, 0.0),
      style,
    ),
    None,
  )
  match decode_document_checked(encode_document(doc)) {
    Ok(decoded) =>
      match decoded.get_node(id) {
        Some(node) =>
          match node.node_type {
            @scenegraph.NodeType::ShapeNode(data) => {
              assert_true(
                @math.nearly_equal(data.style.opacity, 0.42, 0.000001),
              )
              assert_eq(data.style.blend_mode, @shapes.BlendMode::Multiply)
              assert_true(data.style.fill is @shapes.Fill::Solid(_))
              assert_true(data.style.stroke is None)
            }
            _ => assert_true(false)
          }
        None => assert_true(false)
      }
    Err(_) => assert_true(false)
  }
}
