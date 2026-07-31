// Unique NodeID generator and identifier representation.

///|
pub(all) struct NodeID {
  value : String
} derive(Eq, Debug, Hash)

///|
pub impl Show for NodeID with fn output(self, logger) {
  logger.write_string(self.value)
}

///|
pub fn NodeID::new(val : String) -> NodeID {
  { value: val }
}

///|
let id_counter : Ref[Int] = { val: 1000 }

///|
pub fn NodeID::generate(prefix : String) -> NodeID {
  id_counter.val = id_counter.val + 1
  NodeID::new(prefix + "-" + id_counter.val.to_string())
}
