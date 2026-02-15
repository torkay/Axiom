{-# LANGUAGE StrictData #-}
{-|
Module: Axiom.Export.JSON
Description: JSON export/import for world state

Thin wrapper around Aeson for world serialization.
WorldState already has Generic-derived ToJSON/FromJSON instances.
-}

module Axiom.Export.JSON
  ( exportWorldJSON
  , importWorldJSON
  ) where

import Data.Aeson (encode, decode)
import qualified Data.ByteString.Lazy as BL
import Axiom.Simulation.State (WorldState)

-- | Export world state to JSON file
exportWorldJSON :: WorldState -> FilePath -> IO ()
exportWorldJSON world path = BL.writeFile path (encode world)

-- | Import world state from JSON file
importWorldJSON :: FilePath -> IO (Maybe WorldState)
importWorldJSON path = decode <$> BL.readFile path
