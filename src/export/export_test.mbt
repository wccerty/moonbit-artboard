// Export unit tests

///|
test "SVG Document Exporter" {
  let doc = @scenegraph.ArtboardDocument::new("SVG Test", 800.0, 600.0)

  let id1 = @scenegraph.NodeID::new("rect-1")
  let rect = @shapes.ShapeGeometry::rectangle(100.0, 50.0, 0.0, 0.0)
  doc.add_node(
    @scenegraph.Node::create_shape(id1, "R1", rect, @shapes.Style::default()),
    None,
  )

  let svg = export_to_svg(doc)
  inspect(
    svg.has_prefix("<svg xmlns=\"http://www.w3.org/2000/svg\""),
    content="true",
  )
  inspect(svg.contains("<rect"), content="true")
  inspect(svg.has_suffix("</svg>"), content="true")
}

///|
test "Canvas 2D Instructions Compiler" {
  let doc = @scenegraph.ArtboardDocument::new("Canvas Test", 800.0, 600.0)

  let id1 = @scenegraph.NodeID::new("rect-1")
  let rect = @shapes.ShapeGeometry::rectangle(100.0, 50.0, 0.0, 0.0)
  doc.add_node(
    @scenegraph.Node::create_shape(id1, "R1", rect, @shapes.Style::default()),
    None,
  )

  let cmds = generate_canvas_instructions(doc)
  inspect(cmds.length() > 0, content="true")
}

///|
test "PDF Exporter Adapter" {
  let doc = @scenegraph.ArtboardDocument::new("PDF Test", 800.0, 600.0)
  let pdf = export_to_pdf(doc)
  inspect(pdf.has_prefix("%PDF-1.4"), content="true")
  inspect(pdf.has_suffix("%%EOF"), content="true")
}

///|
test "HTML5 Canvas Code Generator" {
  let doc = @scenegraph.ArtboardDocument::new("Code Test", 800.0, 600.0)
  let code = export_to_html5_canvas_code(doc)
  inspect(code.contains("document.createElement('canvas')"), content="true")
}
