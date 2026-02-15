# Roadmap: Axiom

## Overview

Axiom's development follows the causal functional pipeline: Foundation → Geo → Bio → History. Each phase builds a complete layer that proves the system's logical consistency, culminating in a deterministic world-generation engine where rivers never flow uphill and civilizations emerge from geographic constraints.

## Domain Expertise

None

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: Foundation & Elevation** - Project structure, types, noise generation, elevation mapping
- [x] **Phase 2: Hydrology** - Rivers, lakes, basins (proof of causal correctness)
- [ ] **Phase 3: Climate & Biomes** - Temperature, precipitation, biome assignment from geo data
- [ ] **Phase 4: History & CLI** - State Monad simulation, DSL parser, CLI interface

## Phase Details

### Phase 1: Foundation & Elevation
**Goal**: Establish project structure, core types (GADTs for world states), coherent noise generation, and elevation mapping as the foundation for all causal layers.
**Depends on**: Nothing (first phase)
**Research**: Completed (2026-02-16)
**Research topics**: hmatrix API and linear algebra patterns, hs-noise library for coherent noise (Perlin/Simplex), Stack/Cabal project structure for Haskell, GADT type design for world consistency
**Plans**: 2 (both complete)

Plans:
- [x] 01-01: Foundation Setup (Cabal, GADT World types, module structure)
- [x] 01-02: Noise & Elevation (Fractal terrain noise, massiv elevation maps)

### Phase 2: Hydrology
**Goal**: Implement physics-based water flow where rivers never flow uphill, lakes form at basin minimums, and drainage networks follow elevation gradients—the visceral proof of causal correctness.
**Depends on**: Phase 1 (requires elevation data)
**Research**: Completed (2026-02-16)
**Research topics**: Water flow simulation algorithms, graph traversal for river networks, basin detection methods, performance optimization for large grids
**Plans**: 2 (1 complete)

Plans:
- [x] 02-01: Hydrology Foundation (Core types, Priority-Flood depression filling)
- [x] 02-02: Flow & Drainage (Flow direction, accumulation, drainage networks)

### Phase 3: Climate & Biomes
**Goal**: Derive climate zones (temperature, precipitation) from elevation and latitude, then assign biomes logically based on climate conditions.
**Depends on**: Phase 2 (builds on complete geo layer)
**Research**: Completed (2026-02-16)
**Research topics**: Climate modeling formulas (lapse rate, solar angle), orographic precipitation, Whittaker biome classification
**Plans**: 2 (1 complete)

Plans:
- [x] 03-01: Climate Foundation (Temperature with lapse rate, Precipitation with orographic effects)
- [ ] 03-02: Biome Classification (Whittaker diagram, climate → biome mapping)

### Phase 4: History & CLI
**Goal**: Implement State Monad for temporal evolution, Megaparsec DSL parser for Universal Laws, and CLI interface with ASCII/JSON output.
**Depends on**: Phase 3 (requires complete world state for historical simulation)
**Research**: Likely (DSL design and parser implementation)
**Research topics**: Megaparsec parser combinators and DSL design patterns, State Monad for managing temporal evolution, Aeson JSON encoding for world export, CLI argument parsing libraries
**Plans**: TBD

Plans:
- (To be created during phase planning)

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Foundation & Elevation | 2/2 | Complete | 2026-02-16 |
| 2. Hydrology | 2/2 | Complete | 2026-02-16 |
| 3. Climate & Biomes | 1/2 | In progress | - |
| 4. History & CLI | 0/TBD | Not started | - |
