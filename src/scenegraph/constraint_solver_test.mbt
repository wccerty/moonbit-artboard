///|
test "constraint helpers snap and lay out grid children" {
  let grid = SnapGrid::new(8.0, @math.Vec2::zero())
  assert_eq(grid.snap_value(13.0), 16.0)
  assert_eq(
    grid.snap_point(@math.Vec2::new(13.0, 3.0)),
    @math.Vec2::new(16.0, 0.0),
  )
  let doc = @scenegraph.ArtboardDocument::new("Layout", 100.0, 100.0)
  let group_id = NodeID::new("group")
  doc.add_node(Node::create_group(group_id, "Grid", []), None)
  for i = 0; i < 4; i = i + 1 {
    doc.add_node(
      Node::create_shape(
        NodeID::new("cell-" + i.to_string()),
        "Cell",
        @shapes.ShapeGeometry::rectangle(10.0, 10.0, 0.0, 0.0),
        @shapes.Style::default(),
      ),
      Some(group_id),
    )
  }
  let placements = layout_grid(doc, group_id, 2, 4.0, @math.Vec2::new(2.0, 2.0))
  assert_eq(placements.length(), 4)
  assert_eq(doc.get_node(NodeID::new("cell-3")).unwrap().transform.tx, 16.0)
}
