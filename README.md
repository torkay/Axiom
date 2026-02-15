# Axiom

A deterministic procedural world-generation engine in Haskell. Axiom enforces logical consistency through a causal functional pipeline where every layer builds on the previous with physics-based rules -- rivers never flow uphill, biomes follow from climate, and civilizations emerge from geography.

## Architecture

The world is modeled as a pure function:

```
W(v,t) = L_history(L_bio(L_geo(N(v))))
```

Each transformation layer builds causally on the previous:

```
Tectonics → Hydrology → Climate → Biomes → History
```

### Module Structure

```
src/Axiom/
├── World.hs                 # GADT world types (type-safe state progression)
├── Geo/
│   ├── Noise.hs             # Perlin noise terrain generation
│   ├── Elevation.hs         # Fractal elevation maps (massiv arrays)
│   ├── Flow.hs              # D8 flow direction & accumulation
│   ├── Drainage.hs          # Drainage graph & river extraction
│   └── Hydrology.hs         # Priority-Flood depression filling
├── Climate/
│   ├── Temperature.hs       # Lapse rate temperature model
│   ├── Precipitation.hs     # Orographic precipitation effects
│   └── Climate.hs           # Combined climate pipeline
├── Bio/
│   └── Whittaker.hs         # Whittaker biome classification
├── Types/
│   ├── Hydrology.hs         # Flow & drainage types
│   └── Biome.hs             # Biome type definitions
├── DSL/
│   ├── AST.hs               # Universal Laws AST
│   ├── Lexer.hs             # Megaparsec lexer
│   └── Parser.hs            # DSL parser for law definitions
├── Simulation/
│   ├── State.hs             # State Monad temporal simulation
│   └── History.hs           # Historical event generation
├── Export/
│   ├── JSON.hs              # Aeson JSON export
│   └── ASCII.hs             # Terminal ASCII map rendering
└── CLI/
    ├── Options.hs            # optparse-applicative argument parsing
    └── Commands.hs           # Command dispatch
```

## Key Techniques

- **GADTs** for type-level enforcement of world state progression (impossible states are unrepresentable)
- **State Monad** for temporal simulation without side effects
- **Lazy evaluation** for on-demand chunk computation
- **Megaparsec** DSL for defining Universal Laws that govern world behavior
- **massiv** arrays for high-performance elevation/climate grids
- **fgl** graphs for drainage network modeling

## Building

Requires GHC 9.6+ and Cabal 3.16+.

```bash
cabal build
```

## Usage

```bash
# Generate a world
axiom generate --seed 42 --size "(256,256)" -o world.json

# Run historical simulation
axiom simulate --years 100 --world world.json -o world-sim.json

# Export as ASCII map
axiom export --format ASCII -o map.txt world.json

# Export as JSON
axiom export --format JSON -o data.json world.json
```

### Universal Laws DSL

Define custom rules that govern world generation:

```bash
axiom generate --seed 42 --laws rules.axiom -o world.json
```

## Example Output

### CLI Interface

```
$ axiom --help
axiom - causal world-gen with DSL and simulation

Usage: Axiom COMMAND

  Axiom: Deterministic world generation engine

Available options:
  -h,--help                Show this help text

Available commands:
  generate                 Generate a new world
  simulate                 Run historical simulation
  export                   Export world in different formats
```

### World Generation

```
$ axiom generate --seed 42 --size "(64,64)" -o world.json
Generating world with seed 42
Size: (64,64)
No Laws file provided, using default simulation
World saved to world.json
```

### Historical Simulation

```
$ axiom simulate --years 50 -w world.json -o world-sim.json
Loading world from world.json
Running simulation for 50 years
Simulation complete. Final year: 50
Result saved to world-sim.json
```

### JSON Export

```
$ axiom export -f JSON -o data.json world.json
Loading world from world.json
Exported JSON to data.json
```

World state is serialized as JSON with civilizations, events, and temporal data:

```json
{
  "civilizations": {
    "1": {
      "civPopulation": 1613,
      "civTechnology": 1,
      "civLocation": [128, 128]
    }
  },
  "currentYear": 50,
  "events": []
}
```

### ASCII Map Rendering

The engine includes a biome-to-character ASCII renderer for terminal visualization:

```
Legend: T=Tropical Rainforest  S=Savanna  ~=Desert  R=Temperate Rainforest
        t=Temperate Forest     .=Grassland  ^=Taiga  *=Tundra
```

## Development Phases

All four phases are complete:

1. **Foundation & Elevation** -- Project structure, GADT types, Perlin noise, elevation mapping
2. **Hydrology** -- Priority-Flood filling, D8 flow direction, drainage networks, river extraction
3. **Climate & Biomes** -- Temperature/precipitation models, Whittaker biome classification
4. **History & CLI** -- State Monad simulation, Megaparsec DSL parser, CLI with ASCII/JSON export

## License

MIT -- see [LICENSE](LICENSE).
