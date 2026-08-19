// Pointer and keyboard vocabulary shared by editor front ends.

///|
pub(all) enum PointerButton {
  Primary
  Secondary
  Middle
} derive(Eq, Debug)

///|
pub(all) struct Modifiers {
  shift : Bool
  control : Bool
  alt : Bool
  meta : Bool
} derive(Eq, Debug)

///|
pub fn Modifiers::none() -> Modifiers {
  { shift: false, control: false, alt: false, meta: false }
}

///|
pub fn Modifiers::shift() -> Modifiers {
  { shift: true, control: false, alt: false, meta: false }
}

///|
pub fn Modifiers::with_shift(self : Modifiers, value : Bool) -> Modifiers {
  { ..self, shift: value }
}

///|
pub fn Modifiers::with_control(self : Modifiers, value : Bool) -> Modifiers {
  { ..self, control: value }
}

///|
pub fn Modifiers::with_alt(self : Modifiers, value : Bool) -> Modifiers {
  { ..self, alt: value }
}

///|
pub(all) struct PointerEvent {
  screen_position : @math.Vec2
  button : PointerButton
  modifiers : Modifiers
  pointer_id : Int
} derive(Eq, Debug)

///|
pub fn PointerEvent::new(
  screen_position : @math.Vec2,
  button : PointerButton,
  modifiers : Modifiers,
) -> PointerEvent {
  { screen_position, button, modifiers, pointer_id: 0 }
}

///|
pub fn PointerEvent::primary(screen_position : @math.Vec2) -> PointerEvent {
  PointerEvent::new(screen_position, Primary, Modifiers::none())
}

///|
pub fn PointerEvent::middle(screen_position : @math.Vec2) -> PointerEvent {
  PointerEvent::new(screen_position, Middle, Modifiers::none())
}

///|
pub fn PointerEvent::with_pointer_id(
  self : PointerEvent,
  pointer_id : Int,
) -> PointerEvent {
  { ..self, pointer_id, }
}

///|
pub fn PointerEvent::with_modifiers(
  self : PointerEvent,
  modifiers : Modifiers,
) -> PointerEvent {
  { ..self, modifiers, }
}

///|
pub(all) struct WheelEvent {
  screen_position : @math.Vec2
  delta_y : Double
  modifiers : Modifiers
} derive(Eq, Debug)

///|
pub fn WheelEvent::new(
  screen_position : @math.Vec2,
  delta_y : Double,
) -> WheelEvent {
  { screen_position, delta_y, modifiers: Modifiers::none() }
}

///|
pub fn WheelEvent::with_modifiers(
  self : WheelEvent,
  modifiers : Modifiers,
) -> WheelEvent {
  { ..self, modifiers, }
}

///|
pub(all) enum InteractionMode {
  Idle
  Marquee
  Translating
  Panning
} derive(Eq, Debug)

///|
pub(all) struct InteractionResult {
  consumed : Bool
  hit : @scenegraph.NodeID?
  marquee : @math.Rect2D?
  selection_changed : Bool
  viewport_changed : Bool
  mode : InteractionMode
} derive(Eq, Debug)

///|
fn interaction_result(
  consumed : Bool,
  hit : @scenegraph.NodeID?,
  marquee : @math.Rect2D?,
  selection_changed : Bool,
  viewport_changed : Bool,
  mode : InteractionMode,
) -> InteractionResult {
  { consumed, hit, marquee, selection_changed, viewport_changed, mode }
}
