// Fixed, deterministic documents used by the benchmark CLI.

///|
pub fn build_benchmark_document(
  sample_size : Int,
) -> @scenegraph.ArtboardDocument {
  let count = if sample_size < 1 { 1 } else { sample_size }
  let document = @scenegraph.ArtboardDocument::new(
    "Benchmark " + count.to_string(),
    4096.0,
    4096.0,
  )
  let group_id = @scenegraph.NodeID::new("benchmark-root")
  document.add_node(
    @scenegraph.Node::create_group(group_id, "Benchmark Root", []),
    None,
  )
  for i = 0; i < count; i = i + 1 {
    let x = (i % 64).to_double() * 62.0
    let y = (i / 64).to_double() * 62.0
    let geometry = if i % 3 == 0 {
      @shapes.ShapeGeometry::rectangle(48.0, 32.0, 4.0, 4.0)
    } else if i % 3 == 1 {
      @shapes.ShapeGeometry::ellipse(24.0, 16.0)
    } else {
      @shapes.ShapeGeometry::polygon(6, 26.0)
    }
    let node = @scenegraph.Node::create_shape(
      @scenegraph.NodeID::new("shape-" + i.to_string()),
      "Shape " + i.to_string(),
      geometry,
      @shapes.Style::default(),
    )
    document.add_node(
      {
        ..node,
        transform: @math.Matrix2D::translation(x, y).multiply(
          @math.Matrix2D::rotation((i % 11).to_double() * 0.017),
        ),
      },
      Some(group_id),
    )
  }
  document
}

///|
pub fn document_checksum(document : @scenegraph.ArtboardDocument) -> Int {
  let encoded = @serialization.encode_document(document)
  let traversal = document.traverse()
  let mut checksum = encoded.length() * 31 + traversal.length()
  for i = 0; i < traversal.length(); i = i + 1 {
    checksum = checksum + traversal[i].id.value.length() * (i + 1)
  }
  checksum
}
