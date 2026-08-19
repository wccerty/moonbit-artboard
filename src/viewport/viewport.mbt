// Camera state and world/screen coordinate conversion for editor surfaces.

///|
pub(all) struct Viewport {
  world_width : Double
  world_height : Double
  screen_width : Double
  screen_height : Double
  mut center : @math.Vec2
  mut zoom : Double
  device_pixel_ratio : Double
  min_zoom : Double
  max_zoom : Double
} derive(Eq, Debug)

///|
fn positive_dimension(value : Double) -> Double {
  if value > 0.0 {
    value
  } else {
    1.0
  }
}

///|
fn clamp_zoom(viewport : Viewport, zoom : Double) -> Double {
  if zoom < viewport.min_zoom {
    viewport.min_zoom
  } else if zoom > viewport.max_zoom {
    viewport.max_zoom
  } else {
    zoom
  }
}

///|
pub fn Viewport::new(
  world_width : Double,
  world_height : Double,
  screen_width : Double,
  screen_height : Double,
) -> Viewport {
  let normalized_world_width = positive_dimension(world_width)
  let normalized_world_height = positive_dimension(world_height)
  {
    world_width: normalized_world_width,
    world_height: normalized_world_height,
    screen_width: positive_dimension(screen_width),
    screen_height: positive_dimension(screen_height),
    center: @math.Vec2::new(
      normalized_world_width * 0.5,
      normalized_world_height * 0.5,
    ),
    zoom: 1.0,
    device_pixel_ratio: 1.0,
    min_zoom: 0.01,
    max_zoom: 64.0,
  }
}

///|
pub fn Viewport::world_rect(self : Viewport) -> @math.Rect2D {
  @math.Rect2D::new(0.0, 0.0, self.world_width, self.world_height)
}

///|
fn Viewport::screen_center(self : Viewport) -> @math.Vec2 {
  @math.Vec2::new(self.screen_width * 0.5, self.screen_height * 0.5)
}

///|
pub fn Viewport::world_to_screen(
  self : Viewport,
  point : @math.Vec2,
) -> @math.Vec2 {
  let screen_center = self.screen_center()
  @math.Vec2::new(
    (point.x - self.center.x) * self.zoom + screen_center.x,
    (point.y - self.center.y) * self.zoom + screen_center.y,
  )
}

///|
pub fn Viewport::screen_to_world(
  self : Viewport,
  point : @math.Vec2,
) -> @math.Vec2 {
  let screen_center = self.screen_center()
  @math.Vec2::new(
    (point.x - screen_center.x) / self.zoom + self.center.x,
    (point.y - screen_center.y) / self.zoom + self.center.y,
  )
}

///|
pub fn Viewport::visible_world_rect(self : Viewport) -> @math.Rect2D {
  @math.Rect2D::from_points([
    self.screen_to_world(@math.Vec2::new(0.0, 0.0)),
    self.screen_to_world(@math.Vec2::new(self.screen_width, 0.0)),
    self.screen_to_world(@math.Vec2::new(self.screen_width, self.screen_height)),
    self.screen_to_world(@math.Vec2::new(0.0, self.screen_height)),
  ])
}

///|
pub fn Viewport::pan_by(self : Viewport, delta_screen : @math.Vec2) -> Unit {
  self.center = @math.Vec2::new(
    self.center.x - delta_screen.x / self.zoom,
    self.center.y - delta_screen.y / self.zoom,
  )
}

///|
pub fn Viewport::zoom_at(
  self : Viewport,
  factor : Double,
  screen_point : @math.Vec2,
) -> Unit {
  let world_point = self.screen_to_world(screen_point)
  let target_zoom = clamp_zoom(self, self.zoom * factor)
  self.zoom = target_zoom
  let screen_center = self.screen_center()
  self.center = @math.Vec2::new(
    world_point.x - (screen_point.x - screen_center.x) / target_zoom,
    world_point.y - (screen_point.y - screen_center.y) / target_zoom,
  )
}

///|
pub fn Viewport::visible_nodes(
  self : Viewport,
  index : @spatial.GridSpatialIndex,
) -> Array[@scenegraph.NodeID] {
  index.query_rect(self.world_rect())
}
