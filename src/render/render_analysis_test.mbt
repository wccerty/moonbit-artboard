///|
test "render plan validation detects stack and opacity errors" {
  let valid = RenderPlan::{
    ops: [RenderOp::Save, RenderOp::SetOpacity(0.5), RenderOp::Restore],
    stats: RenderStats::empty(),
  }
  assert_true(valid.validate().valid)
  let invalid = RenderPlan::{
    ops: [RenderOp::Restore, RenderOp::SetOpacity(2.0)],
    stats: RenderStats::empty(),
  }
  let report = invalid.validate()
  assert_false(report.valid)
  assert_true(report.errors.length() >= 2)
}

///|
test "render plan analysis counts operations and cost" {
  let plan = RenderPlan::{
    ops: [
      RenderOp::Save,
      RenderOp::SetTransform(@math.Matrix2D::identity()),
      RenderOp::DrawText(
        "text",
        @math.Vec2::zero(),
        12.0,
        "sans-serif",
        @shapes.Style::default(),
      ),
      RenderOp::Restore,
    ],
    stats: RenderStats::empty(),
  }
  assert_eq(plan.operation_count(), 4)
  assert_eq(plan.draw_operation_count(), 1)
  assert_true(plan.estimated_cost() > 0)
}
