///|
test "document metrics summarize a nested document" {
  let doc = @scenegraph.ArtboardDocument::new("Queries", 200.0, 100.0)
  let group_id = NodeID::new("group")
  doc.add_node(Node::create_group(group_id, "Group", []), None)
  let shape_id = NodeID::new("shape")
  doc.add_node(
    Node::create_shape(
      shape_id,
      "Card",
      @shapes.ShapeGeometry::rectangle(20.0, 10.0, 0.0, 0.0),
      @shapes.Style::default(),
    ),
    Some(group_id),
  )
  doc.add_node(
    Node::create_text(
      NodeID::new("label"),
      "Label",
      "hello",
      12.0,
      "sans-serif",
      @shapes.Style::default(),
    ),
    Some(group_id),
  )
  let metrics = doc.metrics()
  assert_eq(metrics.node_count, 3)
  assert_eq(metrics.group_count, 1)
  assert_eq(metrics.shape_count, 1)
  assert_eq(metrics.text_count, 1)
  assert_eq(metrics.leaf_count, 2)
  assert_eq(metrics.max_depth, 1)
}

///|
test "document queries preserve deterministic order and ancestry" {
  let doc = @scenegraph.ArtboardDocument::new("Queries", 100.0, 100.0)
  let root = NodeID::new("root")
  let child = NodeID::new("child")
  doc.add_node(Node::create_group(root, "Root", []), None)
  doc.add_node(
    Node::create_shape(
      child,
      "Card",
      @shapes.ShapeGeometry::rectangle(10.0, 10.0, 0.0, 0.0),
      @shapes.Style::default(),
    ),
    Some(root),
  )
  assert_true(doc.find_by_name("Card").contains(child))
  assert_eq(doc.ancestors(child), [root])
  assert_true(doc.is_ancestor(root, child))
  assert_true(doc.descendants(root).contains(child))
  assert_eq(doc.depth_of(child), 1)
  assert_eq(
    doc.nodes_intersecting(@math.Rect2D::new(0.0, 0.0, 20.0, 20.0)).length(),
    2,
  )
}
