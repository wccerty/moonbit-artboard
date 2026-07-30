// Color models, Hex parsing, HSL conversions, and color blending routines.

///|
fn char_at(s : String, idx : Int) -> Char {
  s[idx].to_int().unsafe_to_char()
}

///|
pub struct RGBA {
  r : Double // 0.0 .. 1.0
  g : Double // 0.0 .. 1.0
  b : Double // 0.0 .. 1.0
  a : Double // 0.0 .. 1.0
} derive(Eq, Debug)

///|
pub impl Show for RGBA with fn output(self, logger) {
  logger.write_string(self.to_hex())
}

///|
pub fn RGBA::new(r : Double, g : Double, b : Double, a : Double) -> RGBA {
  let clamp = fn(v : Double) -> Double {
    if v < 0.0 {
      0.0
    } else if v > 1.0 {
      1.0
    } else {
      v
    }
  }
  { r: clamp(r), g: clamp(g), b: clamp(b), a: clamp(a) }
}

///|
pub fn RGBA::from_bytes(r : Int, g : Int, b : Int, a : Double) -> RGBA {
  RGBA::new(
    r.to_double() / 255.0,
    g.to_double() / 255.0,
    b.to_double() / 255.0,
    a,
  )
}

///|
pub fn RGBA::black() -> RGBA {
  RGBA::new(0.0, 0.0, 0.0, 1.0)
}

///|
pub fn RGBA::white() -> RGBA {
  RGBA::new(1.0, 1.0, 1.0, 1.0)
}

///|
pub fn RGBA::transparent() -> RGBA {
  RGBA::new(0.0, 0.0, 0.0, 0.0)
}

///|
pub fn RGBA::red() -> RGBA {
  RGBA::new(1.0, 0.0, 0.0, 1.0)
}

///|
pub fn RGBA::green() -> RGBA {
  RGBA::new(0.0, 1.0, 0.0, 1.0)
}

///|
pub fn RGBA::blue() -> RGBA {
  RGBA::new(0.0, 0.0, 1.0, 1.0)
}

///|
fn hex_digit_value(ch : Char) -> Int {
  if ch >= '0' && ch <= '9' {
    ch.to_int() - '0'.to_int()
  } else if ch >= 'a' && ch <= 'f' {
    ch.to_int() - 'a'.to_int() + 10
  } else if ch >= 'A' && ch <= 'F' {
    ch.to_int() - 'A'.to_int() + 10
  } else {
    0
  }
}

///|
pub fn RGBA::from_hex(hex_str : String) -> RGBA {
  let s = if hex_str.has_prefix("#") { hex_str[1:].to_owned() } else { hex_str }
  let len = s.length()
  if len == 6 {
    let r = hex_digit_value(char_at(s, 0)) * 16 + hex_digit_value(char_at(s, 1))
    let g = hex_digit_value(char_at(s, 2)) * 16 + hex_digit_value(char_at(s, 3))
    let b = hex_digit_value(char_at(s, 4)) * 16 + hex_digit_value(char_at(s, 5))
    RGBA::from_bytes(r, g, b, 1.0)
  } else if len == 8 {
    let r = hex_digit_value(char_at(s, 0)) * 16 + hex_digit_value(char_at(s, 1))
    let g = hex_digit_value(char_at(s, 2)) * 16 + hex_digit_value(char_at(s, 3))
    let b = hex_digit_value(char_at(s, 4)) * 16 + hex_digit_value(char_at(s, 5))
    let a = hex_digit_value(char_at(s, 6)) * 16 + hex_digit_value(char_at(s, 7))
    RGBA::from_bytes(r, g, b, a.to_double() / 255.0)
  } else if len == 3 {
    let r = hex_digit_value(char_at(s, 0)) * 17
    let g = hex_digit_value(char_at(s, 1)) * 17
    let b = hex_digit_value(char_at(s, 2)) * 17
    RGBA::from_bytes(r, g, b, 1.0)
  } else {
    RGBA::black()
  }
}

///|
fn byte_to_hex(val : Int) -> String {
  let digits = [
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f',
  ]
  let d1 = digits[val / 16 % 16].to_string()
  let d2 = digits[val % 16].to_string()
  d1 + d2
}

///|
pub fn RGBA::to_hex(self : RGBA) -> String {
  let r_int = (self.r * 255.0 + 0.5).to_int()
  let g_int = (self.g * 255.0 + 0.5).to_int()
  let b_int = (self.b * 255.0 + 0.5).to_int()
  let a_int = (self.a * 255.0 + 0.5).to_int()

  if a_int >= 255 {
    "#" + byte_to_hex(r_int) + byte_to_hex(g_int) + byte_to_hex(b_int)
  } else {
    "#" +
    byte_to_hex(r_int) +
    byte_to_hex(g_int) +
    byte_to_hex(b_int) +
    byte_to_hex(a_int)
  }
}

///|
pub fn RGBA::blend(self : RGBA, overlay : RGBA) -> RGBA {
  let out_a = overlay.a + self.a * (1.0 - overlay.a)
  if out_a < 0.000000000001 {
    RGBA::transparent()
  } else {
    let r = (overlay.r * overlay.a + self.r * self.a * (1.0 - overlay.a)) /
      out_a
    let g = (overlay.g * overlay.a + self.g * self.a * (1.0 - overlay.a)) /
      out_a
    let b = (overlay.b * overlay.a + self.b * self.a * (1.0 - overlay.a)) /
      out_a
    RGBA::new(r, g, b, out_a)
  }
}

///|
pub fn RGBA::lerp(self : RGBA, target : RGBA, t : Double) -> RGBA {
  RGBA::new(
    self.r + (target.r - self.r) * t,
    self.g + (target.g - self.g) * t,
    self.b + (target.b - self.b) * t,
    self.a + (target.a - self.a) * t,
  )
}
