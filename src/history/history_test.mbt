// History & Undo/Redo unit tests

///|
test "Undo/Redo Node Addition" {
  let doc = @scenegraph.ArtboardDocument::new("Undo Doc", 800.0, 600.0)
  let mgr = UndoManager::new()

  let id = @scenegraph.NodeID::new("node-1")
  let node = @scenegraph.Node::create_shape(
    id,
    "Shape 1",
    @shapes.ShapeGeometry::rectangle(100.0, 50.0, 0.0, 0.0),
    @shapes.Style::default(),
  )

  let add_cmd = EditCommand::AddNode(node)
  mgr.push(add_cmd, doc)

  inspect(doc.get_node(id) is None, content="false")
  inspect(mgr.can_undo(), content="true")

  ignore(mgr.undo(doc))
  inspect(doc.get_node(id) is None, content="true")
  inspect(mgr.can_redo(), content="true")

  ignore(mgr.redo(doc))
  inspect(doc.get_node(id) is None, content="false")
}

///|
test "Undo/Redo Node Transformation" {
  let doc = @scenegraph.ArtboardDocument::new("Transform Undo", 800.0, 600.0)
  let mgr = UndoManager::new()

  let id = @scenegraph.NodeID::new("node-t")
  let node = @scenegraph.Node::create_shape(
    id,
    "Shape T",
    @shapes.ShapeGeometry::rectangle(100.0, 50.0, 0.0, 0.0),
    @shapes.Style::default(),
  )
  doc.add_node(node, None)

  let m1 = @math.Matrix2D::identity()
  let m2 = @math.Matrix2D::translation(100.0, 200.0)

  let t_cmd = EditCommand::TransformNode({
    id,
    old_transform: m1,
    new_transform: m2,
  })
  mgr.push(t_cmd, doc)

  let p = doc.get_world_matrix(id).transform_point(@math.Vec2::zero())
  inspect(p, content="{x: 100, y: 200}")

  ignore(mgr.undo(doc))
  let p_undo = doc.get_world_matrix(id).transform_point(@math.Vec2::zero())
  inspect(p_undo, content="{x: 0, y: 0}")
}
