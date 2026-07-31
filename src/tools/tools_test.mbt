// Tools & Alignment unit tests

///|
test "Tool state initialization" {
  let state = ToolState::new(SelectTool)
  inspect(state.kind == SelectTool, content="true")
  inspect(state.is_dragging, content="false")
}

///|
test "Alignment guides snap detection" {
  let active = @math.Rect2D::new(10.1, 10.0, 110.1, 110.0)
  let other = @math.Rect2D::new(10.0, 200.0, 110.0, 300.0)

  let result = find_alignment_snaps(active, [other], 1.0)
  inspect((result.snapped_offset.x - -0.1).abs() < 0.0001, content="true")
  inspect(result.active_guides.length() > 0, content="true")
}

///|
test "Pen Tool Curve Controller" {
  let pen = PenToolState::new()
  pen.add_point(@math.Vec2::new(0.0, 0.0))
  pen.add_point(@math.Vec2::new(100.0, 0.0))
  pen.drag_handle(@math.Vec2::new(50.0, 50.0))

  let path = pen.to_path()
  inspect(path.segments.length(), content="2")
}
