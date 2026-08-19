///|
test "spatial document queries filter visibility and locks" {
  let doc = @scenegraph.ArtboardDocument::new("Filters", 100.0, 100.0)
  let visible_id = @scenegraph.NodeID::new("visible")
  doc.add_node(
    @scenegraph.Node::create_shape(
      visible_id,
      "Visible",
      @vshapes.ShapeGeometry::rectangle(10.0, 10.0, 0.0, 0.0),
      @vshapes.Style::default(),
    ),
    None,
  )
  let hidden_id = @scenegraph.NodeID::new("hidden")
  doc.add_node(
    {
      ..@scenegraph.Node::create_shape(
        hidden_id,
        "Hidden",
        @vshapes.ShapeGeometry::rectangle(10.0, 10.0, 0.0, 0.0),
        @vshapes.Style::default(),
      ),
      visible: false,
    },
    None,
  )
  let index = GridSpatialIndex::build_from_doc(doc, 16.0)
  let options = SpatialQueryOptions::visible_only()
  assert_true(
    query_document(index, doc, @math.Rect2D::new(0.0, 0.0, 20.0, 20.0), options).contains(
      visible_id,
    ),
  )
  assert_false(
    query_document(index, doc, @math.Rect2D::new(0.0, 0.0, 20.0, 20.0), options).contains(
      hidden_id,
    ),
  )
  assert_true(
    nearest_document_node(index, doc, @math.Vec2::new(4.0, 4.0), 20.0, options)
    is Some(_),
  )
}
