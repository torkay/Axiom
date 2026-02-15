module Axiom.Geo.Elevation
  ( ElevationMap(..)
  , generate
  , sample
  ) where

import qualified Data.Massiv.Array as A
import Data.Massiv.Array (Array, Ix2(..), Sz(..), Comp(Par))
import qualified Axiom.Geo.Noise as Noise
import Data.Word (Word64)

-- | Elevation map with strict fields to prevent space leaks
data ElevationMap = ElevationMap
  { emGrid :: !(Array A.U Ix2 Double)
  , emSeed :: !Int
  }

-- | Generate elevation map using massiv parallel computation
-- Creates a 512x512 grid with noise values scaled from [-1,1] to [0,1]
generate :: Int -> ElevationMap
generate seed =
  let noiseSeed = fromIntegral seed :: Word64
      grid = A.makeArrayR A.U Par (Sz2 512 512) $ \(i :. j) ->
        let x = fromIntegral i / 512.0
            y = fromIntegral j / 512.0
            -- Scale noise from [-1,1] to [0,1] for elevation
            noise = (Noise.terrainNoise noiseSeed x y + 1.0) / 2.0
        in noise
  in ElevationMap { emGrid = grid, emSeed = seed }

-- | Sample elevation value at grid coordinates (i, j)
-- Uses massiv's index' for safe array access
sample :: ElevationMap -> (Int, Int) -> Double
sample em (i, j) = A.index' (emGrid em) (i :. j)
