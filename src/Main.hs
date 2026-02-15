{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Axiom.World (World(..))
import qualified Axiom.Geo.Elevation as Elev
import Axiom.Climate.Climate (generateClimate, ClimateCell(..))
import qualified Data.Massiv.Array as M
import Data.Massiv.Array (Array, U, Ix2(..), Sz(Sz2), (!))
import Data.List (group, sort)
import Axiom.DSL.Parser (parseLaws)
import Axiom.Simulation.State (initialWorldState, WorldState(..), Civilization(..))
import Axiom.Simulation.History (runSimulation)
import qualified Data.Map.Strict as Map
import Data.Aeson (encode)
import qualified Data.ByteString.Lazy.Char8 as BL

main :: IO ()
main = do
  putStrLn "=== Axiom World Generation ==="
  putStrLn ""

  -- Generate elevation map with seed 42
  let elevMap = Elev.generate 42
  let centerElev = Elev.sample elevMap (256, 256)
  putStrLn $ "✓ Generated 512x512 elevation map, center: " ++ show centerElev ++ "m"

  -- Create World with elevation (demonstrates GADT type progression)
  let _worldWithElev = WithElevation elevMap EmptyWorld
  putStrLn "✓ World advanced to HasElevation phase"
  putStrLn ""

  -- Demonstrate climate pipeline with smaller grid (64x64 for quick demo)
  putStrLn "=== Climate Pipeline Demo (64x64 grid) ==="
  let size = 64
      elevGrid = makeElevationGrid size
      latGrid = makeLatitudeGrid size
      precipGrid = makeBasePrecipitationGrid size

  -- Generate complete climate layer
  let climateGrid = generateClimate elevGrid latGrid precipGrid

  -- Compute statistics to prove causal correctness
  -- Convert delayed array to list for analysis
  let climateList = M.toList climateGrid
  putStrLn $ "✓ Generated " ++ show (length climateList) ++ " climate cells"

  -- Sample some cells to show the pipeline
  let sampleCells = take 5 climateList
  putStrLn "\nSample cells (showing elevation → temp → precip → biome):"
  mapM_ printCell sampleCells

  -- Count biome distribution
  let biomes = map cellBiome climateList
      biomeCounts = map (\xs -> (head xs, length xs)) $ group $ sort biomes
  putStrLn "\nBiome distribution:"
  mapM_ (\(b, count) -> putStrLn $ "  " ++ show b ++ ": " ++ show count ++ " cells") biomeCounts

  putStrLn "\n✓ Climate layer complete - biomes derive causally from geography"

  -- Test DSL parser
  putStrLn "\n=== DSL Parser Test ==="
  let testLaw = "law population_growth: population + 10\nlaw tech_advance: if population > 100 then technology + 1 else technology"
  case parseLaws testLaw of
    Left err -> putStrLn $ "Parse error: " ++ err
    Right laws -> do
      putStrLn $ "✓ Parsed " ++ show (length laws) ++ " laws successfully"
      mapM_ (putStrLn . ("  " ++) . show) laws

  -- Test error handling
  putStrLn "\n=== DSL Error Handling Test ==="
  let invalidLaw = "law invalid syntax here"
  case parseLaws invalidLaw of
    Left err -> putStrLn $ "✓ Error message:\n" ++ err
    Right _ -> putStrLn "ERROR: Should have failed to parse"

  -- Test temporal simulation
  putStrLn "\n=== Temporal Simulation Test ==="
  let initial = initialWorldState
  putStrLn $ "Initial state: Year " ++ show (currentYear initial)
  putStrLn $ "  Civilizations: " ++ show (Map.size (civilizations initial))
  let firstCiv = head $ Map.elems (civilizations initial)
  putStrLn $ "  Starting population: " ++ show (civPopulation firstCiv)
  putStrLn $ "  Starting technology: " ++ show (civTechnology firstCiv)

  putStrLn "\nRunning 100-year simulation..."
  let final = runSimulation 100 initial
  putStrLn $ "Final state: Year " ++ show (currentYear final)
  let finalCiv = head $ Map.elems (civilizations final)
  putStrLn $ "  Final population: " ++ show (civPopulation finalCiv)
  putStrLn $ "  Final technology: " ++ show (civTechnology finalCiv)
  putStrLn $ "  Events recorded: " ++ show (length (events final))

  -- Test JSON serialization
  putStrLn "\n=== JSON Serialization Test ==="
  let jsonOutput = encode final
  putStrLn $ "✓ JSON size: " ++ show (BL.length jsonOutput) ++ " bytes"
  putStrLn "✓ World state is JSON-serializable"

-- Helper: Print a climate cell showing the causal chain
printCell :: ClimateCell -> IO ()
printCell cell = putStrLn $
  "  Elev: " ++ show (round $ cellElevation cell) ++ "m" ++
  " → Temp: " ++ show (round $ cellTemperature cell) ++ "°C" ++
  " → Precip: " ++ show (round $ cellPrecipitation cell) ++ "cm" ++
  " → " ++ show (cellBiome cell)

-- Helper functions for grid generation (simplified for demo)
makeElevationGrid :: Int -> Array U Ix2 Double
makeElevationGrid size =
  M.makeArrayR M.U M.Seq (Sz2 size size) $ \(r :. c) ->
    -- Simple gradient: higher in center, lower at edges
    let dr = fromIntegral r - fromIntegral size / 2
        dc = fromIntegral c - fromIntegral size / 2
        dist = sqrt (dr*dr + dc*dc)
        maxDist = fromIntegral size / 2
    in max 0 $ 3000 * (1 - dist / maxDist)  -- 0-3000m

makeLatitudeGrid :: Int -> Array U Ix2 Double
makeLatitudeGrid size =
  M.makeArrayR M.U M.Seq (Sz2 size size) $ \(r :. _c) ->
    -- Map row to latitude: -90 at top, +90 at bottom
    let yNorm = fromIntegral r / fromIntegral size
    in (yNorm - 0.5) * 180.0

makeBasePrecipitationGrid :: Int -> Array U Ix2 Double
makeBasePrecipitationGrid size =
  M.makeArrayR M.U M.Seq (Sz2 size size) $ \(_r :. c) ->
    -- Simple west-to-east gradient
    let xNorm = fromIntegral c / fromIntegral size
    in 50 + xNorm * 200  -- 50-250 cm/year
