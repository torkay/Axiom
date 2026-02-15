# Axiom

## What This Is

Axiom is a deterministic procedural world-generation engine in Haskell that enforces logical consistency through a causal functional pipeline (tectonics → climate → biome → history). Unlike traditional noise-based generators that produce visually appealing but illogical maps, Axiom models the world as a pure function where every coordinate's state follows from physics-based rules. It's a portfolio/showcase project demonstrating advanced Haskell techniques (GADTs, lazy evaluation, State Monad) applied to world-building.

## Core Value

**The causal correctness of the functional pipeline** - each layer (Geo → Bio → History) follows from the previous with physics-based logic, proven most viscerally through hydrology where rivers never flow uphill and lakes form only at logical basins.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] Deterministic world generation (same seed → same output across all executions)
- [ ] Causal functional pipeline (Geo → Bio → History layers, each following from previous)
- [ ] Physics-based hydrology system (rivers flow from high to low elevation, lakes form at basin minimums)
- [ ] Climate and biome systems derived from elevation and latitude
- [ ] Historical simulation with civilizations and events (State Monad for temporal evolution)
- [ ] DSL for defining Universal Laws (Megaparsec parser for rule syntax)
- [ ] Type safety via GADTs (impossible world states unrepresentable in code)
- [ ] Lazy evaluation for infinite-scale exploration (chunks computed on-demand)
- [ ] CLI interface with ASCII and JSON output formats
- [ ] Performance targets: <200ms per chunk generation, <30s for 4k resolution map, <2GB RAM usage

### Out of Scope

- **3D visualization** — 2D map generation only; 3D would add complexity without proving the causal correctness thesis
- **Game engine integration** — Standalone application; not building Unity/Unreal plugins
- **Phase 4 (Polish/UI)** — SDL2 graphical viewer and multithreading optimizations deferred to future milestone after core pipeline validated
- **Real-time DSL editing** — Laws defined at world creation time, not dynamically editable during exploration
- **Multiplayer/networked worlds** — Single-user desktop tool; no server/client architecture

## Context

**Problem domain:** Traditional noise-based world generators (Perlin/Simplex) produce maps that are visually aesthetic but logically inconsistent. Rivers flow uphill, deserts abut tundra, civilizations spawn without water access, and history is disconnected from geography. The most visceral frustration is **illogical hydrology** - water systems that violate basic physics.

**Solution approach:** Model the world W as a pure function `W(v,t) = L_history(L_bio(L_geo(N(v))))` where each transformation layer builds causally on the previous. Haskell's type system (GADTs) makes invalid states unrepresentable, and lazy evaluation enables infinite-scale worlds without pre-generation.

**Portfolio goals:** Demonstrate advanced Haskell techniques in a practical domain:
- GADTs for type-level enforcement of world consistency
- State Monad for managing temporal evolution without side effects
- Lazy evaluation for on-demand infinite grid computation
- DSL design and parsing with Megaparsec
- Functional architecture for complex systems

## Constraints

- **Tech stack**: Haskell GHC 9.6+ with Stack or Cabal for dependency management
- **Libraries**: hmatrix (linear algebra), hs-noise (coherent noise), Megaparsec (DSL parser), Aeson (JSON export)
- **Performance**: <200ms per 16×16 chunk, <30 seconds for 4k resolution map, <2GB RAM for 1+ hour interactive session
- **Platform**: Desktop (macOS/Linux/Windows via GHC cross-compilation)
- **Stability**: Unit tests must confirm no rivers flow uphill, no settlements without water, no runtime crashes

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Haskell over Rust/C++ | Type system (GADTs) and lazy evaluation are core to the approach; no other language offers both | — Pending |
| Phase 4 deferred to v2.0 | Validate causal correctness first (Phases 1-3) before investing in graphical polish | — Pending |
| 2D-only for v1 | 3D adds complexity without proving the thesis; 2D proves logical consistency | — Pending |

---
*Last updated: 2026-02-16 after initialization*
