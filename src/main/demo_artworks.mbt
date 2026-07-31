// Preset Showcase Artworks Generator for MoonBit Artboard Core Engine.

///|
pub fn create_mobile_app_ui_artboard() -> @scenegraph.ArtboardDocument {
  let doc = @scenegraph.ArtboardDocument::new("Mobile App Mockup", 390.0, 844.0)

  // 1. Mobile Phone Frame Background
  let bg_id = @scenegraph.NodeID::new("mobile-bg")
  let bg_shape = @shapes.ShapeGeometry::rectangle(390.0, 844.0, 40.0, 40.0)
  let bg_style = @shapes.Style::{
    fill: Solid(@shapes.RGBA::from_hex("#090D16")),
    stroke: Some(
      @shapes.Stroke::new(@shapes.RGBA::from_hex("#1E293B"), 2.0, Butt, Miter),
    ),
    opacity: 1.0,
    blend_mode: Normal,
    shadow: None,
  }
  doc.add_node(
    @scenegraph.Node::create_shape(bg_id, "Phone Frame", bg_shape, bg_style),
    None,
  )

  // 2. Header Status Bar & Title Text
  let title_id = @scenegraph.NodeID::new("app-title")
  let title_node = @scenegraph.Node::create_text(
    title_id,
    "App Header",
    "MoonBit Design System",
    22.0,
    "Inter",
    @shapes.Style::{
      fill: Solid(@shapes.RGBA::white()),
      stroke: None,
      opacity: 1.0,
      blend_mode: Normal,
      shadow: None,
    },
  )
  doc.add_node(
    { ..title_node, transform: @math.Matrix2D::translation(24.0, 60.0) },
    Some(bg_id),
  )

  // 3. Hero Card Group
  let card_id = @scenegraph.NodeID::new("hero-card")
  let card_shape = @shapes.ShapeGeometry::rectangle(342.0, 180.0, 20.0, 20.0)
  let card_style = @shapes.Style::{
    fill: LinearGradient(@math.Vec2::zero(), @math.Vec2::new(342.0, 180.0), [
      @shapes.GradientStop::new(0.0, @shapes.RGBA::from_hex("#6366F1")),
      @shapes.GradientStop::new(1.0, @shapes.RGBA::from_hex("#A855F7")),
    ]),
    stroke: None,
    opacity: 1.0,
    blend_mode: Normal,
    shadow: Some(
      @shapes.Shadow::new(0.0, 8.0, 16.0, @shapes.RGBA::from_hex("#6366F140")),
    ),
  }
  let card_node = @scenegraph.Node::create_shape(
    card_id, "Hero Card", card_shape, card_style,
  )
  doc.add_node(
    { ..card_node, transform: @math.Matrix2D::translation(24.0, 110.0) },
    Some(bg_id),
  )

  // 4. Action Button
  let btn_id = @scenegraph.NodeID::new("cta-button")
  let btn_shape = @shapes.ShapeGeometry::rectangle(160.0, 48.0, 24.0, 24.0)
  let btn_style = @shapes.Style::{
    fill: Solid(@shapes.RGBA::from_hex("#38BDF8")),
    stroke: None,
    opacity: 1.0,
    blend_mode: Normal,
    shadow: None,
  }
  let btn_node = @scenegraph.Node::create_shape(
    btn_id, "CTA Button", btn_shape, btn_style,
  )
  doc.add_node(
    { ..btn_node, transform: @math.Matrix2D::translation(24.0, 320.0) },
    Some(bg_id),
  )

  doc
}

///|
pub fn create_marketing_banner_artboard() -> @scenegraph.ArtboardDocument {
  let doc = @scenegraph.ArtboardDocument::new("Marketing Banner", 1200.0, 630.0)

  // Banner Base
  let base_id = @scenegraph.NodeID::new("banner-base")
  let base_shape = @shapes.ShapeGeometry::rectangle(1200.0, 630.0, 0.0, 0.0)
  let base_style = @shapes.Style::{
    fill: Solid(@shapes.RGBA::from_hex("#1E1E2E")),
    stroke: None,
    opacity: 1.0,
    blend_mode: Normal,
    shadow: None,
  }
  doc.add_node(
    @scenegraph.Node::create_shape(
      base_id, "Banner Base", base_shape, base_style,
    ),
    None,
  )

  // Geometric Star Accents
  for i = 0; i < 5; i = i + 1 {
    let star_id = @scenegraph.NodeID::new("accent-star-" + i.to_string())
    let star_shape = @shapes.ShapeGeometry::star(5, 15.0, 35.0)
    let star_style = @shapes.Style::{
      fill: Solid(@shapes.RGBA::from_hex("#F38BA8")),
      stroke: None,
      opacity: 0.8,
      blend_mode: Normal,
      shadow: None,
    }
    let x = 100.0 + i.to_double() * 220.0
    let y = 150.0 + (i % 2).to_double() * 200.0
    let mut star_node = @scenegraph.Node::create_shape(
      star_id, "Star Accent", star_shape, star_style,
    )
    star_node = { ..star_node, transform: @math.Matrix2D::translation(x, y) }
    doc.add_node(star_node, Some(base_id))
  }

  doc
}
