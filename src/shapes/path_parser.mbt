// SVG Path Data String Parser and Formatter in pure MoonBit.

///|
fn is_digit(ch : Char) -> Bool {
  ch >= '0' && ch <= '9'
}

///|
fn is_whitespace(ch : Char) -> Bool {
  ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r' || ch == ','
}

///|
struct PathTokenizer {
  src : String
  mut pos : Int
} derive(Debug)

///|
fn PathTokenizer::new(src : String) -> PathTokenizer {
  { src, pos: 0 }
}

///|
fn PathTokenizer::skip_whitespace(self : PathTokenizer) -> Unit {
  while self.pos < self.src.length() &&
        is_whitespace(char_at(self.src, self.pos)) {
    self.pos = self.pos + 1
  }
}

///|
fn PathTokenizer::next_char(self : PathTokenizer) -> Char? {
  self.skip_whitespace()
  if self.pos >= self.src.length() {
    None
  } else {
    let ch = char_at(self.src, self.pos)
    self.pos = self.pos + 1
    Some(ch)
  }
}

///|
fn PathTokenizer::parse_number(self : PathTokenizer) -> Double {
  self.skip_whitespace()
  let start = self.pos
  if self.pos < self.src.length() {
    let c = char_at(self.src, self.pos)
    if c == '-' || c == '+' {
      self.pos = self.pos + 1
    }
  }
  let mut has_dot = false
  while self.pos < self.src.length() {
    let ch = char_at(self.src, self.pos)
    if is_digit(ch) {
      self.pos = self.pos + 1
    } else if ch == '.' && !has_dot {
      has_dot = true
      self.pos = self.pos + 1
    } else {
      break
    }
  }
  let sub = self.src[start:self.pos].to_owned()
  if sub.is_empty() {
    0.0
  } else {
    let mut sign = 1.0
    let mut idx = 0
    if char_at(sub, 0) == '-' {
      sign = -1.0
      idx = 1
    } else if char_at(sub, 0) == '+' {
      idx = 1
    }
    let mut int_part = 0.0
    let mut frac_part = 0.0
    let mut frac_div = 1.0
    let mut in_frac = false
    while idx < sub.length() {
      let ch = char_at(sub, idx)
      if ch == '.' {
        in_frac = true
      } else if is_digit(ch) {
        let d = (ch.to_int() - '0'.to_int()).to_double()
        if !in_frac {
          int_part = int_part * 10.0 + d
        } else {
          frac_div = frac_div * 10.0
          frac_part = frac_part + d / frac_div
        }
      }
      idx = idx + 1
    }
    sign * (int_part + frac_part)
  }
}

///|
pub fn parse_svg_path(path_str : String) -> Path {
  let tok = PathTokenizer::new(path_str)
  let builder = PathBuilder::new()
  let mut curr = @math.Vec2::zero()
  let mut start_p = @math.Vec2::zero()

  while true {
    match tok.next_char() {
      None => break
      Some(cmd) =>
        match cmd {
          'M' => {
            let x = tok.parse_number()
            let y = tok.parse_number()
            curr = @math.Vec2::new(x, y)
            start_p = curr
            ignore(builder.move_to(curr))
          }
          'm' => {
            let dx = tok.parse_number()
            let dy = tok.parse_number()
            curr = @math.Vec2::new(curr.x + dx, curr.y + dy)
            start_p = curr
            ignore(builder.move_to(curr))
          }
          'L' => {
            let x = tok.parse_number()
            let y = tok.parse_number()
            curr = @math.Vec2::new(x, y)
            ignore(builder.line_to(curr))
          }
          'l' => {
            let dx = tok.parse_number()
            let dy = tok.parse_number()
            curr = @math.Vec2::new(curr.x + dx, curr.y + dy)
            ignore(builder.line_to(curr))
          }
          'H' => {
            let x = tok.parse_number()
            curr = @math.Vec2::new(x, curr.y)
            ignore(builder.line_to(curr))
          }
          'h' => {
            let dx = tok.parse_number()
            curr = @math.Vec2::new(curr.x + dx, curr.y)
            ignore(builder.line_to(curr))
          }
          'V' => {
            let y = tok.parse_number()
            curr = @math.Vec2::new(curr.x, y)
            ignore(builder.line_to(curr))
          }
          'v' => {
            let dy = tok.parse_number()
            curr = @math.Vec2::new(curr.x, curr.y + dy)
            ignore(builder.line_to(curr))
          }
          'C' => {
            let x1 = tok.parse_number()
            let y1 = tok.parse_number()
            let x2 = tok.parse_number()
            let y2 = tok.parse_number()
            let x = tok.parse_number()
            let y = tok.parse_number()
            let c1 = @math.Vec2::new(x1, y1)
            let c2 = @math.Vec2::new(x2, y2)
            curr = @math.Vec2::new(x, y)
            ignore(builder.cubic_to(c1, c2, curr))
          }
          'c' => {
            let dx1 = tok.parse_number()
            let dy1 = tok.parse_number()
            let dx2 = tok.parse_number()
            let dy2 = tok.parse_number()
            let dx = tok.parse_number()
            let dy = tok.parse_number()
            let c1 = @math.Vec2::new(curr.x + dx1, curr.y + dy1)
            let c2 = @math.Vec2::new(curr.x + dx2, curr.y + dy2)
            curr = @math.Vec2::new(curr.x + dx, curr.y + dy)
            ignore(builder.cubic_to(c1, c2, curr))
          }
          'Q' => {
            let x1 = tok.parse_number()
            let y1 = tok.parse_number()
            let x = tok.parse_number()
            let y = tok.parse_number()
            let c1 = @math.Vec2::new(x1, y1)
            curr = @math.Vec2::new(x, y)
            ignore(builder.quad_to(c1, curr))
          }
          'q' => {
            let dx1 = tok.parse_number()
            let dy1 = tok.parse_number()
            let dx = tok.parse_number()
            let dy = tok.parse_number()
            let c1 = @math.Vec2::new(curr.x + dx1, curr.y + dy1)
            curr = @math.Vec2::new(curr.x + dx, curr.y + dy)
            ignore(builder.quad_to(c1, curr))
          }
          'Z' | 'z' => {
            ignore(builder.close_path())
            curr = start_p
          }
          _ => ()
        }
    }
  }

  builder.build()
}

///|
pub fn format_svg_path(path : Path) -> String {
  path.to_string()
}
