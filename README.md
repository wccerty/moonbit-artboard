# MoonBit Artboard

[![CI](https://github.com/wccerty/moonbit-artboard/actions/workflows/ci.yml/badge.svg)](https://github.com/wccerty/moonbit-artboard/actions/workflows/ci.yml)
[![MoonBit](https://img.shields.io/badge/MoonBit-stable-blue)](https://www.moonbitlang.com/)
[![Target](https://img.shields.io/badge/target-WASM--GC-orange)](https://www.moonbitlang.com/)
[![License](https://img.shields.io/badge/license-Apache--2.0-green)](LICENSE)

## Project Overview

MoonBit Artboard is a dependency-light 2D vector editing kernel. It provides a
scene graph, affine geometry, shape-aware hit testing, viewport culling, a
backend-neutral render plan, checked document persistence, and export adapters
for applications that need a deterministic artboard model in WebAssembly.

The repository is organized as reusable MoonBit packages. The core model is
independent of a browser UI: a host can connect pointer events and render
commands to Canvas 2D, SVG, or another backend.

## Core Capabilities

- Affine geometry with vectors, rectangles, Bezier curves, path flattening,
  distance queries, triangulation, and transform decomposition.
- Vector primitives including rectangles, ellipses, polygons, stars, lines,
  polylines, SVG paths, gradients, strokes, shadows, and text metrics.
- Mutable scene graph with parent-child transforms, deterministic traversal,
  visibility and lock state, grouping, constraints, auto layout, validation,
  document queries, and structural diffs.
- Grid spatial index with reverse cell membership, query statistics, viewport
  culling, shape-aware hit testing, and transformed-node selection.
- Selection, transform handles, snapping, pointer gestures, marquee selection,
  pan/zoom control, and bounded undo/redo commands.
- Backend-neutral RenderPlan, Canvas 2D command lowering, SVG export, JSON
  encoding/checked decoding, SVG import, and a small PDF stream adapter.

## Quick Start

Install the current stable MoonBit toolchain, then run the project checks:

~~~~bash
moon fmt
moon info
moon check --deny-warn
moon test --deny-warn
moon run src/main
~~~~

The default target is wasm-gc, as declared in moon.mod. Native builds are also
useful for local tools and can be selected with --target native.

## CLI

The repository includes two runnable examples:

~~~~bash
# Integration showcase
moon run src/main

# Deterministic query → render → Canvas → JSON benchmark
moon run cmd/bench --target wasm-gc
~~~~

The benchmark command prints the target, sample size, iteration count, elapsed
microseconds, average time, and a checksum. The checksum makes it possible to
verify that repeated runs process the same result.

## Architecture

The data flow is intentionally layered:

~~~~text
ArtboardDocument
      │
      ├── traversal + validation + world bounds
      │       │
      │       ├── GridSpatialIndex / hit testing
      │       └── Viewport culling
      │
      └── RenderPlan
              ├── Canvas 2D command stream
              ├── SVG exporter
              └── host-specific renderer
~~~~

Package responsibilities and dependency direction are documented in
[docs/architecture.md](docs/architecture.md). A compact API walkthrough is
available in [docs/api-examples.md](docs/api-examples.md).

## Benchmarks

The benchmark measures one fixed workflow: spatial query, viewport-aware render
plan compilation, Canvas command lowering, and JSON encoding. It uses a
monotonic clock, one warm-up iteration, fixed inputs, and explicit checksums.

Reference wasm-gc run on 2026-08-19 with MoonBit 0.1.20260814:

| Sample nodes | Iterations | Total (µs) | Average (µs) | Checksum |
| ---: | ---: | ---: | ---: | ---: |
| 32 | 64 | 31,236.4 | 488.06875 | 1069760 |
| 256 | 24 | 557,916.9 | 23246.537500000002 | 3192672 |
| 1024 | 8 | 4,725,333.6 | 590666.7 | 4264920 |

These are target- and machine-specific measurements, not hardware-independent
performance claims. See [benchmarks/README.md](benchmarks/README.md) for the
methodology and source-count command.

## Testing

The current local suite contains 91 passing tests, including boundary cases
for malformed JSON, cycles, transformed hit testing, empty geometry, degenerate
curves, viewport edges, marquee selection, render culling, export escaping,
history limits, and deterministic benchmark inputs.

~~~~bash
moon fmt --check
moon check --deny-warn
moon test --deny-warn
~~~~

Production source size is measured by the repository script rather than by
counting documentation, generated interfaces, or test files:

~~~~powershell
pwsh -NoProfile -File scripts/count-moonbit-lines.ps1
~~~~

The current measured result is 8,173 effective MoonBit production lines across
74 source files.

## CI

.github/workflows/ci.yml runs on pushes, pull requests, and manual dispatch.
It installs the current stable MoonBit toolchain, checks formatting and
generated interfaces, runs deny-warning checks and the full test suite on
Ubuntu, macOS, and Windows, and runs the native benchmark/verification job on
Ubuntu.

The workflow uses read-only repository permissions and does not publish
artifacts or packages.

## License

MoonBit Artboard is available under the [Apache License 2.0](LICENSE).
