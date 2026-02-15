module Axiom.Geo.Elevation
  ( ElevationMap(..)
  , generate
  ) where

import qualified Data.Massiv.Array as A
import Data.Massiv.Array (Array, Ix2, Sz(..), Comp(Seq))

-- | Elevation map with strict fields to prevent space leaks
data ElevationMap = ElevationMap
  { emGrid :: !(Array A.U Ix2 Double)
  , emSeed :: !Int
  }

-- | Stub function to generate elevation map (placeholder)
generate :: Int -> ElevationMap
generate seed = ElevationMap
  { emGrid = A.makeArrayR A.U Seq (Sz2 10 10) (const 0.0)
  , emSeed = seed
  }
