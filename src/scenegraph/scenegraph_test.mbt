// SceneGraph unit tests

///|
test "Node creation and hierarchy" {
  let doc = ArtboardDocument::new("Test Doc", 800.0, 600.0)

  let rect_shape = @shapes.ShapeGeometry::rectangle(100.0, 50.0, 0.0, 0.0)
  let style = @shapes.Style::default()
  let id1 = NodeID::new("rect-1")
  let node1 = Node::create_shape(id1, "Rect 1", rect_shape, style)

  doc.add_node(node1, None)

  let fetched = doc.get_node(id1)
  inspect(fetched is None, content="false")

  let bounds = doc.get_world_bounds(id1)
  inspect(bounds.width(), content="100")
  inspect(bounds.height(), content="50")
}

///|
test "World transform accumulation" {
  let doc = ArtboardDocument::new("Transform Doc", 800.0, 600.0)

  let id1 = NodeID::new("group-1")
  let mut group = Node::create_group(id1, "Group 1", [])
  group = { ..group, transform: @math.Matrix2D::translation(100.0, 50.0) }
  doc.add_node(group, None)

  let id2 = NodeID::new("rect-2")
  let rect_shape = @shapes.ShapeGeometry::rectangle(50.0, 50.0, 0.0, 0.0)
  let mut child = Node::create_shape(
    id2,
    "Child Rect",
    rect_shape,
    @shapes.Style::default(),
  )
  child = { ..child, transform: @math.Matrix2D::translation(20.0, 10.0) }
  doc.add_node(child, Some(id1))

  let world_m = doc.get_world_matrix(id2)
  let origin = world_m.transform_point(@math.Vec2::zero())
  inspect(origin, content="{x: 120, y: 60}")
}

///|
test "Grouping and ungrouping" {
  let doc = ArtboardDocument::new("Group Doc", 800.0, 600.0)

  let id1 = NodeID::new("n1")
  let id2 = NodeID::new("n2")
  doc.add_node(
    Node::create_shape(
      id1,
      "N1",
      @shapes.ShapeGeometry::ellipse(10.0, 10.0),
      @shapes.Style::default(),
    ),
    None,
  )
  doc.add_node(
    Node::create_shape(
      id2,
      "N2",
      @shapes.ShapeGeometry::ellipse(20.0, 20.0),
      @shapes.Style::default(),
    ),
    None,
  )

  let gid_opt = doc.group_nodes([id1, id2])
  inspect(gid_opt is None, content="false")

  match gid_opt {
    Some(gid) => {
      let unassigned = doc.ungroup_node(gid)
      inspect(unassigned.length(), content="2")
    }
    None => ()
  }
}

///|
test "Auto Layout Flexbox Positioning" {
  let doc = ArtboardDocument::new("AutoLayout Doc", 800.0, 600.0)
  let frame_id = NodeID::new("frame")
  let c1 = NodeID::new("c1")
  let c2 = NodeID::new("c2")

  doc.add_node(Node::create_group(frame_id, "Frame", [c1, c2]), None)
  doc.add_node(
    Node::create_shape(
      c1,
      "C1",
      @shapes.ShapeGeometry::rectangle(100.0, 40.0, 0.0, 0.0),
      @shapes.Style::default(),
    ),
    Some(frame_id),
  )
  doc.add_node(
    Node::create_shape(
      c2,
      "C2",
      @shapes.ShapeGeometry::rectangle(100.0, 40.0, 0.0, 0.0),
      @shapes.Style::default(),
    ),
    Some(frame_id),
  )

  let config = AutoLayoutConfig::{
    direction: Horizontal,
    alignment: Start,
    gap: 20.0,
    padding: Padding::all(10.0),
  }
  apply_auto_layout(doc, frame_id, config)

  let p2 = doc.get_world_matrix(c2).transform_point(@math.Vec2::zero())
  inspect(p2.x > 0.0, content="true")
}

///|
test "Component Instantiation" {
  let doc = ArtboardDocument::new("Component Doc", 800.0, 600.0)
  let master_root = NodeID::new("master-root")
  doc.add_node(
    Node::create_shape(
      master_root,
      "Master Shape",
      @shapes.ShapeGeometry::ellipse(20.0, 20.0),
      @shapes.Style::default(),
    ),
    None,
  )

  let master = ComponentMaster::{
    id: NodeID::new("comp-m"),
    name: "Button",
    root_node_id: master_root,
  }
  let inst_id = NodeID::new("inst-1")
  let res = instantiate_component(doc, master, inst_id)
  inspect(res is None, content="false")
}

///|
test "Layout Constraints Resizing" {
  let b = @math.Rect2D::new(10.0, 10.0, 110.0, 110.0)
  let p_old = @math.Vec2::new(500.0, 500.0)
  let p_new = @math.Vec2::new(600.0, 600.0)
  let constraint = LayoutConstraint::{ horizontal: Right, vertical: Bottom }
  let res = apply_layout_constraints(b, p_old, p_new, constraint)
  inspect(res.min_x, content="110")
  inspect(res.min_y, content="110")
}
