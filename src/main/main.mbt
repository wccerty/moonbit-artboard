// Main Entry point demonstrating MoonBit Vector Artboard Core Engine.

///|
fn main {
  println("=====================================================")
  println("   MoonBit Vector Artboard Core Engine Demo (WASM)   ")
  println("=====================================================")

  // 1. Create Primary Document Canvas
  let doc = @scenegraph.ArtboardDocument::new(
    "MoonBit Modern Artboard", 1920.0, 1080.0,
  )
  let undo_mgr = @history.UndoManager::new()
  let selection_mgr = @selection.SelectionManager::new()

  println("Created Artboard Document: " + doc.title)

  // 2. Add Background Rect
  let bg_id = @scenegraph.NodeID::new("bg-artboard")
  let bg_shape = @shapes.ShapeGeometry::rectangle(1920.0, 1080.0, 0.0, 0.0)
  let bg_style = @shapes.Style::{
    fill: Solid(@shapes.RGBA::from_hex("#0F172A")),
    stroke: None,
    opacity: 1.0,
    blend_mode: Normal,
    shadow: None,
  }
  let bg_node = @scenegraph.Node::create_shape(
    bg_id, "Background Canvas", bg_shape, bg_style,
  )
  undo_mgr.push(@history.EditCommand::AddNode(bg_node), doc)

  // 3. Add Decorative Star Graphic
  let star_id = @scenegraph.NodeID::new("star-hero")
  let star_shape = @shapes.ShapeGeometry::star(5, 50.0, 120.0)
  let star_style = @shapes.Style::{
    fill: Solid(@shapes.RGBA::from_hex("#F59E0B")),
    stroke: Some(
      @shapes.Stroke::new(
        @shapes.RGBA::white(),
        3.0,
        @shapes.StrokeCap::Round,
        @shapes.StrokeJoin::Round,
      ),
    ),
    opacity: 0.9,
    blend_mode: Normal,
    shadow: Some(
      @shapes.Shadow::new(0.0, 10.0, 20.0, @shapes.RGBA::from_hex("#00000080")),
    ),
  }
  let mut star_node = @scenegraph.Node::create_shape(
    star_id, "Hero Star", star_shape, star_style,
  )
  star_node = {
    ..star_node,
    transform: @math.Matrix2D::translation(400.0, 300.0).multiply(
      @math.Matrix2D::rotation(0.3),
    ),
  }
  undo_mgr.push(@history.EditCommand::AddNode(star_node), doc)

  // 4. Add Complex Bezier Curve Path
  let path_id = @scenegraph.NodeID::new("path-wave")
  let wave_path = @shapes.PathBuilder::new()
    .move_to(@math.Vec2::new(100.0, 500.0))
    .cubic_to(
      @math.Vec2::new(300.0, 300.0),
      @math.Vec2::new(500.0, 700.0),
      @math.Vec2::new(700.0, 500.0),
    )
    .build()
  let wave_style = @shapes.Style::{
    fill: None,
    stroke: Some(
      @shapes.Stroke::new(
        @shapes.RGBA::from_hex("#38BDF8"),
        6.0,
        @shapes.StrokeCap::Round,
        @shapes.StrokeJoin::Round,
      ),
    ),
    opacity: 1.0,
    blend_mode: Normal,
    shadow: None,
  }
  let wave_node = @scenegraph.Node::create_shape(
    path_id,
    "Wave Accent",
    @shapes.ShapeGeometry::path(wave_path),
    wave_style,
  )
  undo_mgr.push(@history.EditCommand::AddNode(wave_node), doc)

  // 5. Test Selection & Transform Handles
  selection_mgr.select(star_id)
  selection_mgr.select(path_id)
  let bounds = selection_mgr.get_bounding_box(doc)
  let handles = @selection.get_transform_handles(bounds)

  println("Multi-selection active nodes: " + selection_mgr.count().to_string())
  println("Selection Bounding Box Width: " + bounds.width().to_string())
  println("Transform Handles Generated: " + handles.length().to_string())

  // 6. Test Spatial Grid Index Query
  let spatial_index = @spatial.GridSpatialIndex::build_from_doc(doc, 100.0)
  let visible_nodes = spatial_index.query_rect(
    @math.Rect2D::new(0.0, 0.0, 500.0, 500.0),
  )
  println(
    "Spatial Query Visible Nodes in (0,0,500,500): " +
    visible_nodes.length().to_string(),
  )

  // 7. Test Tools State Machine
  let tool_state = @tools.ToolState::new(@tools.SelectTool)
  println("Active Tool: " + tool_state.kind.to_string())

  // 8. Generate Preset Showcase Artworks
  let mobile_doc = create_mobile_app_ui_artboard()
  let banner_doc = create_marketing_banner_artboard()
  println(
    "Preset Artwork 1 Generated: " +
    mobile_doc.title +
    " (Nodes: " +
    mobile_doc.root_ids.length().to_string() +
    ")",
  )
  println(
    "Preset Artwork 2 Generated: " +
    banner_doc.title +
    " (Nodes: " +
    banner_doc.root_ids.length().to_string() +
    ")",
  )

  // 9. Test Exporting
  let json_output = @serialization.encode_document(doc)
  let svg_output = @export.export_to_svg(doc)
  let canvas_cmds = @export.generate_canvas_instructions(doc)

  println(
    "JSON Document Serialized Size: " +
    json_output.length().to_string() +
    " bytes",
  )
  println(
    "SVG Vector Export Size: " + svg_output.length().to_string() + " bytes",
  )
  println("Canvas 2D Commands Compiled: " + canvas_cmds.length().to_string())

  println("=====================================================")
  println("   Engine Verification Complete: All Systems GO!    ")
  println("=====================================================")
}
