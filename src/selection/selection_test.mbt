// Selection unit tests

///|
test "Selection Manager multi selection and bounds" {
  let mgr = SelectionManager::new()
  let id1 = @scenegraph.NodeID::new("n1")
  let id2 = @scenegraph.NodeID::new("n2")

  mgr.select(id1)
  mgr.select(id2)
  inspect(mgr.count(), content="2")
  inspect(mgr.is_selected(id1), content="true")

  mgr.deselect(id1)
  inspect(mgr.count(), content="1")
  inspect(mgr.is_selected(id1), content="false")
}

///|
test "Transform handles generation" {
  let bounds = @math.Rect2D::new(0.0, 0.0, 100.0, 100.0)
  let handles = get_transform_handles(bounds)
  inspect(handles.length(), content="9")
  inspect(handles[0].position, content="{x: 0, y: 0}")
  inspect(handles[4].position, content="{x: 100, y: 100}")
}
