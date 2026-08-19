///|
test "hit test respects a rotated shape world transform" {
  let doc = @scenegraph.ArtboardDocument::new("Rotated", 100.0, 100.0)
  let id = @scenegraph.NodeID::new("rotated")
  let node = @scenegraph.Node::create_shape(
    id,
    "Rotated",
    @vshapes.ShapeGeometry::rectangle(10.0, 20.0, 0.0, 0.0),
    @vshapes.Style::default(),
  )
  doc.add_node(
    { ..node, transform: @math.Matrix2D::rotation(1.5707963267948966) },
    None,
  )
  assert_true(hit_test_node(doc, id, @math.Vec2::new(-10.0, 5.0)))
  assert_false(hit_test_node(doc, id, @math.Vec2::new(5.0, 10.0)))
}

///|
test "document hit test returns the topmost visible unlocked shape" {
  let doc = @scenegraph.ArtboardDocument::new("Topmost", 100.0, 100.0)
  let bottom_id = @scenegraph.NodeID::new("bottom")
  let top_id = @scenegraph.NodeID::new("top")
  let geometry = @vshapes.ShapeGeometry::rectangle(20.0, 20.0, 0.0, 0.0)
  doc.add_node(
    @scenegraph.Node::create_shape(
      bottom_id,
      "Bottom",
      geometry,
      @vshapes.Style::default(),
    ),
    None,
  )
  doc.add_node(
    @scenegraph.Node::create_shape(
      top_id,
      "Top",
      geometry,
      @vshapes.Style::default(),
    ),
    None,
  )
  match hit_test_document(doc, @math.Vec2::new(10.0, 10.0)) {
    Some(id) => assert_eq(id, top_id)
    None => assert_true(false)
  }
}

///|
test "hit test rejects invisible and locked nodes" {
  let doc = @scenegraph.ArtboardDocument::new("Flags", 100.0, 100.0)
  let invisible_id = @scenegraph.NodeID::new("invisible")
  let locked_id = @scenegraph.NodeID::new("locked")
  let geometry = @vshapes.ShapeGeometry::rectangle(20.0, 20.0, 0.0, 0.0)
  let invisible = {
    ..@scenegraph.Node::create_shape(
      invisible_id,
      "Invisible",
      geometry,
      @vshapes.Style::default(),
    ),
    visible: false,
  }
  let locked = {
    ..@scenegraph.Node::create_shape(
      locked_id,
      "Locked",
      geometry,
      @vshapes.Style::default(),
    ),
    locked: true,
  }
  doc.add_node(invisible, None)
  doc.add_node(locked, None)
  assert_false(hit_test_node(doc, invisible_id, @math.Vec2::new(10.0, 10.0)))
  assert_false(hit_test_node(doc, locked_id, @math.Vec2::new(10.0, 10.0)))
}
