///|
test "validation accepts a well formed nested document" {
  let doc = ArtboardDocument::new("Valid", 100.0, 100.0)
  let group_id = NodeID::new("group")
  let shape_id = NodeID::new("shape")
  doc.add_node(Node::create_group(group_id, "Group", []), None)
  doc.add_node(
    Node::create_shape(
      shape_id,
      "Shape",
      @shapes.ShapeGeometry::rectangle(10.0, 10.0, 0.0, 0.0),
      @shapes.Style::default(),
    ),
    Some(group_id),
  )
  let report = doc.validate()
  assert_true(report.valid)
  assert_eq(report.issues.length(), 0)
}

///|
test "validation reports missing child and orphan nodes" {
  let doc = ArtboardDocument::new("Invalid", 100.0, 100.0)
  let group_id = NodeID::new("group")
  let missing_id = NodeID::new("missing")
  let orphan_id = NodeID::new("orphan")
  doc.nodes[group_id.value] = Node::create_group(group_id, "Group", [missing_id])
  doc.nodes[orphan_id.value] = {
    ..Node::create_shape(
      orphan_id,
      "Orphan",
      @shapes.ShapeGeometry::rectangle(4.0, 4.0, 0.0, 0.0),
      @shapes.Style::default(),
    ),
    parent_id: Some(NodeID::new("unknown-parent")),
  }
  doc.root_ids.push(group_id)

  let report = doc.validate()
  assert_false(report.valid)
  assert_true(report.issues.length() >= 2)
}

///|
test "validation reports parent cycles and invalid dimensions" {
  let doc = ArtboardDocument::new("Invalid", -1.0, 0.0)
  let first_id = NodeID::new("first")
  let second_id = NodeID::new("second")
  let first = Node::create_group(first_id, "First", [second_id])
  let second = Node::create_group(second_id, "Second", [first_id])
  doc.nodes[first_id.value] = { ..first, parent_id: Some(second_id) }
  doc.nodes[second_id.value] = { ..second, parent_id: Some(first_id) }
  doc.root_ids.push(first_id)

  let report = doc.validate()
  assert_false(report.valid)
  assert_true(report.issues.length() >= 2)
}
