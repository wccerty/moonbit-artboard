# Architecture

## Package graph

The project keeps the editing kernel in small packages so a host application
can depend on only the layers it needs.

| Package | Responsibility |
| --- | --- |
| src/math | Vectors, rectangles, matrices, curves, flattening, distances, and numeric tolerances |
| src/shapes | Shape geometry, paths, colors, styles, text metrics, and boolean helpers |
| src/scenegraph | Document storage, nodes, hierarchy, traversal, layout, constraints, validation, and diffs |
| src/spatial | Uniform-grid indexing, query policies, transformed hit testing, and statistics |
| src/selection | Selection state and transform handles |
| src/interaction | Pointer gestures, marquee selection, snapping, resize policies, and viewport control |
| src/viewport | Camera state, coordinate conversion, visible rectangles, and dirty regions |
| src/render | Viewport-aware backend-neutral render operations and cost analysis |
| src/serialization | JSON AST, strict parser, checked document decoder, style codec, and SVG import |
| src/export | SVG, Canvas 2D command lowering, generated Canvas code, and PDF stream adapter |
| src/history | Bounded command-based undo/redo |
| src/tools | Editor tool state, alignment guides, and pen-tool construction |

The main data path is:

~~~~text
scene graph → safe traversal → spatial/viewport filtering → RenderPlan
                                                       ├→ Canvas commands
                                                       └→ SVG/PDF adapters
~~~~

src/render does not depend on src/export; export adapters consume the render
plan at the package boundary. This keeps the render compiler usable by hosts
that do not use Canvas or SVG.

## Document invariants

ArtboardDocument::traverse is cycle-safe and computes accumulated transforms,
world bounds, depth, and inherited opacity in deterministic child order.
validate_document reports missing parents, duplicate references, cycles,
invalid dimensions, and malformed hierarchy relationships before a document is
persisted or rendered.

The checked JSON path uses parse_json and decode_document_checked. It returns
Result[ArtboardDocument, JsonDecodeError] with an error position and message;
the compatibility decode_document function remains available for callers that
use the older option-style API.

## Rendering and interaction

The render compiler emits save/restore operations around nodes, accumulates
world transforms and opacity, skips invisible subtrees, and culls nodes outside
an optional viewport. A RenderPlan records statistics for observability and
can be lowered to Canvas commands without coupling the compiler to a concrete
renderer.

The interaction controller converts screen coordinates through Viewport, uses
shape-aware document hit testing for primary-pointer selection, and supports
marquee, translation, pan, and wheel zoom gestures. Pure helpers in
src/interaction handle normalization, axis constraints, snapping, resize
policy, and safe boundary behavior so front ends can reuse them without
sharing mutable controller state.
