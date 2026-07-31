// Command pattern definitions for atomic artboard document undo/redo operations.

///|
pub(all) struct TransformDelta {
  id : @scenegraph.NodeID
  old_transform : @math.Matrix2D
  new_transform : @math.Matrix2D
} derive(Eq, Debug)

///|
pub(all) struct StyleDelta {
  id : @scenegraph.NodeID
  old_style : @shapes.Style
  new_style : @shapes.Style
} derive(Eq, Debug)

///|
pub(all) enum EditCommand {
  AddNode(@scenegraph.Node)
  DeleteNode(@scenegraph.Node)
  TransformNode(TransformDelta)
  StyleNode(StyleDelta)
  BatchCommand(String, Array[EditCommand])
} derive(Eq, Debug)

///|
pub fn EditCommand::execute(
  self : EditCommand,
  doc : @scenegraph.ArtboardDocument,
) -> Unit {
  match self {
    AddNode(node) => doc.add_node(node, node.parent_id)
    DeleteNode(node) => ignore(doc.remove_node(node.id))
    TransformNode(delta) =>
      match doc.get_node(delta.id) {
        Some(node) =>
          doc.update_node({ ..node, transform: delta.new_transform })
        None => ()
      }
    StyleNode(delta) =>
      match doc.get_node(delta.id) {
        Some(node) =>
          match node.node_type {
            ShapeNode(s) =>
              doc.update_node({
                ..node,
                node_type: ShapeNode({ ..s, style: delta.new_style }),
              })
            _ => ()
          }
        None => ()
      }
    BatchCommand(_, commands) =>
      for i = 0; i < commands.length(); i = i + 1 {
        commands[i].execute(doc)
      }
  }
}

///|
pub fn EditCommand::undo(
  self : EditCommand,
  doc : @scenegraph.ArtboardDocument,
) -> Unit {
  match self {
    AddNode(node) => ignore(doc.remove_node(node.id))
    DeleteNode(node) => doc.add_node(node, node.parent_id)
    TransformNode(delta) =>
      match doc.get_node(delta.id) {
        Some(node) =>
          doc.update_node({ ..node, transform: delta.old_transform })
        None => ()
      }
    StyleNode(delta) =>
      match doc.get_node(delta.id) {
        Some(node) =>
          match node.node_type {
            ShapeNode(s) =>
              doc.update_node({
                ..node,
                node_type: ShapeNode({ ..s, style: delta.old_style }),
              })
            _ => ()
          }
        None => ()
      }
    BatchCommand(_, commands) =>
      for i = commands.length() - 1; i >= 0; i = i - 1 {
        commands[i].undo(doc)
      }
  }
}
