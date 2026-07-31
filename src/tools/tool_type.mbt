// Interactive Tool State Machine types.

///|
pub(all) enum ToolKind {
  SelectTool
  RectangleTool
  EllipseTool
  StarTool
  PenTool
  PanTool
  ZoomTool
} derive(Eq, Debug)

///|
pub impl Show for ToolKind with fn output(self, logger) {
  match self {
    SelectTool => logger.write_string("Select")
    RectangleTool => logger.write_string("Rectangle")
    EllipseTool => logger.write_string("Ellipse")
    StarTool => logger.write_string("Star")
    PenTool => logger.write_string("Pen")
    PanTool => logger.write_string("Pan")
    ZoomTool => logger.write_string("Zoom")
  }
}

///|
pub(all) struct ToolState {
  kind : ToolKind
  is_dragging : Bool
  drag_start : @math.Vec2
  current_pos : @math.Vec2
} derive(Debug)

///|
pub fn ToolState::new(kind : ToolKind) -> ToolState {
  {
    kind,
    is_dragging: false,
    drag_start: @math.Vec2::zero(),
    current_pos: @math.Vec2::zero(),
  }
}
