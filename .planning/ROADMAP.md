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

- [ ] **Phase 1: Foundation & Elevation** - Project structure, types, noise generation, elevation mapping
- [ ] **Phase 2: Hydrology** - Rivers, lakes, basins (proof of causal correctness)
- [ ] **Phase 3: Climate & Biomes** - Temperature, precipitation, biome assignment from geo data
- [ ] **Phase 4: History & CLI** - State Monad simulation, DSL parser, CLI interface

## Phase Details

### Phase 1: Foundation & Elevation
**Goal**: Establish project structure, core types (GADTs for world states), coherent noise generation, and elevation mapping as the foundation for all causal layers.
**Depends on**: Nothing (first phase)
**Research**: Likely (new libraries and project setup)
**Research topics**: hmatrix API and linear algebra patterns, hs-noise library for coherent noise (Perlin/Simplex), Stack/Cabal project structure for Haskell, GADT type design for world consistency
**Plans**: TBD

Plans:
- (To be created during phase planning)

### Phase 2: Hydrology
**Goal**: Implement physics-based water flow where rivers never flow uphill, lakes form at basin minimums, and drainage networks follow elevation gradients—the visceral proof of causal correctness.
**Depends on**: Phase 1 (requires elevation data)
**Research**: Likely (algorithmic complexity and physics simulation)
**Research topics**: Water flow simulation algorithms, graph traversal for river networks, basin detection methods, performance optimization for large grids
**Plans**: TBD

Plans:
- (To be created during phase planning)

### Phase 3: Climate & Biomes
**Goal**: Derive climate zones (temperature, precipitation) from elevation and latitude, then assign biomes logically based on climate conditions.
**Depends on**: Phase 2 (builds on complete geo layer)
**Research**: Unlikely (internal logic following established patterns)
**Plans**: TBD

Plans:
- (To be created during phase planning)

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
| 1. Foundation & Elevation | 0/TBD | Not started | - |
| 2. Hydrology | 0/TBD | Not started | - |
| 3. Climate & Biomes | 0/TBD | Not started | - |
| 4. History & CLI | 0/TBD | Not started | - |
