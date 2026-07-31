// Code Generator adapter emitting standalone HTML5 Canvas/SVG snippets.

///|
pub fn export_to_html5_canvas_code(
  doc : @scenegraph.ArtboardDocument,
) -> String {
  let mut code = "const canvas = document.createElement('canvas');\n"
  code = code + "canvas.width = " + doc.width.to_string() + ";\n"
  code = code + "canvas.height = " + doc.height.to_string() + ";\n"
  code = code + "const ctx = canvas.getContext('2d');\n\n"

  let cmds = generate_canvas_instructions(doc)
  for i = 0; i < cmds.length(); i = i + 1 {
    match cmds[i] {
      Save => code = code + "ctx.save();\n"
      Restore => code = code + "ctx.restore();\n"
      SetTransform(m) =>
        code = code +
          "ctx.setTransform(" +
          m.a.to_string() +
          ", " +
          m.b.to_string() +
          ", " +
          m.c.to_string() +
          ", " +
          m.d.to_string() +
          ", " +
          m.tx.to_string() +
          ", " +
          m.ty.to_string() +
          ");\n"
      SetFillStyle(c) => code = code + "ctx.fillStyle = '" + c.to_hex() + "';\n"
      SetStrokeStyle(c, w) => {
        code = code + "ctx.strokeStyle = '" + c.to_hex() + "';\n"
        code = code + "ctx.lineWidth = " + w.to_string() + ";\n"
      }
      BeginPath => code = code + "ctx.beginPath();\n"
      MoveTo(p) =>
        code = code +
          "ctx.moveTo(" +
          p.x.to_string() +
          ", " +
          p.y.to_string() +
          ");\n"
      LineTo(p) =>
        code = code +
          "ctx.lineTo(" +
          p.x.to_string() +
          ", " +
          p.y.to_string() +
          ");\n"
      CubicTo(c1, c2, end) =>
        code = code +
          "ctx.bezierCurveTo(" +
          c1.x.to_string() +
          ", " +
          c1.y.to_string() +
          ", " +
          c2.x.to_string() +
          ", " +
          c2.y.to_string() +
          ", " +
          end.x.to_string() +
          ", " +
          end.y.to_string() +
          ");\n"
      ClosePath => code = code + "ctx.closePath();\n"
      Fill => code = code + "ctx.fill();\n"
      Stroke => code = code + "ctx.stroke();\n"
      _ => ()
    }
  }

  code
}
