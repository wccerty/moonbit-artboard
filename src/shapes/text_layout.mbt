// Advanced Text Typography & Multi-line Layout Engine.

///|
pub(all) struct TextLine {
  text : String
  width : Double
  height : Double
  baseline : Double
} derive(Eq, Debug)

///|
pub(all) struct TextLayoutResult {
  lines : Array[TextLine]
  total_width : Double
  total_height : Double
} derive(Eq, Debug)

///|
pub fn compute_text_layout(
  text : String,
  font_size : Double,
  max_width : Double,
  line_height_multiplier : Double,
) -> TextLayoutResult {
  let lines : Array[TextLine] = []
  let line_h = font_size * line_height_multiplier

  let words = text.split(" ")
  let mut curr_line = ""
  let mut curr_w = 0.0
  let mut max_w = 0.0

  for word in words {
    let word_str = word.to_owned()
    let word_w = word_str.length().to_double() * font_size * 0.6
    if curr_w + word_w > max_width && !curr_line.is_empty() {
      lines.push({
        text: curr_line,
        width: curr_w,
        height: line_h,
        baseline: font_size * 0.8,
      })
      if curr_w > max_w {
        max_w = curr_w
      }
      curr_line = word_str
      curr_w = word_w
    } else if !curr_line.is_empty() {
      curr_line = curr_line + " " + word_str
      curr_w = curr_w + font_size * 0.3 + word_w
    } else {
      curr_line = word_str
      curr_w = word_w
    }
  }

  if !curr_line.is_empty() {
    lines.push({
      text: curr_line,
      width: curr_w,
      height: line_h,
      baseline: font_size * 0.8,
    })
    if curr_w > max_w {
      max_w = curr_w
    }
  }

  let total_h = lines.length().to_double() * line_h
  { lines, total_width: max_w, total_height: total_h }
}
