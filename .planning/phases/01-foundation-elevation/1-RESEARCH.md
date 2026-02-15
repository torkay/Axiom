# Phase 1: Foundation & Elevation - Research

**Researched:** 2026-02-16
**Domain:** Haskell project structure, linear algebra, and coherent noise generation
**Confidence:** HIGH

<research_summary>
## Summary

Researched the Haskell ecosystem for building a procedural world generation foundation with type-safe architecture, efficient linear algebra for grid operations, and high-performance coherent noise generation.

The modern Haskell stack (2026) uses GHCup to manage tooling with Cabal as the build system (Stack is viable but Cabal is now the standard). For numerical work, massiv has superseded repa as the high-performance array library, offering 3x faster performance and active maintenance. For noise generation, pure-noise is the state-of-the-art library, achieving 84-95% of C++ FastNoiseLite performance with Perlin, Simplex, and other noise types.

Key finding: Don't hand-roll noise algorithms or linear algebra operations. pure-noise handles multi-dimensional noise with domain warping and fractal composition. massiv provides parallel array operations with a sophisticated scheduler. GADTs enable compile-time guarantees for world state transitions, preventing invalid states.

**Primary recommendation:** Use Cabal + GHC 9.14 (LTS) + massiv for grid operations + pure-noise for terrain generation + GADTs for type-safe world states. Vertical module organization prevents cyclic dependencies. Use strict evaluation strategically to avoid space leaks in large grid computations.
</research_summary>

<standard_stack>
## Standard Stack

The established libraries/tools for Haskell procedural generation:

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| GHC | 9.14+ | Haskell compiler | First LTS release (Aug 2025), 2+ years support |
| Cabal | 3.16+ | Build system | Now preferred over Stack, standard Haskell tooling |
| massiv | Latest | Multi-dimensional arrays | Superseded repa: 3x faster, actively maintained |
| pure-noise | 0.2.1+ | Coherent noise generation | 84-95% C++ performance, composable API |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| vector | Latest | Efficient sequences | Base for massiv/hmatrix, ubiquitous in Haskell |
| deepseq | Latest | Strict evaluation | Force evaluation to prevent space leaks |
| primitive | Latest | Low-level ops | Performance-critical operations |
| hmatrix | 0.20.2 | Linear algebra (optional) | If need BLAS/LAPACK, but massiv preferred |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| massiv | repa | repa is deprecated/unmaintained, 3x slower |
| pure-noise | hsnoise | hsnoise only has Perlin, pure-noise has 6 types |
| Cabal | Stack | Stack is viable but Cabal is now standard |
| massiv | hmatrix | hmatrix good for BLAS but massiv better for grids |

**Installation:**
```bash
# Install GHCup (manages GHC + Cabal + HLS)
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

# Create project
mkdir axiom && cd axiom
cabal init

# Add dependencies to axiom.cabal:
# build-depends: base, massiv, pure-noise, vector, deepseq
```
</standard_stack>

<architecture_patterns>
## Architecture Patterns

### Recommended Project Structure
```
axiom/
├── axiom.cabal                # Package definition
├── cabal.project              # Multi-package config (optional)
├── src/
│   ├── Axiom/
│   │   ├── World.hs          # GADT world state types
│   │   ├── Geo/
│   │   │   ├── Elevation.hs  # Elevation generation
│   │   │   └── Noise.hs      # Noise utilities
│   │   ├── Bio/              # (Phase 3)
│   │   └── History/          # (Phase 4)
│   └── Main.hs
└── test/
    └── ...
```

### Pattern 1: GADTs for Type-Safe World States
**What:** Use GADTs to encode world generation phase as a type parameter, ensuring impossible states don't compile
**When to use:** Multi-stage procedural generation where each phase depends on previous
**Example:**
```haskell
{-# LANGUAGE GADTs #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE KindSignatures #-}

-- Phase kind
data Phase = Empty | HasElevation | HasHydrology | Complete

-- World state indexed by phase
data World (p :: Phase) where
  EmptyWorld :: World 'Empty
  WithElevation :: ElevationMap -> World 'Empty -> World 'HasElevation
  WithHydrology :: RiverNetwork -> World 'HasElevation -> World 'HasHydrology
  CompleteWorld :: BiomeMap -> World 'HasHydrology -> World 'Complete

-- Only compile if elevation exists
addRivers :: World 'HasElevation -> World 'HasHydrology
addRivers (WithElevation elev _) = WithHydrology (computeRivers elev) (WithElevation elev EmptyWorld)

-- Invalid: won't compile (no elevation)
-- addRivers EmptyWorld = ...  -- TYPE ERROR!
```
**Source:** [GHC GADT User's Guide](https://ghc.gitlab.haskell.org/ghc/doc/users_guide/exts/gadt.html), [Type-safe state machines](https://www.poberezkin.com/posts/2020-06-29-modeling-state-machine-dependent-types-haskell-1.html)

### Pattern 2: Massiv Arrays for Grids
**What:** Use massiv's parallel computation for large 2D elevation grids
**When to use:** Any grid operation (noise sampling, elevation maps, terrain processing)
**Example:**
```haskell
import Data.Massiv.Array as A

-- Generate 512x512 elevation grid using pure-noise
generateElevation :: Noise2 -> Array U Ix2 Double
generateElevation noiseFunc = A.computeAs U $ A.makeArray Par (Sz2 512 512) $ \(i :. j) ->
  let x = fromIntegral i / 512.0
      y = fromIntegral j / 512.0
  in noise2At noiseFunc x y

-- Parallel computation with massiv scheduler
{-# INLINE generateElevation #-}
```
**Source:** [massiv documentation](https://hackage.haskell.org/package/massiv), [massiv GitHub](https://github.com/lehins/massiv)

### Pattern 3: Composable Noise with pure-noise
**What:** Layer multiple noise functions for realistic terrain features
**When to use:** Generating elevation, humidity, temperature maps
**Example:**
```haskell
import Noise qualified

-- Combine base terrain + mountains + detail
terrainNoise :: Noise2
terrainNoise =
  let base = Noise.perlin2 * 0.5                    -- Base elevation
      mountains = Noise.superSimplex2 * 0.3          -- Mountain ranges
      detail = Noise.valueCubic2 * 0.2               -- Fine details
  in (base + mountains + detail) / 1.0

-- Fractal noise for multi-scale features
fractalTerrain :: Noise2
fractalTerrain = Noise.fractal2 config Noise.perlin2
  where config = Noise.FractalConfig
          { fractalOctaves = 6
          , fractalLacunarity = 2.0
          , fractalGain = 0.5
          }
```
**Source:** [pure-noise Hackage](https://hackage.haskell.org/package/pure-noise)

### Pattern 4: Vertical Module Organization
**What:** Group related types and functions in the same module, avoid separate "Types" modules
**When to use:** All Haskell projects
**Example:**
```haskell
-- GOOD: Axiom/Geo/Elevation.hs
module Axiom.Geo.Elevation
  ( ElevationMap      -- Export type
  , generate          -- Export functions
  , sample
  , normalize
  ) where

data ElevationMap = ElevationMap
  { emGrid :: Array U Ix2 Double
  , emSeed :: Int
  }

generate :: Int -> ElevationMap
sample :: ElevationMap -> (Int, Int) -> Double
normalize :: ElevationMap -> ElevationMap

-- BAD: Separate Axiom/Types.hs and Axiom/Elevation.hs (creates coupling)
```
**Source:** [Module organization guidelines](https://www.haskellforall.com/2021/05/module-organization-guidelines-for.html)

### Anti-Patterns to Avoid
- **Lazy lists for large grids:** Use massiv arrays instead (lists are O(n) access, cause space leaks)
- **Separate Types/Constants modules:** Creates tight coupling and cyclic dependencies
- **Hand-rolling noise algorithms:** pure-noise handles edge cases (gradient selection, interpolation)
- **Using repa:** Deprecated in favor of massiv (3x slower, unmaintained)
- **Avoiding strictness annotations:** Large computations need `!` fields and `deepseq` to prevent space leaks
</architecture_patterns>

<dont_hand_roll>
## Don't Hand-Roll

Problems that look simple but have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Perlin/Simplex noise | Custom gradient/interpolation | pure-noise | Gradient selection, smoothstep interpolation, 84-95% C++ speed |
| Multi-dimensional arrays | Nested lists `[[a]]` | massiv | Parallel computation, memory efficiency, proper indexing |
| Fractal noise (octaves) | Manual loop over noise | `Noise.fractal2` | Handles lacunarity/gain, optimized composition |
| Domain warping | Manual coordinate math | pure-noise `reseed`/`next2` | Proper noise layering without correlation |
| Matrix operations | Nested list comprehensions | massiv or hmatrix | BLAS/LAPACK backend, proven algorithms |
| Project scaffolding | Manual directory creation | `cabal init` | Standard structure, dependency management |

**Key insight:** Haskell's ecosystem has mature numerical libraries. pure-noise implements Ken Perlin's algorithms correctly (gradient tables, smoothstep). massiv provides parallel schedulers that are hard to replicate. Fighting these leads to performance issues and numerical artifacts that look like "aesthetic" problems but are actually algorithm bugs.
</dont_hand_roll>

<common_pitfalls>
## Common Pitfalls

### Pitfall 1: Space Leaks from Lazy Evaluation
**What goes wrong:** Unevaluated thunks accumulate in memory during large grid generation, causing OOM
**Why it happens:** Haskell is lazy by default; large computations build thunks instead of evaluating
**How to avoid:**
- Use strict fields in data types: `data ElevationMap = ElevationMap { emGrid :: !(Array U Ix2 Double) }`
- Force evaluation with `deepseq` before passing large structures
- Use `foldl'` instead of `foldl` for accumulation
- Profile with `+RTS -s` to see heap usage
**Warning signs:** Memory usage grows linearly with grid size, GC pauses, heap exhaustion

**Source:** [Performance/Strictness](https://wiki.haskell.org/Performance/Strictness), [Space leak troubleshooting](https://www.mindfulchase.com/explore/troubleshooting-tips/troubleshooting-space-leaks-in-haskell-optimizing-lazy-evaluation-and-memory-usage.html)

### Pitfall 2: Lists for Large Grids
**What goes wrong:** Using `[[Double]]` for 512x512 elevation grids is slow and memory-inefficient
**Why it happens:** Lists are linked structures (O(n) access), not cache-friendly, cause pointer chasing
**How to avoid:** Always use massiv `Array U Ix2 a` for 2D grids (unboxed, contiguous memory)
**Warning signs:** Slow iteration over grid, high memory usage, poor cache performance

**Source:** [High-Performance Haskell](https://softwarepatternslexicon.com/haskell/performance-optimization/best-practices-for-high-performance-haskell-code/)

### Pitfall 3: hmatrix BLAS/LAPACK Dependency Hell
**What goes wrong:** hmatrix requires system BLAS/LAPACK libraries, which are hard to install/link correctly
**Why it happens:** hmatrix is a thin wrapper over C libraries with complex build requirements
**How to avoid:**
- Use massiv instead for array operations (pure Haskell, no C deps)
- If you need hmatrix: install OpenBLAS via system package manager first
- Check `INSTALL.md` in hmatrix repo for platform-specific instructions
**Warning signs:** Build failures with linker errors, missing BLAS symbols

**Source:** [hmatrix INSTALL.md](https://github.com/haskell-numerics/hmatrix/blob/master/INSTALL.md)

### Pitfall 4: GADT Type Complexity Explosion
**What goes wrong:** Adding too many phases/states to GADT World type makes code unreadable
**Why it happens:** Each transition requires explicit pattern match, combinatorial explosion
**How to avoid:**
- Keep GADT phases to 3-5 main states (Empty, HasGeo, HasBio, Complete)
- Use phantom types for sub-states if needed
- Don't encode every detail in types—only critical invariants
**Warning signs:** Functions with 10+ pattern matches, type inference failing, hard to refactor

**Source:** [GADTs for dummies](https://wiki.haskell.org/GADTs_for_dummies)

### Pitfall 5: Not Using LLVM Backend for Numerical Code
**What goes wrong:** pure-noise and massiv achieve best performance with LLVM backend, default backend is slower
**Why it happens:** LLVM optimization passes improve numerical loop performance 50-80%
**How to avoid:** Compile with `-fllvm` flag: `cabal build --ghc-options="-fllvm -O2"`
**Warning signs:** Benchmarks show 50% of expected performance, not utilizing CPU fully

**Source:** [pure-noise Hackage (performance notes)](https://hackage.haskell.org/package/pure-noise)
</common_pitfalls>

<code_examples>
## Code Examples

Verified patterns from official sources:

### Basic Cabal Project Setup
```bash
# Source: Cabal Getting Started Guide
mkdir axiom && cd axiom
cabal init --non-interactive --minimal
cabal build
cabal run axiom
```
**Source:** [Cabal Getting Started](https://cabal.readthedocs.io/en/stable/getting-started.html)

### Massiv Array Creation and Computation
```haskell
-- Source: massiv documentation
import Data.Massiv.Array as A

-- Create 512x512 array in parallel
elevationGrid :: Array U Ix2 Double
elevationGrid = A.computeAs U $ A.makeArray Par (Sz2 512 512) generate
  where
    generate :: Ix2 -> Double
    generate (i :. j) = fromIntegral (i + j) / 1024.0

-- Sample from array
sampleAt :: Ix2 -> Double
sampleAt ix = A.index' elevationGrid ix

-- Map operation (stays delayed)
normalized :: Array D Ix2 Double
normalized = A.map (\x -> (x - 0.5) * 2.0) elevationGrid
```
**Source:** [massiv Hackage](https://hackage.haskell.org/package/massiv)

### pure-noise Multi-Octave Fractal Terrain
```haskell
-- Source: pure-noise documentation
import Noise qualified

-- Multi-scale terrain with fractal noise
terrainHeight :: Double -> Double -> Double
terrainHeight x y =
  let config = Noise.FractalConfig
        { fractalOctaves = 6        -- 6 layers of detail
        , fractalLacunarity = 2.0   -- Each octave 2x frequency
        , fractalGain = 0.5         -- Each octave 0.5x amplitude
        }
      baseNoise = Noise.perlin2
  in Noise.noise2At (Noise.fractal2 config baseNoise) x y

-- Domain warping (one noise distorts another)
warpedTerrain :: Double -> Double -> Double
warpedTerrain x y =
  let warpX = Noise.noise2At Noise.superSimplex2 (x * 0.5) (y * 0.5) * 0.3
      warpY = Noise.noise2At (Noise.next2 Noise.superSimplex2) (x * 0.5) (y * 0.5) * 0.3
  in terrainHeight (x + warpX) (y + warpY)
```
**Source:** [pure-noise Hackage](https://hackage.haskell.org/package/pure-noise)

### GADT World State Progression
```haskell
-- Source: GHC User's Guide + Type-safe state machine blog
{-# LANGUAGE GADTs, DataKinds, KindSignatures #-}

data Phase = Empty | HasElevation | Complete

data World (p :: Phase) where
  EmptyWorld :: World 'Empty
  WithElevation :: Array U Ix2 Double -> World 'Empty -> World 'HasElevation
  CompleteWorld :: BiomeMap -> World 'HasElevation -> World 'Complete

-- Type-safe progression
initialize :: World 'Empty
initialize = EmptyWorld

addElevation :: Array U Ix2 Double -> World 'Empty -> World 'HasElevation
addElevation grid w = WithElevation grid w

finalize :: BiomeMap -> World 'HasElevation -> World 'Complete
finalize biomes w = CompleteWorld biomes w

-- Build pipeline (enforced by types)
buildWorld :: World 'Complete
buildWorld =
  let empty = initialize
      withElev = addElevation someGrid empty
      complete = finalize someBiomes withElev
  in complete
```
**Source:** [GHC GADT docs](https://ghc.gitlab.haskell.org/ghc/doc/users_guide/exts/gadt.html), [Type-safe state machines](https://www.poberezkin.com/posts/2020-06-29-modeling-state-machine-dependent-types-haskell-1.html)
</code_examples>

<sota_updates>
## State of the Art (2024-2026)

What's changed recently:

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Stack for build | Cabal + ghcup | 2024-2025 | Cabal is now recommended standard, ghcup manages all tools |
| repa for arrays | massiv | 2020-2023 | massiv 3x faster, better maintained, sophisticated scheduler |
| hsnoise | pure-noise | 2024-2025 | pure-noise has 6 noise types, 84-95% C++ performance, composable |
| GHC 9.2 | GHC 9.14 LTS | Aug 2025 | First LTS release with 2+ year support guarantee |
| Manual BLAS/LAPACK | massiv pure Haskell | 2020+ | Avoid C dependency hell, massiv handles parallelism natively |

**New tools/patterns to consider:**
- **ghcup:** Universal Haskell tooling installer (replaces manual GHC/Cabal/Stack management)
- **GHC 9.14 LTS:** Long-term support release, stable for production
- **massiv integration with pure-noise:** Can compose noise functions and compute in parallel with massiv scheduler
- **Vertical module organization:** Avoid "Types" modules, group related functionality vertically

**Deprecated/outdated:**
- **repa:** No longer maintained, massiv is superior
- **hsnoise:** Only has Perlin noise, pure-noise has 6 types
- **Stack-first workflow:** Cabal is now the standard (Stack still works but less common)
- **Manual GHC installation:** ghcup is the standard installer
</sota_updates>

<open_questions>
## Open Questions

Things that couldn't be fully resolved:

1. **Massiv vs hmatrix for Phase 2 (Hydrology)**
   - What we know: massiv is better for grid operations, hmatrix better for BLAS/LAPACK
   - What's unclear: Whether river network computation needs BLAS or just massiv arrays
   - Recommendation: Start with massiv; if Phase 2 needs linear solvers, add hmatrix then

2. **GADT complexity for 4-phase pipeline**
   - What we know: GADTs enable type-safe state progression
   - What's unclear: Whether 4 phases (Empty → Geo → Bio → History) becomes unwieldy
   - Recommendation: Implement Empty → HasElevation first, assess complexity before adding more phases

3. **pure-noise seed management for reproducibility**
   - What we know: pure-noise supports reseeding with `reseed` and `next2`/`next3`
   - What's unclear: Best pattern for multiple noise layers with independent seeds
   - Recommendation: Use `next2` for independent noise functions; test seed consistency
</open_questions>

<sources>
## Sources

### Primary (HIGH confidence)
- [massiv Hackage](https://hackage.haskell.org/package/massiv) - Array documentation, performance characteristics
- [massiv GitHub](https://github.com/lehins/massiv) - Active maintenance, benchmarks
- [pure-noise Hackage](https://hackage.haskell.org/package/pure-noise) - Noise API, performance notes
- [GHC GADT User's Guide](https://ghc.gitlab.haskell.org/ghc/doc/users_guide/exts/gadt.html) - Official GADT documentation
- [Cabal Getting Started](https://cabal.readthedocs.io/en/stable/getting-started.html) - Official Cabal docs
- [hmatrix Hackage](https://hackage.haskell.org/package/hmatrix) - Linear algebra library reference

### Secondary (MEDIUM confidence)
- [Stack vs Cabal discussion (Haskell Community)](https://discourse.haskell.org/t/question-about-relationship-of-cabal-and-stack/1155) - Verified with official docs
- [Module organization guidelines (Haskell for All)](https://www.haskellforall.com/2021/05/module-organization-guidelines-for.html) - Verified pattern
- [Type-safe state machines blog](https://www.poberezkin.com/posts/2020-06-29-modeling-state-machine-dependent-types-haskell-1.html) - Verified with GHC docs
- [Canny benchmarks (Alexey Kuleshevich)](https://alexey.kuleshevi.ch/blog/2020/07/10/canny-benchmarks/) - massiv vs repa verified

### Tertiary (LOW confidence - needs validation)
- None - all findings verified against official sources or cross-referenced
</sources>

<metadata>
## Metadata

**Research scope:**
- Core technology: Haskell GHC 9.14, Cabal build system
- Ecosystem: massiv, pure-noise, vector, deepseq
- Patterns: GADTs, vertical modules, strict evaluation, parallel arrays
- Pitfalls: Space leaks, lazy lists, BLAS dependencies, GADT complexity

**Confidence breakdown:**
- Standard stack: HIGH - verified with Hackage, official docs, benchmarks
- Architecture: HIGH - from official GHC docs, verified blog posts, Hackage examples
- Pitfalls: HIGH - documented in HaskellWiki, official performance guides
- Code examples: HIGH - from Hackage documentation and GHC User's Guide

**Research date:** 2026-02-16
**Valid until:** 2026-03-16 (30 days - Haskell ecosystem stable, GHC 9.14 LTS active)
</metadata>

---

*Phase: 01-foundation-elevation*
*Research completed: 2026-02-16*
*Ready for planning: yes*
