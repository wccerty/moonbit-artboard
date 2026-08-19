# Progress

## 2026-08-19 local acceptance work

- Completed the repository and competition self-audit using the available
  MoonBit guidance and the public osc2026-guide checklist.
- Kept OSC2026_August_Hackathon_Application.md unchanged; final SHA-256:
  FB37F61B02D1466BC147D1266848FCAE39132686BDF5680B8D907B081267AE04.
- Added production capabilities for numeric projection, path flattening and
  analysis, safe scene traversal and diffs, uniform-grid spatial queries,
  transformed hit testing, checked JSON/style persistence, viewport/render
  planning, export lowering, grid layout, and pointer interaction control.
- Added 91 passing tests, including malformed-input, cycle, degenerate
  geometry, transformed hit, viewport, marquee, export-escaping, style
  round-trip, and deterministic benchmark boundary cases.
- Added cmd/bench and recorded a real wasm-gc benchmark run in
  benchmarks/README.md; the second run preserved all checksums.
- Added scripts/count-moonbit-lines.ps1, which excludes tests and generated
  files and fails below 8,000 effective production lines. Current result:
  8,173 lines across 74 production files.
- Rewrote README into the requested open-source structure and added
  docs/architecture.md plus docs/api-examples.md.
- Replaced the CI workflow with stable-toolchain installation, interface and
  formatting checks, deny-warning checks, three-platform wasm-gc testing, and
  Ubuntu native verification/benchmark jobs.
- Local verification completed: moon fmt --check, moon check --deny-warn,
  moon info, moon test --deny-warn, moon run src/main --target wasm-gc,
  moon run cmd/bench --target wasm-gc, source counting, and git diff --check.
- The Windows native target remains blocked by the MoonBit runtime's
  env.c:181 rand_s declaration error; the CI native job is Ubuntu-only.
- No GitHub push, package publication, or external repository mutation was
  performed in this local phase.
