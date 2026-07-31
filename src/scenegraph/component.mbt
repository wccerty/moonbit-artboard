// Master Component & Instance system with property overrides.

///|
pub(all) struct ComponentMaster {
  id : NodeID
  name : String
  root_node_id : NodeID
} derive(Eq, Debug)

///|
pub(all) struct ComponentInstance {
  id : NodeID
  master_id : NodeID
  name_override : String?
  opacity_override : Double?
} derive(Eq, Debug)

///|
pub fn instantiate_component(
  doc : ArtboardDocument,
  master : ComponentMaster,
  instance_id : NodeID,
) -> NodeID? {
  match doc.get_node(master.root_node_id) {
    None => None
    Some(root) => {
      let instance_node = {
        ..root,
        id: instance_id,
        name: root.name + " (Instance)",
        parent_id: None,
      }
      doc.add_node(instance_node, None)
      Some(instance_id)
    }
  }
}
