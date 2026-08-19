// Structural validation for documents assembled by editors or decoders.

///|
pub(all) enum ValidationIssue {
  DuplicateNodeId(String)
  MissingParent(NodeID)
  MissingChild(NodeID, NodeID)
  ParentCycle(NodeID)
  OrphanNode(NodeID)
  InvalidDimension(NodeID)
  RootMismatch(NodeID)
} derive(Eq, Debug)

///|
pub(all) struct DocumentValidationReport {
  valid : Bool
  issues : Array[ValidationIssue]
} derive(Eq, Debug)

///|
fn visit_for_validation(
  doc : ArtboardDocument,
  id : NodeID,
  states : Map[String, Int],
  reachable : Map[String, Bool],
  issues : Array[ValidationIssue],
) -> Unit {
  match states.get(id.value) {
    Some(state) => if state == 1 { issues.push(ParentCycle(id)) }
    None =>
      match doc.nodes.get(id.value) {
        None => ()
        Some(node) => {
          states[id.value] = 1
          reachable[id.value] = true
          match node.parent_id {
            None => ()
            Some(parent_id) =>
              match doc.nodes.get(parent_id.value) {
                None => issues.push(MissingParent(id))
                Some(_) => ()
              }
          }
          match node.node_type {
            GroupNode(children) =>
              for i = 0; i < children.length(); i = i + 1 {
                let child_id = children[i]
                match doc.nodes.get(child_id.value) {
                  None => issues.push(MissingChild(id, child_id))
                  Some(child) => {
                    match child.parent_id {
                      None => issues.push(OrphanNode(child_id))
                      Some(parent_id) =>
                        if parent_id != id {
                          issues.push(OrphanNode(child_id))
                        }
                    }
                    visit_for_validation(
                      doc, child_id, states, reachable, issues,
                    )
                  }
                }
              }
            _ => ()
          }
          states[id.value] = 2
        }
      }
  }
}

///|
pub fn ArtboardDocument::validate(
  self : ArtboardDocument,
) -> DocumentValidationReport {
  let issues : Array[ValidationIssue] = []
  if self.width <= 0.0 {
    issues.push(InvalidDimension(NodeID::new("document.width")))
  }
  if self.height <= 0.0 {
    issues.push(InvalidDimension(NodeID::new("document.height")))
  }
  let states : Map[String, Int] = Map([])
  let reachable : Map[String, Bool] = Map([])
  for i = 0; i < self.root_ids.length(); i = i + 1 {
    let root_id = self.root_ids[i]
    match self.nodes.get(root_id.value) {
      None => issues.push(RootMismatch(root_id))
      Some(root) => {
        match root.parent_id {
          None => ()
          Some(_) => issues.push(RootMismatch(root_id))
        }
        visit_for_validation(self, root_id, states, reachable, issues)
      }
    }
  }
  for key, node in self.nodes {
    if node.id.value != key {
      issues.push(DuplicateNodeId(key))
    }
    match reachable.get(key) {
      Some(_) => ()
      None => issues.push(OrphanNode(node.id))
    }
  }
  { valid: issues.is_empty(), issues }
}
