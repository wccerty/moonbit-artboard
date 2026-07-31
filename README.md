# moonbit-artboard

> High-Performance Vector Artboard Data Model & Interactive Editing Engine written in pure **MoonBit** for WebAssembly (WASM-GC).

[![CI Test & Build](https://github.com/wccerty/moonbit-artboard/actions/workflows/ci.yml/badge.svg)](https://github.com/wccerty/moonbit-artboard/actions/workflows/ci.yml)
[![MoonBit Version](https://img.shields.io/badge/MoonBit-0.10.4-blue.svg)](https://www.moonbitlang.com/)
[![Target](https://img.shields.io/badge/Target-WASM--GC-orange.svg)](https://www.moonbitlang.com/)
[![License](https://img.shields.io/badge/License-Apache_2.0-green.svg)](LICENSE)

---

## 📌 Project Overview

`moonbit-artboard` is a production-grade, zero-dependency 2D vector graphic canvas and interactive design editor kernel built from scratch in MoonBit. It is designed to power WebAssembly-native graphic design applications, design tools, and vector node scene-graph manipulation engines (similar to Figma, Illustrator, and Canvas 2D kernels).

### 🌟 Key Features

- **2D & 3D Affine Geometry Engine**: Full 2D matrix transformation engine (`Matrix2D`), cubic/quadratic Bezier evaluation (`CubicBezier`, `QuadraticBezier`), 3D perspective transformation matrices (`Matrix4x4`), and Ear Clipping polygon triangulation algorithms.
- **Rich Vector Primitive Systems**: Rectangles (rounded corners), Ellipses, Polygons, N-Point Stars, Lines, Polylines, and pure MoonBit SVG Path string parser & tokenizer (`parse_svg_path`).
- **Scene-Graph Tree & Transform Hierarchy**: Document node tree with parent-child matrix accumulation (`ArtboardDocument`), Group/Ungroup node commands, layer z-ordering, and Flexbox-style Auto Layout framing engine.
- **Interactive Selection & Controllers**: Bounding box union calculations, 8-point resize handle controllers, rotation handles, and smart alignment guides with edge/center snapping.
- **Undo / Redo History Stack**: Command pattern transaction manager (`UndoManager`) supporting atomic operations, batch transactions, and history depth bounds.
- **Spatial Indexing & Hit Testing**: Winding number point-in-path hit testing and Grid Spatial Partitioning index for fast viewport culling.
- **Dual Exporter & Code Generator**: Native SVG document exporter (`export_to_svg`), Canvas 2D instruction stream compiler (`generate_canvas_instructions`), Vector PDF document adapter (`export_to_pdf`), and HTML5 Canvas code generator.

---

## 📊 Code Scale & Architecture Sitemap

This repository contains **5,713 lines** of clean, idiomatic MoonBit code across 10 modules:

| Module Package | Description | Submodules & Features |
| :--- | :--- | :--- |
| `src/math` | Math & Matrix Kernel | Vector algebra, 2D/3D affine matrix, Bezier curves, B-Splines, Triangulation |
| `src/shapes` | Vector Shapes & Color | RGBA color space, Hex parsing, Styles, Bezier path builders, Text typography, Boolean ops, Mesh Gradients |
| `src/scenegraph` | Scene-Graph Node Tree | Artboard document, Node repository, Layer z-index, Auto Layout, Component instances, Layout constraints |
| `src/spatial` | Spatial Indexing | Winding Number hit testing, Grid spatial index culling |
| `src/selection` | Selection Engine | Selection manager, 8-handle transform controllers |
| `src/history` | Undo / Redo Manager | Command pattern, Transaction manager, History stack |
| `src/tools` | Interactive Tool Engine | Tool state machine, Alignment guides, Interactive Pen tool bezier engine |
| `src/serialization` | Serialization & AST | Document JSON encoder, JsonValue AST parser, SVG XML importer |
| `src/export` | Export Adapters | SVG exporter, Canvas 2D instruction stream, PDF exporter, HTML5 Canvas code generator |
| `src/main` | Entry Demo | Integration showcase & preset artwork generation |

---

## 🚀 Quick Start & Build Instructions

### Prerequisites

- [MoonBit Compiler Toolchain](https://www.moonbitlang.com/download/) (v0.10.4 / latest)

### Build & Run Commands

```bash
# 1. Format code and check formatting compliance
moon fmt

# 2. Check package interface files
moon info

# 3. Run the full unit test suite (36 passing tests)
moon test

# 4. Compile and execute the main integration demo
moon run src/main
```

---

## 🏆 Open Source Competition (OSC 2026) Submission

This project is submitted to **OSC 2026 (Open Source Contest 2026)**.

- **Author & Contributor**: `wccerty` (Single contributor, fully matched across GitHub and GitLink).
- **GitHub Repository**: [https://github.com/wccerty/moonbit-artboard](https://github.com/wccerty/moonbit-artboard)
- **GitLink Repository**: [https://www.gitlink.org.cn/Wccerty/moonbit-artboard](https://www.gitlink.org.cn/Wccerty/moonbit-artboard)
- **License**: Apache-2.0 License
