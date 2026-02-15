# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-02-16)

**Core value:** The causal correctness of the functional pipeline—each layer (Geo → Bio → History) follows from the previous with physics-based logic, proven most viscerally through hydrology where rivers never flow uphill and lakes form only at logical basins.
**Current focus:** Phase 2 — Hydrology & Water Systems

## Current Position

Phase: 4 of 4 (History & CLI)
Plan: 1 of 2 in current phase
Status: In progress
Last activity: 2026-02-15 — Completed 04-01-PLAN.md (DSL parser & State Monad simulation)

Progress: ███████░░░ 87.5%

## Performance Metrics

**Velocity:**
- Total plans completed: 7
- Average duration: 16 min
- Total execution time: 1.9 hours

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 1 | 2 | 46 min | 23 min |
| 2 | 2 | 46 min | 23 min |
| 3 | 2 | 11 min | 5.5 min |
| 4 | 1 | 12 min | 12 min |

**Recent Trend:**
- Last 5 plans: 23m, 7m, 4m, 12m
- Trend: Efficient execution (12m average for recent plans)

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Recent decisions affecting current work:

| Phase | Decision | Rationale |
|-------|----------|-----------|
| 1 | Use Cabal over Stack | Current Haskell standard build tool |
| 1 | Use massiv over hmatrix | Avoids BLAS/LAPACK dependency issues, better performance |
| 1 | Use GHC2021 language standard | Modern Haskell features enabled by default |
| 1 | Vertical module organization | Avoids coupling from separate Types modules |
| 1 | Strict fields in data types | Prevents space leaks |
| 1 | makeArrayR vs computeAs for massiv | Direct representation specification avoids type ambiguity |
| 1 | weightedStrength 0.0 for fractal noise | Independent octave amplitudes create cleaner terrain |
| 1 | 512x512 grid size for elevation | Balances detail and performance for testing |
| 2 | Use fgl's PatriciaTree.Gr | Gr type exported from PatriciaTree not Graph module |
| 2 | Qualified massiv imports | Avoids namespace conflicts, clearer code |
| 2 | Priority-Flood algorithm | O(m log² m) proven depression-filling (Barnes 2014) |
| 2 | Topological sort for flow accumulation | Avoids recursion/stack overflow on long river paths |
| 2 | Epsilon tolerance 0.01 for elevation | Based on typical DEM vertical accuracy |
| 2 | River threshold 100 cells | Balances meaningful rivers vs noise in extraction |
| 3 | ICAO standard lapse rate (-6.5°C/km) | Internationally verified atmospheric standard |
| 3 | Solar angle formula for temperature | Physics-based (27°C equator, -20°C poles) |
| 3 | Simplified orographic model | Mid-elevation peak at 2000m, no wind direction for v1 |
| 3 | Whittaker diagram thresholds | Research-verified ecology (40+ years), no custom biome rules |
| 3 | ClimateCell structure | Makes causal chain explicit and observable |
| 3 | Delayed arrays for BiomeType | No Unbox instance needed for v1 |
| 4 | Pure State Monad (not StateT IO) | No IO effects needed yet, keeps simulation pure and testable |
| 4 | Simple Law syntax | Variables, constants, if-then-else, arithmetic - minimal but extensible |
| 4 | Generic derivation for JSON | No custom instances, using toEncoding for performance |
| 4 | Concrete Parser type | type Parser = Parsec Void Text for GHC optimization |
| 4 | --allow-newer flag | Required for GHC 9.14 compatibility with aeson |

### Deferred Issues

None yet.

### Blockers/Concerns

None yet.

## Session Continuity

Last session: 2026-02-15T17:12:03Z
Stopped at: Completed 04-01-PLAN.md (Phase 4 Plan 1 - ready for 04-02: CLI interface)
Resume file: None
