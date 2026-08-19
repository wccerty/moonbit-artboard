///|
test "canvas adapter lowers a render plan without changing draw order" {
  let doc = @scenegraph.ArtboardDocument::new("Canvas", 100.0, 100.0)
  doc.add_node(
    @scenegraph.Node::create_shape(
      @scenegraph.NodeID::new("shape"),
      "Shape",
      @shapes.ShapeGeometry::rectangle(20.0, 20.0, 0.0, 0.0),
      @shapes.Style::default(),
    ),
    None,
  )
  let plan = @render.compile_render_plan(doc, None)
  let commands = canvas_commands_from_plan(plan)
  assert_true(commands.length() > 0)
  assert_true(commands.contains(Save))
  assert_true(commands.contains(BeginPath))
  assert_true(commands.contains(Fill))
  assert_true(commands.contains(Restore))
}

///|
test "SVG exporter escapes user-controlled text and URLs" {
  let doc = @scenegraph.ArtboardDocument::new("SVG", 100.0, 100.0)
  let text = @scenegraph.Node::create_text(
    @scenegraph.NodeID::new("text<&"),
    "Text",
    "<hello & \"world\">",
    14.0,
    "font&family",
    @shapes.Style::default(),
  )
  doc.add_node(text, None)
  let svg = export_to_svg(doc)
  assert_true(svg.contains("&lt;hello &amp; &quot;world&quot;&gt;"))
  assert_true(svg.contains("font&amp;family"))
  assert_false(svg.contains("><hello & \"world\"></text>"))
}
