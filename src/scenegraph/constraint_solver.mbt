// Grid snapping and deterministic child placement helpers.

///|
pub(all) struct SnapGrid {
  spacing : Double
  origin : @math.Vec2
}

///|
pub fn SnapGrid::new(spacing : Double, origin : @math.Vec2) -> SnapGrid {
  {
    spacing: if spacing.abs() < 0.000000000001 {
      1.0
    } else {
      spacing.abs()
    },
    origin,
  }
}

///|
pub fn SnapGrid::snap_value(self : SnapGrid, value : Double) -> Double {
  let normalized = (value - self.origin.x) / self.spacing
  let bucket = if normalized >= 0.0 {
    (normalized + 0.5).to_int()
  } else {
    (normalized - 0.5).to_int()
  }
  self.origin.x + bucket.to_double() * self.spacing
}

///|
pub fn SnapGrid::snap_point(self : SnapGrid, point : @math.Vec2) -> @math.Vec2 {
  let x_grid = self.snap_value(point.x)
  let y_grid = {
    let normalized = (point.y - self.origin.y) / self.spacing
    let bucket = if normalized >= 0.0 {
      (normalized + 0.5).to_int()
    } else {
      (normalized - 0.5).to_int()
    }
    self.origin.y + bucket.to_double() * self.spacing
  }
  @math.Vec2::new(x_grid, y_grid)
}

///|
pub(all) struct GridPlacement {
  node_id : NodeID
  position : @math.Vec2
} derive(Eq, Debug)

///|
pub fn layout_grid(
  document : ArtboardDocument,
  group_id : NodeID,
  columns : Int,
  gap : Double,
  origin : @math.Vec2,
) -> Array[GridPlacement] {
  let safe_columns = if columns < 1 { 1 } else { columns }
  let children = match document.get_node(group_id) {
    Some(node) =>
      match node.node_type {
        GroupNode(ids) => ids
        _ => []
      }
    None => []
  }
  let placements : Array[GridPlacement] = []
  let mut cell_width = 0.0
  let mut cell_height = 0.0
  for i = 0; i < children.length(); i = i + 1 {
    match document.get_node(children[i]) {
      Some(node) => {
        let bounds = node.local_bounds()
        if bounds.width() > cell_width {
          cell_width = bounds.width()
        }
        if bounds.height() > cell_height {
          cell_height = bounds.height()
        }
      }
      None => ()
    }
  }
  for i = 0; i < children.length(); i = i + 1 {
    let column = i % safe_columns
    let row = i / safe_columns
    let position = @math.Vec2::new(
      origin.x + column.to_double() * (cell_width + gap),
      origin.y + row.to_double() * (cell_height + gap),
    )
    let child_id = children[i]
    match document.get_node(child_id) {
      Some(node) => {
        document.update_node({
          ..node,
          transform: @math.Matrix2D::translation(position.x, position.y),
        })
        placements.push({ node_id: child_id, position })
      }
      None => ()
    }
  }
  placements
}
