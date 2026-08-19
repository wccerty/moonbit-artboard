///|
test "pointer selection and translation stay in world coordinates" {
  let doc = @scenegraph.ArtboardDocument::new("Editor", 100.0, 100.0)
  let id = @scenegraph.NodeID::new("card")
  doc.add_node(
    @scenegraph.Node::create_shape(
      id,
      "Card",
      @shapes.ShapeGeometry::rectangle(20.0, 20.0, 10.0, 10.0),
      @shapes.Style::default(),
    ),
    None,
  )
  let controller = InteractionController::new(
    @viewport.Viewport::new(100.0, 100.0, 100.0, 100.0),
  )
  let down = controller.pointer_down(
    doc,
    PointerEvent::primary(@math.Vec2::new(10.0, 10.0)),
  )
  assert_true(down.hit == Some(id))
  ignore(
    controller.pointer_move(
      doc,
      PointerEvent::primary(@math.Vec2::new(22.0, 25.0)),
    ),
  )
  ignore(
    controller.pointer_up(
      doc,
      PointerEvent::primary(@math.Vec2::new(22.0, 25.0)),
    ),
  )
  assert_eq(controller.selection_count(), 1)
  assert_eq(doc.get_world_matrix(id).tx, 12.0)
  assert_eq(doc.get_world_matrix(id).ty, 15.0)
  assert_eq(controller.mode(), Idle)
}

///|
test "marquee selects intersecting nodes and normalizes reversed drag" {
  let doc = @scenegraph.ArtboardDocument::new("Editor", 200.0, 100.0)
  let first = @scenegraph.NodeID::new("first")
  let second = @scenegraph.NodeID::new("second")
  doc.add_node(
    @scenegraph.Node::create_shape(
      first,
      "First",
      @shapes.ShapeGeometry::rectangle(20.0, 20.0, 20.0, 20.0),
      @shapes.Style::default(),
    ),
    None,
  )
  doc.update_node({
    ..doc.get_node(first).unwrap(),
    transform: @math.Matrix2D::translation(20.0, 20.0),
  })
  doc.add_node(
    @scenegraph.Node::create_shape(
      second,
      "Second",
      @shapes.ShapeGeometry::rectangle(20.0, 20.0, 120.0, 20.0),
      @shapes.Style::default(),
    ),
    None,
  )
  doc.update_node({
    ..doc.get_node(second).unwrap(),
    transform: @math.Matrix2D::translation(120.0, 20.0),
  })
  let controller = InteractionController::new(
    @viewport.Viewport::new(200.0, 100.0, 200.0, 100.0),
  )
  ignore(
    controller.pointer_down(
      doc,
      PointerEvent::primary(@math.Vec2::new(80.0, 60.0)),
    ),
  )
  ignore(
    controller.pointer_move(
      doc,
      PointerEvent::primary(@math.Vec2::new(10.0, 10.0)),
    ),
  )
  let result = controller.pointer_up(
    doc,
    PointerEvent::primary(@math.Vec2::new(10.0, 10.0)),
  )
  assert_true(result.marquee is Some(_))
  assert_eq(controller.selection_count(), 1)
  assert_true(controller.is_selected(first))
  assert_true(!controller.is_selected(second))
}

///|
test "secondary and wheel gestures update the viewport without selecting" {
  let controller = InteractionController::new(
    @viewport.Viewport::new(100.0, 100.0, 100.0, 100.0),
  )
  ignore(
    controller.pointer_down(
      @scenegraph.ArtboardDocument::new("Editor", 100.0, 100.0),
      PointerEvent::middle(@math.Vec2::new(50.0, 50.0)),
    ),
  )
  ignore(
    controller.pointer_move(
      @scenegraph.ArtboardDocument::new("Editor", 100.0, 100.0),
      PointerEvent::middle(@math.Vec2::new(60.0, 55.0)),
    ),
  )
  ignore(
    controller.pointer_up(
      @scenegraph.ArtboardDocument::new("Editor", 100.0, 100.0),
      PointerEvent::middle(@math.Vec2::new(60.0, 55.0)),
    ),
  )
  assert_eq(controller.selection_count(), 0)
  let before = controller.viewport().zoom
  ignore(controller.wheel(WheelEvent::new(@math.Vec2::new(50.0, 50.0), 1.0)))
  assert_true(controller.viewport().zoom > before)
}
