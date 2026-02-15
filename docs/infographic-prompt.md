# Axiom Architecture Infographic — Generation Prompt

Use the following prompt to generate a technical infographic illustrating the architecture of **Axiom**, a deterministic procedural world-generation engine written in Haskell.

---

## Prompt

> Create a tall vertical technical infographic (portrait, roughly 1080×2400 px) illustrating the architecture of "Axiom," a deterministic procedural world-generation engine written in Haskell.
>
> **Overall style**: Clean, modern, dark-mode technical diagram. Deep charcoal-black background (#0D1117). Thin glowing connection lines between layers. Flat-design icons with subtle gradients. Monospaced code snippets as decorative elements. Think "GitHub dark mode meets conference keynote slide." No photorealism — everything is vector/diagrammatic.
>
> **Color palette**:
> - Background: deep charcoal #0D1117
> - Primary accent: Haskell purple #5E5086
> - Secondary accent: electric teal #58D4C8
> - Tertiary accent: warm amber #E8A838
> - Text: off-white #C9D1D9
> - Subtle grid lines: #161B22
> - Layer glow: each layer gets its own hue (see below)
>
> **Typography**:
> - Title: bold geometric sans-serif (like JetBrains Mono Bold or Space Grotesk Bold), large, centered at top
> - Subtitles & labels: medium-weight sans-serif, off-white
> - Code snippets: monospaced (JetBrains Mono or Fira Code), smaller, Haskell purple on dark card backgrounds
> - All text high-contrast against background
>
> ---
>
> ### Layout (top to bottom)
>
> **HEADER SECTION**
> - Title "AXIOM" in large bold letters, subtle purple glow behind it
> - Subtitle beneath: "Deterministic Procedural World Generation in Haskell"
> - A thin horizontal rule with a lambda (λ) symbol centered on it
> - Small tagline: "Every world is a pure function"
>
> **CORE FORMULA BANNER**
> - A wide card/banner spanning the width, slightly recessed
> - Contains the formula in elegant monospace:
>   `W(v,t) = L_history( L_bio( L_geo( N(v) ) ) )`
> - Each function name colored differently to match its pipeline layer below:
>   - N(v) = stone/gray #8B8680
>   - L_geo = deep earth brown #A0522D
>   - L_bio = forest green #2EA043
>   - L_history = warm amber #E8A838
> - Small annotation: "World W at vertex v, time t"
>
> **CAUSAL PIPELINE — Main body (largest section)**
>
> Five horizontal layers stacked vertically, connected by downward-flowing arrows/lines. Each layer is a rounded-rectangle card with an icon on the left, title in the center, and bullet points on the right. Glowing lines flow downward from each layer to the next, indicating data dependencies.
>
> Layer 1 — TECTONICS (color: stone gray #8B8680)
> - Icon: stylized mountain/terrain cross-section
> - Title: "Tectonics & Elevation"
> - Details: "Perlin noise → fractal heightmap", "massiv arrays for high-perf grids", "Seed-deterministic terrain"
> - Code snippet: `ElevationMap :: Array U Ix2 Double`
> - Small Haskell module badge: `Geo.Noise · Geo.Elevation`
>
> Layer 2 — HYDROLOGY (color: deep blue #1F6FEB)
> - Icon: stylized river/water flow lines
> - Title: "Hydrology & Drainage"
> - Details: "Priority-Flood depression filling", "D8 flow direction & accumulation", "fgl graph → river extraction"
> - Code snippet: `DrainageGraph :: Gr GridCoord FlowInfo`
> - Module badge: `Geo.Hydrology · Geo.Flow · Geo.Drainage`
>
> Layer 3 — CLIMATE (color: sky blue #58A6FF)
> - Icon: stylized thermometer + cloud
> - Title: "Climate"
> - Details: "Lapse-rate temperature model", "Orographic precipitation", "Latitude & elevation effects"
> - Code snippet: `ClimateGrid :: Array U Ix2 ClimateCell`
> - Module badge: `Climate.Temperature · Climate.Precipitation`
>
> Layer 4 — BIOMES (color: forest green #2EA043)
> - Icon: stylized tree / leaf
> - Title: "Biome Classification"
> - Details: "Whittaker diagram classification", "Temp × Precip → Biome type", "16 biome categories"
> - Code snippet: `classifyBiome :: Double -> Double -> Biome`
> - Module badge: `Bio.Whittaker · Types.Biome`
>
> Layer 5 — HISTORY (color: warm amber #E8A838)
> - Icon: stylized scroll / timeline
> - Title: "Historical Simulation"
> - Details: "State Monad temporal simulation", "Event generation from geography", "Deterministic history replay"
> - Code snippet: `simulate :: Int -> State WorldState [Event]`
> - Module badge: `Simulation.State · Simulation.History`
>
> Between the layers, show thin animated-style downward arrows with small labels:
> - Tectonics → Hydrology: "elevation feeds water flow"
> - Hydrology → Climate: "drainage shapes precipitation"
> - Climate → Biomes: "temp & precip classify biomes"
> - Biomes → History: "geography drives civilization"
>
> **TYPE SAFETY SIDEBAR (right side, overlapping the pipeline)**
> - A narrow vertical card running alongside the pipeline layers
> - Title: "GADT State Machine"
> - Shows the type progression as a vertical state diagram:
>   - `Empty` (top, gray)
>   - ↓ `WithElevation`
>   - `HasElevation` (middle, brown)
>   - ↓ ... more layers ...
>   - `Complete` (bottom, green)
> - Annotation: "Impossible states are unrepresentable"
> - Small Haskell badge: `data Phase = Empty | HasElevation | Complete`
>
> **HASKELL TECHNIQUES ROW**
> - A horizontal row of 6 small icon-cards beneath the pipeline:
>   1. λ icon — "GADTs" / "Type-safe state"
>   2. ∞ icon — "Lazy Eval" / "Infinite worlds"
>   3. ⟳ icon — "State Monad" / "Pure simulation"
>   4. 📖 icon — "Megaparsec" / "DSL parsing"
>   5. ▦ icon — "massiv" / "Array performance"
>   6. 🔗 icon — "fgl" / "Graph networks"
>
> **EXPORT & CLI FOOTER**
> - A bottom bar showing the output layer
> - Three output format cards side by side:
>   - JSON export (icon: curly braces)
>   - ASCII map (icon: terminal grid)
>   - CLI interface (icon: terminal prompt)
> - Example command in monospace: `axiom generate --seed 42 --size "(256,256)" -o world.json`
> - Module badge: `Export.JSON · Export.ASCII · CLI.Options · CLI.Commands`
>
> **DSL CALLOUT (small floating card, bottom-left)**
> - Title: "Universal Laws DSL"
> - Shows a tiny code snippet of what a .axiom law file looks like
> - Module badge: `DSL.AST · DSL.Lexer · DSL.Parser`
> - Annotation: "Custom rules that govern world generation"
>
> **FOOTER**
> - Thin line, then small text: "Built with GHC 9.6+ · Cabal · MIT License"
> - GitHub-style badge or URL placeholder
>
> ---
>
> **Style references**: Stripe's technical architecture diagrams, Figma's engineering blog illustrations, Haskell.org purple branding, GitHub's dark-mode UI aesthetic. Clean vector lines, no clutter, generous whitespace between sections. Technical but approachable.
>
> **Do NOT include**: Photographs, 3D renders, realistic landscapes, or cartoonish elements. Keep it purely diagrammatic and typographic.

---

## Adaptation Notes

**For Midjourney**: Prefix with `--ar 9:20 --style raw --stylize 200`. Append: `technical infographic, vector illustration, dark mode, flat design, diagram, no photorealism, no 3D`. You may need to simplify the text-heavy elements since Midjourney struggles with readable text — focus on the visual layout and color hierarchy, then overlay text in Figma or Canva afterward.

**For DALL-E**: Use the full prompt. DALL-E handles text better but may still garble code snippets. Plan to add all text in post-production. Focus the prompt on layout, color, shapes, and structure.

**For a designer (Figma/Illustrator)**: This prompt serves as a complete creative brief. The color codes are exact hex values. The layout is described top-to-bottom. A designer can implement this 1:1 with full typographic control.

**Recommended approach**: Use AI generation for the overall composition and color mood, then recreate or overlay all text and code in a vector tool for crisp, accurate typography.
