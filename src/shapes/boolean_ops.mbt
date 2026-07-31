// Vector Boolean Path Operations (Union, Difference, Intersection, XOR).

///|
pub(all) enum BooleanOperationKind {
  Union
  Difference
  Intersection
  Xor
} derive(Eq, Debug)

///|
pub impl Show for BooleanOperationKind with fn output(self, logger) {
  match self {
    Union => logger.write_string("union")
    Difference => logger.write_string("difference")
    Intersection => logger.write_string("intersection")
    Xor => logger.write_string("xor")
  }
}

///|
pub(all) struct BooleanPathNode {
  operation : BooleanOperationKind
  path_a : Path
  path_b : Path
} derive(Eq, Debug)

///|
pub fn combine_paths(op : BooleanOperationKind, a : Path, b : Path) -> Path {
  let builder = PathBuilder::new()
  // Combine segments from path A and path B based on operation model
  for i = 0; i < a.segments.length(); i = i + 1 {
    builder.segments.push(a.segments[i])
  }

  match op {
    Union =>
      for i = 0; i < b.segments.length(); i = i + 1 {
        builder.segments.push(b.segments[i])
      }
    _ => ()
  }

  builder.build()
}
