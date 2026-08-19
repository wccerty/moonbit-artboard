///|
test "render plan preserves traversal order, transforms, opacity, and stats" {
  let doc = @scenegraph.ArtboardDocument::new("Render", 400.0, 300.0)
  let group_id = @scenegraph.NodeID::new("group")
  let group = @scenegraph.Node::create_group(group_id, "Group", [])
  doc.add_node(group, None)
  let child_id = @scenegraph.NodeID::new("child")
  let child_base = @scenegraph.Node::create_shape(
    child_id,
    "Child",
    @shapes.ShapeGeometry::rectangle(20.0, 10.0, 0.0, 0.0),
    @shapes.Style::default(),
  )
  let child = {
    ..child_base,
    transform: @math.Matrix2D::translation(10.0, 15.0),
  }
  doc.add_node(child, Some(group_id))
  doc.update_node({ ..group, opacity: 0.5 })
  let text = @scenegraph.Node::create_text(
    @scenegraph.NodeID::new("text"),
    "Text",
    "hello",
    16.0,
    "sans-serif",
    @shapes.Style::default(),
  )
  doc.add_node(text, None)

  let plan = compile_render_plan(doc, None)
  assert_true(plan.ops.length() >= 10)
  assert_true(plan.ops[0] == RenderOp::Save)
  assert_true(plan.ops[1] == RenderOp::SetTransform(@math.Matrix2D::identity()))
  assert_true(plan.ops[2] == RenderOp::SetOpacity(0.5))
  assert_eq(plan.stats.visited_nodes, 3)
  assert_eq(plan.stats.visible_nodes, 3)
  assert_eq(plan.stats.culled_nodes, 0)
  assert_eq(plan.stats.draw_ops, 2)
  assert_true(plan.stats.path_segments >= 5)
}

///|
test "render plan omits invisible nodes and culls outside viewport" {
  let doc = @scenegraph.ArtboardDocument::new("Render", 100.0, 100.0)
  let visible_id = @scenegraph.NodeID::new("visible")
  doc.add_node(
    @scenegraph.Node::create_shape(
      visible_id,
      "Visible",
      @shapes.ShapeGeometry::rectangle(10.0, 10.0, 0.0, 0.0),
      @shapes.Style::default(),
    ),
    None,
  )
  let hidden_base = @scenegraph.Node::create_shape(
    @scenegraph.NodeID::new("hidden"),
    "Hidden",
    @shapes.ShapeGeometry::rectangle(10.0, 10.0, 0.0, 0.0),
    @shapes.Style::default(),
  )
  let hidden = { ..hidden_base, visible: false }
  doc.add_node(hidden, None)
  let outside_base = @scenegraph.Node::create_shape(
    @scenegraph.NodeID::new("outside"),
    "Outside",
    @shapes.ShapeGeometry::rectangle(10.0, 10.0, 0.0, 0.0),
    @shapes.Style::default(),
  )
  let outside = {
    ..outside_base,
    transform: @math.Matrix2D::translation(1000.0, 1000.0),
  }
  doc.add_node(outside, None)
  let viewport = @viewport.Viewport::new(100.0, 100.0, 100.0, 100.0)
  let plan = compile_render_plan(doc, Some(viewport))
  assert_eq(plan.stats.visited_nodes, 3)
  assert_eq(plan.stats.visible_nodes, 1)
  assert_eq(plan.stats.culled_nodes, 1)
  assert_eq(plan.stats.draw_ops, 1)
}
