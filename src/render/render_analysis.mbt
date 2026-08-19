// Render-plan diagnostics for profiling and backend conformance checks.

///|
pub(all) struct RenderPlanReport {
  valid : Bool
  operation_count : Int
  draw_operation_count : Int
  max_save_depth : Int
  errors : Array[String]
} derive(Eq, Debug)

///|
fn render_op_is_draw(op : RenderOp) -> Bool {
  match op {
    DrawPath(_, _) | DrawText(_, _, _, _, _) | DrawImage(_, _, _) => true
    _ => false
  }
}

///|
pub fn RenderPlan::operation_count(self : RenderPlan) -> Int {
  self.ops.length()
}

///|
pub fn RenderPlan::draw_operation_count(self : RenderPlan) -> Int {
  let mut count = 0
  for i = 0; i < self.ops.length(); i = i + 1 {
    if render_op_is_draw(self.ops[i]) {
      count = count + 1
    }
  }
  count
}

///|
pub fn RenderPlan::estimated_cost(self : RenderPlan) -> Int {
  let mut cost = 0
  for i = 0; i < self.ops.length(); i = i + 1 {
    let weight = match self.ops[i] {
      Save | Restore => 1
      SetTransform(_) => 2
      SetOpacity(_) => 2
      DrawPath(path, style) => {
        ignore(style)
        5 + path.segments.length() * 2
      }
      DrawText(text, position, size, family, style) => {
        ignore(position)
        ignore(size)
        ignore(family)
        ignore(style)
        4 + text.length()
      }
      DrawImage(src, bounds, opacity) => {
        ignore(bounds)
        ignore(opacity)
        6 + src.length()
      }
    }
    cost = cost + weight
  }
  cost
}

///|
pub fn RenderPlan::validate(self : RenderPlan) -> RenderPlanReport {
  let errors : Array[String] = []
  let mut depth = 0
  let mut max_depth = 0
  for i = 0; i < self.ops.length(); i = i + 1 {
    match self.ops[i] {
      Save => {
        depth = depth + 1
        if depth > max_depth {
          max_depth = depth
        }
      }
      Restore =>
        if depth == 0 {
          errors.push("restore without save at operation " + i.to_string())
        } else {
          depth = depth - 1
        }
      SetOpacity(opacity) =>
        if opacity < 0.0 || opacity > 1.0 {
          errors.push("opacity outside [0,1] at operation " + i.to_string())
        }
      _ => ()
    }
  }
  if depth != 0 {
    errors.push("unbalanced save/restore stack")
  }
  {
    valid: errors.is_empty(),
    operation_count: self.operation_count(),
    draw_operation_count: self.draw_operation_count(),
    max_save_depth: max_depth,
    errors,
  }
}

///|
pub fn RenderPlan::has_draw_operations(self : RenderPlan) -> Bool {
  self.draw_operation_count() > 0
}

///|
pub fn RenderPlan::contains_transparency(self : RenderPlan) -> Bool {
  for i = 0; i < self.ops.length(); i = i + 1 {
    match self.ops[i] {
      SetOpacity(value) if value < 0.999999 => return true
      DrawPath(_, style) if style.opacity < 0.999999 => return true
      DrawText(_, _, _, _, style) if style.opacity < 0.999999 => return true
      _ => ()
    }
  }
  false
}

///|
pub fn RenderPlan::count_paths(self : RenderPlan) -> Int {
  let mut count = 0
  for i = 0; i < self.ops.length(); i = i + 1 {
    if self.ops[i] is DrawPath(_, _) {
      count = count + 1
    }
  }
  count
}
