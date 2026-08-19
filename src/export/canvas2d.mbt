// Canvas 2D Rendering Instruction Stream Adapter.

///|
pub(all) enum CanvasCommand {
  Save
  Restore
  SetTransform(@math.Matrix2D)
  SetGlobalAlpha(Double)
  SetFillStyle(@shapes.RGBA)
  SetStrokeStyle(@shapes.RGBA, Double)
  BeginPath
  MoveTo(@math.Vec2)
  LineTo(@math.Vec2)
  QuadTo(@math.Vec2, @math.Vec2)
  CubicTo(@math.Vec2, @math.Vec2, @math.Vec2)
  ArcTo(Double, Double, Double, Bool, Bool, @math.Vec2)
  ClosePath
  Fill
  Stroke
  DrawText(String, @math.Vec2, Double, String)
  DrawImage(String, @math.Rect2D)
} derive(Eq, Debug)

///|
pub fn generate_canvas_instructions(
  doc : @scenegraph.ArtboardDocument,
) -> Array[CanvasCommand] {
  let cmds : Array[CanvasCommand] = []

  fn compile_node(id : @scenegraph.NodeID) -> Unit {
    match doc.get_node(id) {
      None => ()
      Some(node) => {
        if !node.visible {
          return
        }
        cmds.push(Save)
        cmds.push(SetTransform(node.transform))

        match node.node_type {
          GroupNode(children) =>
            for i = 0; i < children.length(); i = i + 1 {
              compile_node(children[i])
            }
          ShapeNode(s) => {
            cmds.push(BeginPath)
            let path = s.geometry.to_path()
            for i = 0; i < path.segments.length(); i = i + 1 {
              match path.segments[i] {
                MoveTo(p) => cmds.push(MoveTo(p))
                LineTo(p) => cmds.push(LineTo(p))
                CubicTo(c1, c2, end) => cmds.push(CubicTo(c1, c2, end))
                Close => cmds.push(ClosePath)
                _ => ()
              }
            }

            match s.style.fill {
              Solid(c) => {
                cmds.push(SetFillStyle(c))
                cmds.push(Fill)
              }
              _ => ()
            }

            match s.style.stroke {
              Some(st) => {
                cmds.push(SetStrokeStyle(st.color, st.width))
                cmds.push(Stroke)
              }
              None => ()
            }
          }
          TextNode(t) =>
            cmds.push(
              DrawText(t.text, @math.Vec2::zero(), t.font_size, t.font_family),
            )
          ImageNode(img) =>
            cmds.push(
              DrawImage(
                img.src,
                @math.Rect2D::new(0.0, 0.0, img.width, img.height),
              ),
            )
          ArtboardNode(_) => ()
        }

        cmds.push(Restore)
      }
    }
  }

  for i = 0; i < doc.root_ids.length(); i = i + 1 {
    compile_node(doc.root_ids[i])
  }

  cmds
}

///|
fn append_render_path(
  path : @shapes.Path,
  style : @shapes.Style,
  commands : Array[CanvasCommand],
) -> Unit {
  commands.push(BeginPath)
  for i = 0; i < path.segments.length(); i = i + 1 {
    match path.segments[i] {
      MoveTo(point) => commands.push(MoveTo(point))
      LineTo(point) => commands.push(LineTo(point))
      QuadTo(control, end) => commands.push(QuadTo(control, end))
      CubicTo(control1, control2, end) =>
        commands.push(CubicTo(control1, control2, end))
      ArcTo(rx, ry, rotation, large, sweep, end) =>
        commands.push(ArcTo(rx, ry, rotation, large, sweep, end))
      Close => commands.push(ClosePath)
    }
  }
  match style.fill {
    Solid(color) => {
      commands.push(SetFillStyle(color))
      commands.push(Fill)
    }
    _ => ()
  }
  match style.stroke {
    Some(stroke) => {
      commands.push(SetStrokeStyle(stroke.color, stroke.width))
      commands.push(Stroke)
    }
    None => ()
  }
}

///|
pub fn canvas_commands_from_plan(
  plan : @render.RenderPlan,
) -> Array[CanvasCommand] {
  let commands : Array[CanvasCommand] = []
  for i = 0; i < plan.ops.length(); i = i + 1 {
    match plan.ops[i] {
      @render.RenderOp::Save => commands.push(Save)
      @render.RenderOp::Restore => commands.push(Restore)
      @render.RenderOp::SetTransform(matrix) =>
        commands.push(SetTransform(matrix))
      @render.RenderOp::SetOpacity(opacity) =>
        commands.push(SetGlobalAlpha(opacity))
      @render.RenderOp::DrawPath(path, style) =>
        append_render_path(path, style, commands)
      @render.RenderOp::DrawText(text, position, size, family, _) =>
        commands.push(DrawText(text, position, size, family))
      @render.RenderOp::DrawImage(src, bounds, _) =>
        commands.push(DrawImage(src, bounds))
    }
  }
  commands
}
