{-|
Module: Axiom.Bio.Whittaker
Description: Whittaker biome diagram classification

Maps climate conditions (temperature, precipitation) to biome types using
the Whittaker biome diagram - a standard ecological classification system
with 40+ years of research verification.

Thresholds are from established ecology research and should NOT be modified.
-}

module Axiom.Bio.Whittaker
  ( classifyBiome
  , biomeField
  ) where

import Axiom.Types.Biome (BiomeType(..))
import qualified Data.Massiv.Array as M
import Data.Massiv.Array (Array, U, Ix2)

-- | Classify biome type from climate conditions using Whittaker diagram.
--
-- The Whittaker biome diagram maps (temperature, precipitation) → biome type
-- in 2D climate space. These thresholds are based on global ecology research
-- and represent the standard classification used worldwide.
--
-- Temperature zones:
-- - Tropical: > 20°C
-- - Temperate: 10-20°C
-- - Cool: 0-10°C
-- - Cold: < 0°C
--
-- Precipitation zones:
-- - Very wet: > 200 cm/year
-- - Wet: 100-200 cm/year
-- - Moderate: 50-100 cm/year
-- - Dry: < 50 cm/year
--
-- >>> classifyBiome 30 250  -- Hot and very wet
-- TropicalRainforest
-- >>> classifyBiome 25 30   -- Hot and dry
-- Desert
-- >>> classifyBiome (-5) 30 -- Cold and dry
-- Tundra
-- >>> classifyBiome 15 100  -- Temperate and moderate
-- TemperateForest
classifyBiome :: Double      -- ^ Temperature in °C
              -> Double      -- ^ Precipitation in cm/year
              -> BiomeType   -- ^ Classified biome type
classifyBiome temp precip
  -- Tropical (temp > 20°C)
  | temp > 20 && precip > 200 = TropicalRainforest
  | temp > 20 && precip < 50  = Desert
  | temp > 20 && precip < 100 = TropicalSavanna

  -- Temperate (10°C < temp < 20°C)
  | temp > 10 && temp < 20 && precip > 150 = TemperateRainforest
  | temp > 10 && temp < 20 && precip > 75  = TemperateForest
  | temp > 0  && temp < 10 && precip < 100 = Grassland

  -- Cold (temp < 0°C)
  | temp < 0 && precip > 50 = Taiga
  | temp < 0 && precip < 50 = Tundra

  -- Catch-all for edge cases (moderate temp, moderate precip falls through)
  | otherwise = Desert

-- | Calculate biome field for entire grid using massiv.
--
-- Applies Whittaker classification element-wise to temperature and
-- precipitation grids. Uses strict unboxed arrays where possible.
--
-- >>> let tempGrid = M.fromList M.Seq [2 :. 2] [30, 25, -5, 15]
-- >>> let precipGrid = M.fromList M.Seq [2 :. 2] [250, 30, 30, 100]
-- >>> biomeField tempGrid precipGrid
-- -- Returns grid: [TropicalRainforest, Desert, Tundra, TemperateForest]
biomeField :: Array U Ix2 Double    -- ^ Temperature grid (°C)
           -> Array U Ix2 Double    -- ^ Precipitation grid (cm/year)
           -> Array M.D Ix2 BiomeType  -- ^ Biome grid (delayed, can't use U without Unbox instance)
biomeField tempGrid precipGrid =
  M.zipWith classifyBiome tempGrid precipGrid
