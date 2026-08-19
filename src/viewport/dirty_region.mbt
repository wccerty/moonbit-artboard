// Dirty-region aggregation with a bounded escalation path for redraws.

///|
pub(all) struct DirtyRegion {
  mut bounds : @math.Rect2D
  mut full_redraw : Bool
  regions : Array[@math.Rect2D]
} derive(Eq, Debug)

///|
pub fn DirtyRegion::empty() -> DirtyRegion {
  { bounds: @math.Rect2D::empty(), full_redraw: false, regions: [] }
}

///|
fn dirty_adjacent(left : @math.Rect2D, right : @math.Rect2D) -> Bool {
  left.expand(0.000001).intersects(right)
}

///|
pub fn DirtyRegion::mark(self : DirtyRegion, bounds : @math.Rect2D) -> Unit {
  if bounds.is_empty() || self.full_redraw {
    return
  }
  let mut merged = bounds
  let remaining : Array[@math.Rect2D] = []
  for i = 0; i < self.regions.length(); i = i + 1 {
    let existing = self.regions[i]
    if dirty_adjacent(existing, merged) {
      merged = merged.union(existing)
    } else {
      remaining.push(existing)
    }
  }
  remaining.push(merged)
  self.regions.clear()
  for i = 0; i < remaining.length(); i = i + 1 {
    self.regions.push(remaining[i])
  }
  self.bounds = self.bounds.union(bounds)
  if self.regions.length() > 8 {
    self.full_redraw = true
  }
}

///|
pub fn DirtyRegion::merge(self : DirtyRegion, other : DirtyRegion) -> Unit {
  if other.full_redraw {
    self.full_redraw = true
    self.bounds = self.bounds.union(other.bounds)
    return
  }
  for i = 0; i < other.regions.length(); i = i + 1 {
    self.mark(other.regions[i])
  }
}

///|
pub fn DirtyRegion::needs_redraw(self : DirtyRegion) -> Bool {
  self.full_redraw || !self.regions.is_empty()
}
