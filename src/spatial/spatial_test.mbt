// Spatial unit tests

///|
test "Point in polygon hit test" {
  let poly = [
    @math.Vec2::new(0.0, 0.0),
    @math.Vec2::new(100.0, 0.0),
    @math.Vec2::new(100.0, 100.0),
    @math.Vec2::new(0.0, 100.0),
  ]
  let inside = point_in_polygon(@math.Vec2::new(50.0, 50.0), poly)
  let outside = point_in_polygon(@math.Vec2::new(150.0, 50.0), poly)

  inspect(inside, content="true")
  inspect(outside, content="false")
}

///|
test "Grid Spatial Index Culling" {
  let doc = @scenegraph.ArtboardDocument::new("Spatial Doc", 1000.0, 1000.0)

  let id1 = @scenegraph.NodeID::new("node-1")
  let id2 = @scenegraph.NodeID::new("node-2")

  let n1 = @scenegraph.Node::create_shape(
    id1,
    "N1",
    @vshapes.ShapeGeometry::rectangle(50.0, 50.0, 0.0, 0.0),
    @vshapes.Style::default(),
  )
  let mut n2 = @scenegraph.Node::create_shape(
    id2,
    "N2",
    @vshapes.ShapeGeometry::rectangle(50.0, 50.0, 0.0, 0.0),
    @vshapes.Style::default(),
  )
  n2 = { ..n2, transform: @math.Matrix2D::translation(500.0, 500.0) }

  doc.add_node(n1, None)
  doc.add_node(n2, None)

  let index = GridSpatialIndex::build_from_doc(doc, 100.0)
  let query = @math.Rect2D::new(0.0, 0.0, 200.0, 200.0)
  let matches = index.query_rect(query)

  inspect(matches.length(), content="1")
  inspect(matches[0].value, content="node-1")
}
