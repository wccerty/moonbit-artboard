# Benchmark suite

The benchmark CLI measures one fixed workflow across deterministic artboard sizes:

1. query a uniform-grid spatial index;
2. compile a viewport-aware backend-neutral render plan;
3. lower the plan to Canvas commands;
4. encode the document as JSON.

Run it locally with:

```text
moon run cmd/bench --target native
```

The CLI uses `moonbitlang/core/bench` monotonic timestamps, performs one warm-up
iteration, reports explicit sample sizes and iteration counts, and emits a
checksum for the measured result. Timing output is machine-dependent; commit
the command output together with the toolchain version when comparing runs.

The source-size statistic is intentionally separate from benchmark output:

```powershell
pwsh -File scripts/count-moonbit-lines.ps1
```

## Recorded run

The following run was captured locally on 2026-08-19 with MoonBit
`0.1.20260814` and the `wasm-gc` target:

| sample size | iterations | total (µs) | average (µs) | checksum |
| ---: | ---: | ---: | ---: | ---: |
| 32 | 64 | 31,236.4 | 488.06875 | 1069760 |
| 256 | 24 | 557,916.9 | 23246.537500000002 | 3192672 |
| 1024 | 8 | 4,725,333.6 | 590666.7 | 4264920 |

Raw output from the same run:

```text
MoonBit Artboard benchmark suite
clock=moonbitlang/core/bench.monotonic_clock_us
render-query-export sample_size=32 iterations=64 total_us=31236.4 average_us=488.06875 checksum=1069760
render-query-export sample_size=256 iterations=24 total_us=557916.9 average_us=23246.537500000002 checksum=3192672
render-query-export sample_size=1024 iterations=8 total_us=4725333.6 average_us=590666.7 checksum=4264920
```

These numbers are a reproducible reference run, not a hardware-independent
performance claim. Compare runs on the same target and record the toolchain
and commit alongside any new measurements.
