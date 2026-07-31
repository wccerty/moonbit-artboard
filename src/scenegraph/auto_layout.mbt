// Flexbox Auto-Layout Engine for modern responsive UI framing.

///|
pub(all) enum LayoutDirection {
  Horizontal
  Vertical
} derive(Eq, Debug)

///|
pub(all) enum LayoutAlignment {
  Start
  Center
  End
  SpaceBetween
} derive(Eq, Debug)

///|
pub(all) struct Padding {
  top : Double
  right : Double
  bottom : Double
  left : Double
} derive(Eq, Debug)

///|
pub fn Padding::all(v : Double) -> Padding {
  { top: v, right: v, bottom: v, left: v }
}

///|
pub fn Padding::symmetric(h : Double, v : Double) -> Padding {
  { top: v, right: h, bottom: v, left: h }
}

///|
pub(all) struct AutoLayoutConfig {
  direction : LayoutDirection
  alignment : LayoutAlignment
  gap : Double
  padding : Padding
} derive(Eq, Debug)

///|
pub fn apply_auto_layout(
  doc : ArtboardDocument,
  frame_id : NodeID,
  config : AutoLayoutConfig,
) -> Unit {
  match doc.get_node(frame_id) {
    None => ()
    Some(frame_node) =>
      match frame_node.node_type {
        GroupNode(children) => {
          let mut curr_x = config.padding.left
          let mut curr_y = config.padding.top

          for i = 0; i < children.length(); i = i + 1 {
            let cid = children[i]
            match doc.get_node(cid) {
              Some(child) => {
                let bounds = child.local_bounds()
                let new_transform = @math.Matrix2D::translation(curr_x, curr_y)
                doc.update_node({ ..child, transform: new_transform })

                match config.direction {
                  Horizontal => curr_x = curr_x + bounds.width() + config.gap
                  Vertical => curr_y = curr_y + bounds.height() + config.gap
                }
              }
              None => ()
            }
          }
        }
        _ => ()
      }
  }
}
