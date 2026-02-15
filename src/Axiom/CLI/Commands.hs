{-# LANGUAGE StrictData #-}
{-|
Module: Axiom.CLI.Commands
Description: Command handlers for Axiom CLI
-}

module Axiom.CLI.Commands
  ( runCommand
  , runGenerate
  , runSimulate
  , runExport
  ) where

import Axiom.CLI.Options
import Axiom.Export.JSON (exportWorldJSON, importWorldJSON)
import Axiom.Export.ASCII (exportWorldASCII)
import Axiom.Simulation.State (WorldState(..), initialWorldState)
import Axiom.Simulation.History (runSimulation)
import Axiom.DSL.Parser (parseLaws)
import qualified Data.Text.IO as TIO
import System.Exit (die)

-- | Run the appropriate command
runCommand :: Command -> IO ()
runCommand (Generate opts) = runGenerate opts
runCommand (Simulate opts) = runSimulate opts
runCommand (Export opts) = runExport opts

-- | Generate a new world
runGenerate :: GenerateOpts -> IO ()
runGenerate opts = do
  putStrLn $ "Generating world with seed " ++ show (genSeed opts)
  putStrLn $ "Size: " ++ show (genSize opts)

  -- Parse Laws file if provided
  _laws <- case genLawsFile opts of
    Nothing -> do
      putStrLn "No Laws file provided, using default simulation"
      return []
    Just lawsPath -> do
      putStrLn $ "Parsing Laws from " ++ lawsPath
      lawsText <- TIO.readFile lawsPath
      case parseLaws lawsText of
        Left err -> die $ "Parse error in Laws file:\n" ++ err
        Right laws -> do
          putStrLn $ "Parsed " ++ show (length laws) ++ " laws successfully"
          return laws

  -- For now, create initial world state
  -- TODO: Integrate with World.hs generation (elevation, climate, biomes)
  let world = initialWorldState

  -- Export to JSON
  exportWorldJSON world (genOutput opts)
  putStrLn $ "World saved to " ++ genOutput opts

-- | Run historical simulation
runSimulate :: SimulateOpts -> IO ()
runSimulate opts = do
  putStrLn $ "Loading world from " ++ simWorldFile opts

  -- Load world
  maybeWorld <- importWorldJSON (simWorldFile opts)
  world <- case maybeWorld of
    Nothing -> die $ "Failed to load world from " ++ simWorldFile opts
    Just w -> return w

  putStrLn $ "Running simulation for " ++ show (simYears opts) ++ " years"

  -- Run simulation
  let finalWorld = runSimulation (simYears opts) world

  putStrLn $ "Simulation complete. Final year: " ++ show (currentYear finalWorld)

  -- Export result
  exportWorldJSON finalWorld (simOutput opts)
  putStrLn $ "Result saved to " ++ simOutput opts

-- | Export world in different formats
runExport :: ExportOpts -> IO ()
runExport opts = do
  putStrLn $ "Loading world from " ++ exportInput opts

  -- Load world
  maybeWorld <- importWorldJSON (exportInput opts)
  world <- case maybeWorld of
    Nothing -> die $ "Failed to load world from " ++ exportInput opts
    Just w -> return w

  -- Export based on format
  case exportFormat opts of
    JSON -> do
      exportWorldJSON world (exportOutput opts)
      putStrLn $ "Exported JSON to " ++ exportOutput opts
    ASCII -> do
      putStrLn "ASCII export not yet implemented (requires climate grid)"
      -- TODO: Export ASCII map once we integrate full world state
      -- exportWorldASCII climateGrid (exportOutput opts)
