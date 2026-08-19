// Strict JSON parser used by the document decoder.

///|
pub(all) struct JsonDecodeError {
  position : Int
  message : String
} derive(Eq, Debug)

///|
pub fn JsonDecodeError::new(
  position : Int,
  message : String,
) -> JsonDecodeError {
  { position, message }
}

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
    let ch = json_char_at(self.src, self.pos)
    if ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r' {
      self.pos = self.pos + 1
    } else {
      break
    }
  }
}

///|
fn[T] json_error(
  tokenizer : JsonTokenizer,
  message : String,
) -> Result[T, JsonDecodeError] {
  Err(JsonDecodeError::new(tokenizer.pos, message))
}

///|
fn[T, U] json_result_map(
  result : Result[T, JsonDecodeError],
  transform : (T) -> U,
) -> Result[U, JsonDecodeError] {
  match result {
    Ok(value) => Ok(transform(value))
    Err(error) => Err(error)
  }
}

///|
fn json_char_at(src : String, index : Int) -> Char {
  src[index].to_int().unsafe_to_char()
}

///|
fn json_is_digit(ch : Char) -> Bool {
  ch >= '0' && ch <= '9'
}

///|
fn json_is_hex_digit(ch : Char) -> Bool {
  (ch >= '0' && ch <= '9') ||
  (ch >= 'a' && ch <= 'f') ||
  (ch >= 'A' && ch <= 'F')
}

///|
fn json_hex_value(ch : Char) -> Int {
  if ch >= '0' && ch <= '9' {
    ch.to_int() - '0'.to_int()
  } else if ch >= 'a' && ch <= 'f' {
    ch.to_int() - 'a'.to_int() + 10
  } else {
    ch.to_int() - 'A'.to_int() + 10
  }
}

///|
fn JsonTokenizer::peek(self : JsonTokenizer) -> Char? {
  if self.pos < self.src.length() {
    Some(json_char_at(self.src, self.pos))
  } else {
    None
  }
}

///|
fn JsonTokenizer::consume(self : JsonTokenizer) -> Char? {
  match self.peek() {
    Some(ch) => {
      self.pos = self.pos + 1
      Some(ch)
    }
    None => None
  }
}

///|
fn JsonTokenizer::expect_char(
  self : JsonTokenizer,
  expected : Char,
) -> Result[Unit, JsonDecodeError] {
  self.skip_whitespace()
  match self.consume() {
    Some(ch) if ch == expected => Ok(())
    Some(_) => json_error(self, "expected '" + expected.to_string() + "'")
    None => json_error(self, "unexpected end of input")
  }
}

///|
fn JsonTokenizer::parse_string_checked(
  self : JsonTokenizer,
) -> Result[String, JsonDecodeError] {
  self.skip_whitespace()
  match self.consume() {
    Some('"') => {
      let mut result = ""
      while true {
        match self.consume() {
          None => return json_error(self, "unterminated string")
          Some('"') => return Ok(result)
          Some('\\') =>
            match self.consume() {
              Some('"') => result = result + "\""
              Some('\\') => result = result + "\\"
              Some('/') => result = result + "/"
              Some('b') => result = result + "\u{0008}"
              Some('f') => result = result + "\u{000c}"
              Some('n') => result = result + "\n"
              Some('r') => result = result + "\r"
              Some('t') => result = result + "\t"
              Some('u') => {
                let mut codepoint = 0
                for i = 0; i < 4; i = i + 1 {
                  match self.consume() {
                    Some(hex) if json_is_hex_digit(hex) =>
                      codepoint = codepoint * 16 + json_hex_value(hex)
                    Some(_) => return json_error(self, "invalid unicode escape")
                    None => return json_error(self, "truncated unicode escape")
                  }
                }
                result = result + codepoint.unsafe_to_char().to_string()
              }
              Some(_) => return json_error(self, "invalid escape sequence")
              None => return json_error(self, "truncated escape sequence")
            }
          Some(ch) if ch.to_int() < 0x20 =>
            return json_error(self, "control character in string")
          Some(ch) => result = result + ch.to_string()
        }
      } nobreak {
        json_error(self, "unterminated string")
      }
    }
    Some(_) => json_error(self, "expected string")
    None => json_error(self, "unexpected end of input")
  }
}

///|
fn JsonTokenizer::consume_literal(
  self : JsonTokenizer,
  literal : String,
) -> Result[Unit, JsonDecodeError] {
  for i = 0; i < literal.length(); i = i + 1 {
    match self.consume() {
      Some(ch) if ch == json_char_at(literal, i) => ()
      _ => return json_error(self, "invalid literal")
    }
  }
  Ok(())
}

///|
fn JsonTokenizer::parse_number_checked(
  self : JsonTokenizer,
) -> Result[Double, JsonDecodeError] {
  self.skip_whitespace()
  let start = self.pos
  let mut negative = false
  match self.peek() {
    Some('-') => {
      negative = true
      self.pos = self.pos + 1
    }
    _ => ()
  }

  let integer_start = self.pos
  match self.peek() {
    Some('0') => {
      self.pos = self.pos + 1
      if self.pos < self.src.length() &&
        json_is_digit(json_char_at(self.src, self.pos)) {
        return json_error(self, "leading zero in number")
      }
    }
    Some(ch) if json_is_digit(ch) =>
      while self.pos < self.src.length() &&
            json_is_digit(json_char_at(self.src, self.pos)) {
        self.pos = self.pos + 1
      }
    _ => return json_error(self, "expected number")
  }
  if self.pos == integer_start {
    return json_error(self, "expected number")
  }

  let mut fraction_digits = 0
  if self.peek() == Some('.') {
    self.pos = self.pos + 1
    let fraction_start = self.pos
    while self.pos < self.src.length() &&
          json_is_digit(json_char_at(self.src, self.pos)) {
      self.pos = self.pos + 1
    }
    fraction_digits = self.pos - fraction_start
    if fraction_digits == 0 {
      return json_error(self, "fraction requires digits")
    }
  }

  let mut exponent = 0
  let mut exponent_negative = false
  if self.peek() == Some('e') || self.peek() == Some('E') {
    self.pos = self.pos + 1
    match self.peek() {
      Some('-') => {
        exponent_negative = true
        self.pos = self.pos + 1
      }
      Some('+') => self.pos = self.pos + 1
      _ => ()
    }
    let exponent_start = self.pos
    while self.pos < self.src.length() &&
          json_is_digit(json_char_at(self.src, self.pos)) {
      exponent = exponent * 10 +
        (json_char_at(self.src, self.pos).to_int() - '0'.to_int())
      self.pos = self.pos + 1
    }
    if self.pos == exponent_start {
      return json_error(self, "exponent requires digits")
    }
  }

  let source = self.src[start:self.pos].to_owned()
  let mut value = 0.0
  let mut decimal_seen = false
  let mut decimal_scale = 1.0
  let mut index = 0
  while index < source.length() {
    let ch = json_char_at(source, index)
    if ch == '-' || ch == '+' {
      index = index + 1
    } else if ch == '.' {
      decimal_seen = true
      index = index + 1
    } else if ch == 'e' || ch == 'E' {
      break
    } else if json_is_digit(ch) {
      let digit = (ch.to_int() - '0'.to_int()).to_double()
      if decimal_seen {
        decimal_scale = decimal_scale * 10.0
        value = value + digit / decimal_scale
      } else {
        value = value * 10.0 + digit
      }
      index = index + 1
    } else {
      index = index + 1
    }
  }
  if exponent != 0 {
    let factor = @cmath.pow(10.0, exponent.to_double())
    value = if exponent_negative { value / factor } else { value * factor }
  }
  Ok(if negative { -value } else { value })
}

///|
fn JsonTokenizer::parse_value(
  self : JsonTokenizer,
) -> Result[JsonValue, JsonDecodeError] {
  self.skip_whitespace()
  match self.peek() {
    Some('n') =>
      json_result_map(self.consume_literal("null"), fn(_) { JsonValue::JNull })
    Some('t') =>
      json_result_map(self.consume_literal("true"), fn(_) {
        JsonValue::JBool(true)
      })
    Some('f') =>
      json_result_map(self.consume_literal("false"), fn(_) {
        JsonValue::JBool(false)
      })
    Some('"') =>
      json_result_map(self.parse_string_checked(), fn(value) {
        JsonValue::JString(value)
      })
    Some('[') => self.parse_array()
    Some('{') => self.parse_object()
    Some('-') =>
      json_result_map(self.parse_number_checked(), fn(value) {
        JsonValue::JNumber(value)
      })
    Some(ch) if json_is_digit(ch) =>
      json_result_map(self.parse_number_checked(), fn(value) {
        JsonValue::JNumber(value)
      })
    Some(_) => json_error(self, "unexpected token")
    None => json_error(self, "unexpected end of input")
  }
}

///|
fn JsonTokenizer::parse_array(
  self : JsonTokenizer,
) -> Result[JsonValue, JsonDecodeError] {
  ignore(self.expect_char('['))
  let values : Array[JsonValue] = []
  self.skip_whitespace()
  if self.peek() == Some(']') {
    ignore(self.consume())
    return Ok(JsonValue::JArray(values))
  }
  while true {
    let value = match self.parse_value() {
      Ok(item) => item
      Err(error) => return Err(error)
    }
    values.push(value)
    self.skip_whitespace()
    match self.consume() {
      Some(']') => return Ok(JsonValue::JArray(values))
      Some(',') => ()
      _ => return json_error(self, "expected ',' or ']'")
    }
  } nobreak {
    json_error(self, "unterminated array")
  }
}

///|
fn JsonTokenizer::parse_object(
  self : JsonTokenizer,
) -> Result[JsonValue, JsonDecodeError] {
  ignore(self.expect_char('{'))
  let fields : Map[String, JsonValue] = Map([])
  self.skip_whitespace()
  if self.peek() == Some('}') {
    ignore(self.consume())
    return Ok(JsonValue::JObject(fields))
  }
  while true {
    let key = match self.parse_string_checked() {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    match self.expect_char(':') {
      Ok(_) => ()
      Err(error) => return Err(error)
    }
    let value = match self.parse_value() {
      Ok(item) => item
      Err(error) => return Err(error)
    }
    fields[key] = value
    self.skip_whitespace()
    match self.consume() {
      Some('}') => return Ok(JsonValue::JObject(fields))
      Some(',') => ()
      _ => return json_error(self, "expected ',' or '}'")
    }
    self.skip_whitespace()
    if self.peek() == Some('}') {
      return json_error(self, "trailing comma in object")
    }
  } nobreak {
    json_error(self, "unterminated object")
  }
}

///|
pub fn parse_json(json_str : String) -> Result[JsonValue, JsonDecodeError] {
  let tokenizer = JsonTokenizer::new(json_str)
  let value = match tokenizer.parse_value() {
    Ok(parsed) => parsed
    Err(error) => return Err(error)
  }
  tokenizer.skip_whitespace()
  if tokenizer.pos != tokenizer.src.length() {
    Err(JsonDecodeError::new(tokenizer.pos, "trailing characters"))
  } else {
    Ok(value)
  }
}
