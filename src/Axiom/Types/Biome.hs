{-|
Module: Axiom.Types.Biome
Description: Biome type definitions for climate-based biome classification
-}

module Axiom.Types.Biome
  ( BiomeType(..)
  ) where

-- | Biome types based on Whittaker biome diagram classification
-- Each biome is determined by temperature and precipitation thresholds
data BiomeType
  = TropicalRainforest  -- Hot and wet (> 20°C, > 200 cm/year)
  | TropicalSavanna     -- Hot and moderate precip (> 20°C, 50-100 cm/year)
  | Desert              -- Hot/moderate and dry (< 50 cm/year)
  | TemperateRainforest -- Moderate temp, very wet (10-20°C, > 150 cm/year)
  | TemperateForest     -- Moderate temp and precip (10-20°C, 75-150 cm/year)
  | Grassland           -- Cool and moderate precip (0-10°C, < 100 cm/year)
  | Taiga               -- Cold and wet (< 0°C, > 50 cm/year)
  | Tundra              -- Cold and dry (< 0°C, < 50 cm/year)
  deriving (Show, Eq, Ord)
