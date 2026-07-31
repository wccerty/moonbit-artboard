// Smart Alignment Guides Engine (Edge & Center snap alignment).

///|
pub(all) enum GuideOrientation {
  Horizontal
  Vertical
} derive(Eq, Debug)

///|
pub(all) struct AlignmentGuide {
  orientation : GuideOrientation
  position : Double
  start_coord : Double
  end_coord : Double
} derive(Eq, Debug)

///|
pub(all) struct SnapResult {
  snapped_offset : @math.Vec2
  active_guides : Array[AlignmentGuide]
} derive(Debug)

///|
pub fn find_alignment_snaps(
  active_bounds : @math.Rect2D,
  other_bounds : Array[@math.Rect2D],
  threshold : Double,
) -> SnapResult {
  let mut snap_dx = 0.0
  let mut snap_dy = 0.0
  let guides : Array[AlignmentGuide] = []

  let act_min_x = active_bounds.min_x
  let act_mid_x = (active_bounds.min_x + active_bounds.max_x) * 0.5
  let act_max_x = active_bounds.max_x

  let act_min_y = active_bounds.min_y
  let act_mid_y = (active_bounds.min_y + active_bounds.max_y) * 0.5
  let act_max_y = active_bounds.max_y

  for i = 0; i < other_bounds.length(); i = i + 1 {
    let oth = other_bounds[i]
    let oth_min_x = oth.min_x
    let oth_mid_x = (oth.min_x + oth.max_x) * 0.5
    let oth_max_x = oth.max_x

    let oth_min_y = oth.min_y
    let oth_mid_y = (oth.min_y + oth.max_y) * 0.5
    let oth_max_y = oth.max_y

    // X alignment
    if (act_min_x - oth_min_x).abs() <= threshold {
      snap_dx = oth_min_x - act_min_x
      guides.push({
        orientation: Vertical,
        position: oth_min_x,
        start_coord: act_min_y,
        end_coord: oth_max_y,
      })
    } else if (act_mid_x - oth_mid_x).abs() <= threshold {
      snap_dx = oth_mid_x - act_mid_x
      guides.push({
        orientation: Vertical,
        position: oth_mid_x,
        start_coord: act_min_y,
        end_coord: oth_max_y,
      })
    } else if (act_max_x - oth_max_x).abs() <= threshold {
      snap_dx = oth_max_x - act_max_x
      guides.push({
        orientation: Vertical,
        position: oth_max_x,
        start_coord: act_min_y,
        end_coord: oth_max_y,
      })
    }

    // Y alignment
    if (act_min_y - oth_min_y).abs() <= threshold {
      snap_dy = oth_min_y - act_min_y
      guides.push({
        orientation: Horizontal,
        position: oth_min_y,
        start_coord: act_min_x,
        end_coord: oth_max_x,
      })
    } else if (act_mid_y - oth_mid_y).abs() <= threshold {
      snap_dy = oth_mid_y - act_mid_y
      guides.push({
        orientation: Horizontal,
        position: oth_mid_y,
        start_coord: act_min_x,
        end_coord: oth_max_x,
      })
    } else if (act_max_y - oth_max_y).abs() <= threshold {
      snap_dy = oth_max_y - act_max_y
      guides.push({
        orientation: Horizontal,
        position: oth_max_y,
        start_coord: act_min_x,
        end_coord: oth_max_x,
      })
    }
  }

  { snapped_offset: @math.Vec2::new(snap_dx, snap_dy), active_guides: guides }
}
