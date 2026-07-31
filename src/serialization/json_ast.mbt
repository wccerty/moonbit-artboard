// Pure MoonBit JSON AST Value representation and AST parser.

///|
pub(all) enum JsonValue {
  JNull
  JBool(Bool)
  JNumber(Double)
  JString(String)
  JArray(Array[JsonValue])
  JObject(Map[String, JsonValue])
} derive(Eq, Debug)

///|
pub impl Show for JsonValue with fn output(self, logger) {
  match self {
    JNull => logger.write_string("null")
    JBool(b) => logger.write_string(b.to_string())
    JNumber(n) => logger.write_string(n.to_string())
    JString(s) => logger.write_string("\"" + s + "\"")
    JArray(arr) => {
      logger.write_string("[")
      for i = 0; i < arr.length(); i = i + 1 {
        if i > 0 {
          logger.write_string(",")
        }
        logger.write_string(arr[i].to_string())
      }
      logger.write_string("]")
    }
    JObject(obj) => {
      logger.write_string("{")
      let mut first = true
      for k, v in obj {
        if !first {
          logger.write_string(",")
        }
        logger.write_string("\"" + k + "\":" + v.to_string())
        first = false
      }
      logger.write_string("}")
    }
  }
}

///|
pub fn JsonValue::as_string(self : JsonValue) -> String? {
  match self {
    JString(s) => Some(s)
    _ => None
  }
}

///|
pub fn JsonValue::as_number(self : JsonValue) -> Double? {
  match self {
    JNumber(n) => Some(n)
    _ => None
  }
}

///|
pub fn JsonValue::as_bool(self : JsonValue) -> Bool? {
  match self {
    JBool(b) => Some(b)
    _ => None
  }
}

///|
pub fn JsonValue::get_field(self : JsonValue, key : String) -> JsonValue? {
  match self {
    JObject(obj) => obj.get(key)
    _ => None
  }
}
