///|
test "integration workflow covers edit, query, render, and persistence" {
  let doc = @scenegraph.ArtboardDocument::new("Integration", 300.0, 200.0)
  let group_id = @scenegraph.NodeID::new("frame")
  doc.add_node(@scenegraph.Node::create_group(group_id, "Frame", []), None)
  let shape_id = @scenegraph.NodeID::new("shape")
  doc.add_node(
    @scenegraph.Node::create_shape(
      shape_id,
      "Card",
      @shapes.ShapeGeometry::rectangle(40.0, 30.0, 4.0, 4.0),
      @shapes.Style::default(),
    ),
    Some(group_id),
  )
  let text_id = @scenegraph.NodeID::new("label")
  doc.add_node(
    @scenegraph.Node::create_text(
      text_id,
      "Label",
      "MoonBit",
      14.0,
      "sans-serif",
      @shapes.Style::default(),
    ),
    Some(group_id),
  )
  let image_id = @scenegraph.NodeID::new("image")
  doc.add_node(
    @scenegraph.Node::create_image(
      image_id, "Preview", "preview.png", 32.0, 32.0,
    ),
    Some(group_id),
  )
  @scenegraph.apply_auto_layout(doc, group_id, @scenegraph.AutoLayoutConfig::{
    direction: @scenegraph.LayoutDirection::Horizontal,
    alignment: @scenegraph.LayoutAlignment::Start,
    gap: 8.0,
    padding: @scenegraph.Padding::all(4.0),
  })
  let selection = @selection.SelectionManager::new()
  selection.select(shape_id)
  assert_eq(selection.count(), 1)
  let index = @spatial.GridSpatialIndex::build_from_doc(doc, 32.0)
  assert_true(
    index.query_rect(@math.Rect2D::new(0.0, 0.0, 100.0, 100.0)).length() >= 3,
  )
  assert_true(
    @spatial.document_hit_test(doc, @math.Vec2::new(10.0, 10.0)) is Some(_),
  )
  let viewport = @viewport.Viewport::new(300.0, 200.0, 600.0, 400.0)
  let plan = @render.compile_render_plan(doc, Some(viewport))
  assert_true(plan.stats.draw_ops >= 3)
  let encoded = @serialization.encode_document(doc)
  match @serialization.decode_document_checked(encoded) {
    Ok(decoded) => assert_true(decoded.validate().valid)
    Err(_) => assert_true(false)
  }
  assert_true(doc.validate().valid)
}

///|
test "integration failure paths report malformed JSON and cycles" {
  match @serialization.decode_document_checked("{\"title\":\"broken\"}") {
    Ok(_) => assert_true(false)
    Err(error) => assert_true(error.message.contains("width"))
  }
  let doc = @scenegraph.ArtboardDocument::new("Cycle", 100.0, 100.0)
  let first_id = @scenegraph.NodeID::new("first")
  let second_id = @scenegraph.NodeID::new("second")
  doc.add_node(
    @scenegraph.Node::create_group(first_id, "First", [second_id]),
    None,
  )
  doc.add_node(
    @scenegraph.Node::create_group(second_id, "Second", [first_id]),
    None,
  )
  let first = match doc.get_node(first_id) {
    Some(node) => node
    None => panic()
  }
  let second = match doc.get_node(second_id) {
    Some(node) => node
    None => panic()
  }
  doc.update_node({ ..first, parent_id: Some(second_id) })
  doc.update_node({ ..second, parent_id: Some(first_id) })
  assert_false(doc.validate().valid)
  assert_true(
    doc.validate().issues.contains(
      @scenegraph.ValidationIssue::ParentCycle(first_id),
    ),
  )
}
