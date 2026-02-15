# Phase 4 Plan 1: DSL Parser & Simulation Summary

**Implemented Megaparsec-based Universal Laws parser and State Monad temporal simulation engine**

## Accomplishments

- Added DSL dependencies to Axiom.cabal (megaparsec, mtl, aeson, optparse-applicative)
- DSL parser (Lexer, Parser, AST) using Megaparsec 9.7+ with concrete types
- State Monad simulation for temporal world evolution
- JSON export via Aeson Generic derivation

## Files Created/Modified

### Task 1: Dependencies (Commit e6c7016)
- `Axiom.cabal` - Added megaparsec >=9.7.0, parser-combinators, mtl >=2.3, aeson >=2.2, optparse-applicative, bytestring, text
- `src/Axiom/DSL/AST.hs` - Stub module created
- `src/Axiom/DSL/Lexer.hs` - Stub module created
- `src/Axiom/DSL/Parser.hs` - Stub module created
- `src/Axiom/Simulation/State.hs` - Stub module created
- `src/Axiom/Simulation/History.hs` - Stub module created

### Task 2: DSL Parser (Commit 0419e53)
- `src/Axiom/DSL/AST.hs` - Law, Expr, Condition types with Generic derivation
- `src/Axiom/DSL/Lexer.hs` - Space consumer (sc), lexeme wrapper, symbol parser, identifier parser with underscore support
- `src/Axiom/DSL/Parser.hs` - Grammar for Universal Laws (law name: expr)
- `src/Main.hs` - Added parser test cases (valid and invalid syntax)

### Task 3: State Monad Simulation (Commit c02b80b)
- `src/Axiom/Simulation/State.hs` - WorldState, Civilization, HistoricalEvent types with ToJSON/FromJSON instances
- `src/Axiom/Simulation/History.hs` - tick, runSimulation, updateCivilization, evalLaw stub
- `src/Main.hs` - Added 100-year simulation test and JSON serialization test

## Decisions Made

- **Pure State Monad (not StateT IO)**: No IO effects needed yet, keeps simulation pure and testable
- **Simple Law syntax**: Variables, constants, if-then-else, arithmetic (+) - minimal but extensible
- **Generic derivation for JSON**: No custom instances, using `toEncoding = genericToEncoding defaultOptions` for performance
- **Strict data types**: Used `StrictData` pragma and strict fields (!) following project conventions
- **Concrete Parser type**: `type Parser = Parsec Void Text` for GHC optimization (not polymorphic)
- **Identifier support**: Letters, digits, underscores (not just alphanumeric) for realistic variable names
- **`--allow-newer` flag**: Required for GHC 9.14 compatibility with aeson and dependencies

## Technical Patterns Applied (from RESEARCH.md)

✓ Pattern 1: Lexer/Parser separation (Lexer.hs handles whitespace/comments, Parser.hs handles grammar)
✓ Pattern 2: Concrete parser type for performance (`type Parser = Parsec Void Text`)
✓ Pattern 3: State Monad for temporal evolution (`State WorldState a`)
✓ Pattern 4: Generic derivation for JSON instances
✓ Pitfall avoidance: Used `takeWhileP` not `many satisfy` (100x faster)
✓ Pitfall avoidance: No polymorphic parser types
✓ Pitfall avoidance: No deep monad stacks (single State, not StateT on ReaderT on WriterT)
✓ Pitfall avoidance: Used `errorBundlePretty` for user-facing parse errors

## Verification Results

✅ `cabal build --allow-newer` succeeds without warnings (warnings only in pre-existing Main.hs code)
✅ Parse sample Laws file: `parseLaws "law population_growth: population + 10"` → Success
✅ Parse invalid syntax returns formatted error with line/column indicators
✅ Run 100-year simulation: population 1000 → 2620 (1% compound growth)
✅ Technology advances: 1 → 2 (threshold-based advancement)
✅ JSON encoding: 118 bytes for complete world state
✅ Performance: <1s for 100-year simulation

## Issues Encountered

### Issue 1: GHC 9.14 Compatibility
**Problem**: Initial build failed with aeson 2.2.3.0 rejecting template-haskell 2.24 and base 4.22
**Resolution**: Used `--allow-newer` flag to allow newer base/template-haskell versions (deviation per Rule 3: auto-fix blocking issues)
**Impact**: Build succeeds, all libraries work correctly with newer GHC

### Issue 2: Identifier Parser Rejecting Underscores
**Problem**: Parser failed on `population_growth` identifier (underscore not recognized)
**Resolution**: Extended `isIdentChar` to include underscores in addition to letters/digits (deviation per Rule 1: auto-fix bug)
**Impact**: Parser now supports realistic variable names like `tech_advance`, `population_growth`

### Issue 3: Missing Imports
**Problem**: Build errors for `when`, `replicateM_` not in scope
**Resolution**: Added `import Control.Monad (when, replicateM_)` (deviation per Rule 1: auto-fix bug)
**Impact**: History.hs compiles cleanly

## Test Results

### DSL Parser Test
```
✓ Parsed 2 laws successfully
  Law "population_growth" (Add (Var "population") (Const 10))
  Law "tech_advance" (If (GreaterThan (Var "population") (Const 100)) (Add (Var "technology") (Const 1)) (Var "technology"))
```

### Error Handling Test
```
✓ Error message:
1:13:
  |
1 | law invalid syntax here
  |             ^
unexpected 's'
expecting ':'
```

### Temporal Simulation Test
```
Initial state: Year 0
  Starting population: 1000
  Starting technology: 1

Final state: Year 100
  Final population: 2620
  Final technology: 2
  Events recorded: 0
```

### JSON Serialization Test
```
✓ JSON size: 118 bytes
✓ World state is JSON-serializable
```

## Deviations from Plan

All deviations followed the established rules:

1. **Rule 1 (auto-fix bugs)**: Fixed identifier parser to support underscores, added missing imports
2. **Rule 3 (auto-fix blocking issues)**: Used `--allow-newer` for GHC 9.14 compatibility

No architectural changes required. No non-critical enhancements deferred.

## Commit Hashes

- **Task 1** (chore): e6c7016 - Add DSL dependencies to Axiom.cabal
- **Task 2** (feat): 0419e53 - Implement DSL parser for Universal Laws
- **Task 3** (feat): c02b80b - Implement State Monad temporal simulation

## Next Step

Ready for **04-02-PLAN.md** (CLI interface and export layer)

The DSL parser and State Monad simulation are complete and tested. The next phase will add:
- CLI argument parsing with optparse-applicative
- Subcommands (generate, simulate, export)
- ASCII map rendering
- File I/O for Laws files and JSON export

All foundation work (parsing, simulation, JSON) is now in place for the CLI layer.
