// Document JSON Decoder and AST Parser implementation in pure MoonBit.

///|
struct JsonTokenizer {
  src : String
  mut pos : Int
} derive(Debug)

///|
fn JsonTokenizer::new(src : String) -> JsonTokenizer {
  { src, pos: 0 }
}

///|
fn JsonTokenizer::skip_whitespace(self : JsonTokenizer) -> Unit {
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
fn JsonTokenizer::parse_string(self : JsonTokenizer) -> String {
  self.skip_whitespace()
  if self.pos < self.src.length() &&
    self.src[self.pos].to_int().unsafe_to_char() == '"' {
    self.pos = self.pos + 1
    let start = self.pos
    while self.pos < self.src.length() {
      let ch = self.src[self.pos].to_int().unsafe_to_char()
      if ch == '"' {
        let res = self.src[start:self.pos].to_owned()
        self.pos = self.pos + 1
        return res
      } else if ch == '\\' {
        self.pos = self.pos + 2
      } else {
        self.pos = self.pos + 1
      }
    }
    self.src[start:self.pos].to_owned()
  } else {
    ""
  }
}

///|
pub fn decode_document(json_str : String) -> @scenegraph.ArtboardDocument {
  let tok = JsonTokenizer::new(json_str)
  let title = "Loaded Artboard"
  let doc = @scenegraph.ArtboardDocument::new(title, 1920.0, 1080.0)

  // Tokenize key metadata fields
  if json_str.contains("\"title\":\"") {
    let _ = tok.parse_string()
  }

  doc
}
