{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE StrictData #-}
module Axiom.Simulation.History
  ( tick
  , updateCivilization
  , evalLaw
  , runSimulation
  ) where

import Control.Monad (when, replicateM_)
import Control.Monad.State.Strict
import qualified Data.Map.Strict as Map

import Axiom.Simulation.State
import Axiom.DSL.AST (Law)

-- | Advance simulation by one year
-- Updates all civilizations and records events
tick :: Simulation ()
tick = do
  -- Increment year
  modify $ \s -> s { currentYear = currentYear s + 1 }

  -- Get all civilization IDs
  civIds <- gets (Map.keys . civilizations)

  -- Update each civilization
  mapM_ updateCivilization civIds

-- | Update a single civilization for one year
-- Applies growth rules and records major events
updateCivilization :: CivID -> Simulation ()
updateCivilization cid = do
  maybeCiv <- gets (Map.lookup cid . civilizations)
  case maybeCiv of
    Nothing -> return ()  -- Civilization doesn't exist
    Just civ -> do
      let civ' = growCivilization civ

      -- Update civilization in map
      modify $ \s -> s { civilizations = Map.insert cid civ' (civilizations s) }

      -- Check for technology milestone (every 10 levels)
      when (civTechnology civ' `mod` 10 == 0 && civTechnology civ' /= civTechnology civ) $
        recordEvent (TechMilestone cid (civTechnology civ') "Technology advancement")

      -- Check for population threshold (every 100k)
      when (civPopulation civ' `div` 100000 > civPopulation civ `div` 100000) $
        recordEvent (PopulationThreshold cid (civPopulation civ'))

-- | Apply growth rules to a civilization
-- Population grows by 1% per year (capped at 1M)
-- Technology advances when population exceeds thresholds
growCivilization :: Civilization -> Civilization
growCivilization civ =
  let pop = civPopulation civ
      tech = civTechnology civ

      -- Population growth: 1% per year, capped at 1M
      newPop = min 1000000 (pop + pop `div` 100)

      -- Technology advances at population thresholds
      -- Every 1000 population grants 1 tech level (up to pop/1000)
      targetTech = newPop `div` 1000
      newTech = max tech targetTech

  in civ { civPopulation = newPop, civTechnology = newTech }

-- | Record a historical event
recordEvent :: HistoricalEvent -> Simulation ()
recordEvent event = modify $ \s -> s { events = event : events s }

-- | Evaluate a Law in the context of a civilization
-- This is a stub for future integration - Laws don't affect simulation yet
evalLaw :: Law -> Civilization -> Int
evalLaw _law _civ = 0  -- Stub: will be implemented in future phase

-- | Run simulation for N years
-- Returns the final world state
runSimulation :: Int -> WorldState -> WorldState
runSimulation n initialState = execState (replicateM_ n tick) initialState
