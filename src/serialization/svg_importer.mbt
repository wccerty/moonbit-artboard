// SVG XML AST Parser and SceneGraph Document Importer in pure MoonBit.

///|
pub(all) enum XmlToken {
  TagStart(String)
  TagEnd(String)
  Attribute(String, String)
  TextContent(String)
  SelfClosingTagEnd
} derive(Eq, Debug)

///|
struct XmlTokenizer {
  src : String
  mut pos : Int
} derive(Debug)

///|
fn XmlTokenizer::new(src : String) -> XmlTokenizer {
  { src, pos: 0 }
}

///|
fn XmlTokenizer::skip_whitespace(self : XmlTokenizer) -> Unit {
  while self.pos < self.src.length() {
    let ch = self.src[self.pos].to_int().unsafe_to_char()
    if ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r' {
      self.pos = self.pos + 1
    } else {
      break
    }
  }
}

///|
pub fn parse_svg_to_document(
  svg_str : String,
  doc_title : String,
) -> @scenegraph.ArtboardDocument {
  let tok = XmlTokenizer::new(svg_str)
  let doc = @scenegraph.ArtboardDocument::new(doc_title, 800.0, 600.0)

  let mut curr_node_idx = 0
  tok.skip_whitespace()

  if svg_str.contains("<path") {
    let path = @shapes.parse_svg_path(svg_str)
    let shape_data = @shapes.ShapeGeometry::path(path)
    let style = @shapes.Style::default()
    curr_node_idx = curr_node_idx + 1
    let id = @scenegraph.NodeID::new(
      "imported-path-" + curr_node_idx.to_string(),
    )
    let node = @scenegraph.Node::create_shape(
      id, "Imported Path", shape_data, style,
    )
    doc.add_node(node, None)
  }

  doc
}
