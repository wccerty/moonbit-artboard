///|
test "grid index deduplicates items spanning multiple cells" {
  let index = GridSpatialIndex::new(10.0)
  let id = @scenegraph.NodeID::new("wide")
  index.insert(id, @math.Rect2D::new(2.0, 2.0, 28.0, 28.0))
  let matches = index.query_rect(@math.Rect2D::new(0.0, 0.0, 30.0, 30.0))
  assert_eq(matches.length(), 1)
  assert_eq(matches[0], id)
  let stats = index.stats()
  assert_eq(stats.item_count, 1)
  assert_true(stats.bucket_count >= 4)
}

///|
test "grid index updates and removes item memberships" {
  let index = GridSpatialIndex::new(10.0)
  let id = @scenegraph.NodeID::new("moving")
  index.insert(id, @math.Rect2D::new(0.0, 0.0, 4.0, 4.0))
  assert_eq(index.query_rect(@math.Rect2D::new(0.0, 0.0, 5.0, 5.0)).length(), 1)
  assert_true(index.update(id, @math.Rect2D::new(100.0, 100.0, 104.0, 104.0)))
  assert_eq(index.query_rect(@math.Rect2D::new(0.0, 0.0, 5.0, 5.0)).length(), 0)
  assert_eq(
    index.query_rect(@math.Rect2D::new(100.0, 100.0, 105.0, 105.0)).length(),
    1,
  )
  assert_true(index.remove(id))
  assert_false(index.remove(id))
  assert_eq(index.stats().item_count, 0)
}

///|
test "grid index includes child shapes when built from a document" {
  let doc = @scenegraph.ArtboardDocument::new("Children", 200.0, 200.0)
  let group_id = @scenegraph.NodeID::new("group")
  let child_id = @scenegraph.NodeID::new("child")
  doc.add_node(@scenegraph.Node::create_group(group_id, "Group", []), None)
  doc.add_node(
    @scenegraph.Node::create_shape(
      child_id,
      "Child",
      @vshapes.ShapeGeometry::rectangle(20.0, 20.0, 0.0, 0.0),
      @vshapes.Style::default(),
    ),
    Some(group_id),
  )
  let index = GridSpatialIndex::build_from_doc(doc, 10.0)
  let matches = index.query_rect(@math.Rect2D::new(0.0, 0.0, 21.0, 21.0))
  assert_true(matches.contains(child_id))
}
