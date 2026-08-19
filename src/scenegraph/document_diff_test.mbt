///|
test "document diff reports added removed and changed nodes" {
  let before = @scenegraph.ArtboardDocument::new("Diff", 100.0, 100.0)
  let id = NodeID::new("shape")
  before.add_node(
    Node::create_shape(
      id,
      "Before",
      @shapes.ShapeGeometry::rectangle(10.0, 10.0, 0.0, 0.0),
      @shapes.Style::default(),
    ),
    None,
  )
  let after = @scenegraph.ArtboardDocument::new("Diff", 100.0, 100.0)
  after.add_node(
    {
      ..Node::create_shape(
        id,
        "After",
        @shapes.ShapeGeometry::rectangle(10.0, 10.0, 0.0, 0.0),
        @shapes.Style::default(),
      ),
      opacity: 0.5,
    },
    None,
  )
  let added_id = NodeID::new("added")
  after.add_node(Node::create_group(added_id, "Added", []), None)
  let diff = before.diff(after)
  assert_eq(diff.added, [added_id])
  assert_eq(diff.removed.length(), 0)
  assert_eq(diff.modified, [id])
  assert_true(diff.has_changes())
}
