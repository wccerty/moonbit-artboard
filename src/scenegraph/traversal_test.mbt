///|
test "document traversal is pre-order with accumulated transform and opacity" {
  let doc = ArtboardDocument::new("Traversal", 200.0, 200.0)
  let group_id = NodeID::new("group")
  let shape_id = NodeID::new("shape")
  let text_id = NodeID::new("text")
  let group = {
    ..Node::create_group(group_id, "Group", []),
    transform: @math.Matrix2D::translation(10.0, 20.0),
    opacity: 0.5,
  }
  let shape = {
    ..Node::create_shape(
      shape_id,
      "Shape",
      @shapes.ShapeGeometry::rectangle(20.0, 10.0, 0.0, 0.0),
      @shapes.Style::default(),
    ),
    transform: @math.Matrix2D::translation(5.0, 6.0),
    opacity: 0.5,
  }
  let text = Node::create_text(
    text_id,
    "Text",
    "hello",
    12.0,
    "sans",
    @shapes.Style::default(),
  )
  doc.add_node(group, None)
  doc.add_node(shape, Some(group_id))
  doc.add_node(text, Some(group_id))

  let entries = doc.traverse()
  assert_eq(entries.length(), 3)
  assert_eq(entries[0].id, group_id)
  assert_eq(entries[1].id, shape_id)
  assert_eq(entries[2].id, text_id)
  assert_eq(entries[1].depth, 1)
  assert_true((entries[1].world_transform.tx - 15.0).abs() < 0.000001)
  assert_true((entries[1].world_transform.ty - 26.0).abs() < 0.000001)
  assert_true((entries[1].inherited_opacity - 0.25).abs() < 0.000001)
}

///|
test "traversal does not recurse forever through a malformed cycle" {
  let doc = ArtboardDocument::new("Cycle", 100.0, 100.0)
  let first_id = NodeID::new("first")
  let second_id = NodeID::new("second")
  let first = Node::create_group(first_id, "First", [second_id])
  let second = Node::create_group(second_id, "Second", [first_id])
  doc.nodes[first_id.value] = { ..first, parent_id: Some(second_id) }
  doc.nodes[second_id.value] = { ..second, parent_id: Some(first_id) }
  doc.root_ids.push(first_id)

  let entries = doc.traverse()
  assert_true(entries.length() <= 2)
}
