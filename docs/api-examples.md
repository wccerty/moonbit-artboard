# API Examples

The examples below show the intended composition of the packages. They are
small fragments; a host application decides how to connect them to a UI.

## Build a document

~~~~mbt
let document = @scenegraph.ArtboardDocument::new("Demo", 800.0, 600.0)
let card = @scenegraph.Node::create_shape(
  @scenegraph.NodeID::new("card"),
  "Card",
  @shapes.ShapeGeometry::rectangle(240.0, 120.0, 12.0, 12.0),
  @shapes.Style::default(),
)
document.add_node(card, None)
~~~~

## Query and hit-test

~~~~mbt
let index = @spatial.GridSpatialIndex::build_from_doc(document, 64.0)
let candidates = @spatial.query_document(
  index,
  document,
  @math.Rect2D::new(0.0, 0.0, 400.0, 300.0),
  @spatial.SpatialQueryOptions::visible_only(),
)
let hit = @spatial.document_hit_test(document, @math.Vec2::new(50.0, 50.0))
~~~~

## Compile a render plan

~~~~mbt
let viewport = @viewport.Viewport::new(800.0, 600.0, 800.0, 600.0)
let plan = @render.compile_render_plan(document, Some(viewport))
let canvas_commands = @export.canvas_commands_from_plan(plan)
~~~~

## Checked persistence

~~~~mbt
let json = @serialization.encode_document(document)
match @serialization.decode_document_checked(json) {
  Ok(restored) => println(restored.title)
  Err(error) => println(error.message)
}
~~~~

For untrusted input, use the checked decoder so syntax and shape errors remain
visible to the caller. For deterministic exports, create the render plan once
and pass it to the selected backend adapter.
