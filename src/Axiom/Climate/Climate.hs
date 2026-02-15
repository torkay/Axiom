{-|
Module: Axiom.Climate.Climate
Description: Unified climate pipeline integrating temperature, precipitation, and biomes

This module implements the complete climate layer of the functional pipeline:
Elevation + Latitude → Temperature → Precipitation → Biome

This demonstrates causal correctness: biomes derive from climate,
climate derives from geography.
-}

module Axiom.Climate.Climate
  ( ClimateCell(..)
  , generateClimate
  ) where

import qualified Data.Massiv.Array as M
import Data.Massiv.Array (Array, U, Ix2, Comp(Seq))
import Axiom.Climate.Temperature (temperature, temperatureField)
import Axiom.Climate.Precipitation (precipitationField)
import Axiom.Bio.Whittaker (classifyBiome, biomeField)
import Axiom.Types.Biome (BiomeType)

-- | Climate data for a single grid cell.
--
-- Combines all climate-related information: geography (elevation, latitude),
-- derived climate (temperature, precipitation), and resulting biome.
--
-- This structure makes the causal chain explicit:
-- - Elevation + Latitude determine Temperature (lapse rate + solar angle)
-- - Elevation adjusts Precipitation (orographic effects)
-- - Temperature + Precipitation determine Biome (Whittaker diagram)
data ClimateCell = ClimateCell
  { cellElevation :: Double        -- ^ Elevation in meters (from Phase 2)
  , cellLatitude :: Double         -- ^ Latitude in degrees (-90 to 90)
  , cellTemperature :: Double      -- ^ Temperature in °C (derived)
  , cellPrecipitation :: Double    -- ^ Precipitation in cm/year (derived)
  , cellBiome :: BiomeType         -- ^ Biome type (derived)
  } deriving (Show)

-- | Generate complete climate layer from elevation, latitude, and base precipitation.
--
-- This is the core function that chains the entire climate pipeline:
--
-- 1. Calculate temperature from elevation + latitude (lapse rate + solar angle)
-- 2. Adjust precipitation for elevation effects (orographic model)
-- 3. Classify biomes from temperature + precipitation (Whittaker diagram)
-- 4. Combine all data into ClimateCell grid
--
-- The function demonstrates causal correctness: each step derives from the previous,
-- creating a logically consistent world where biomes follow from geography.
--
-- Example usage:
-- >>> let elevGrid = ... -- from Phase 2 elevation generation
-- >>> let latGrid = ... -- from grid position
-- >>> let basePrecipGrid = ... -- from noise
-- >>> let climateGrid = generateClimate elevGrid latGrid basePrecipGrid
--
-- The resulting grid contains complete climate information for world generation.
generateClimate :: Array U Ix2 Double   -- ^ Elevation grid (meters)
                -> Array U Ix2 Double   -- ^ Latitude grid (degrees)
                -> Array U Ix2 Double   -- ^ Base precipitation grid (cm/year, from noise)
                -> Array M.D Ix2 ClimateCell  -- ^ Complete climate grid (delayed)
generateClimate elevGrid latGrid basePrecipGrid =
  -- Step 1: Calculate temperature from elevation + latitude
  let tempGrid = temperatureField elevGrid latGrid

      -- Step 2: Adjust precipitation for orographic effects
      precipGrid = precipitationField basePrecipGrid elevGrid

      -- Step 3: Classify biomes from temperature + precipitation
      biomeGrid = biomeField tempGrid precipGrid

      -- Step 4: Combine into ClimateCell using nested zipWith
      -- First combine elevation, latitude, temperature, precipitation
      climateSansB = M.zipWith4 (\e lat t p -> (e, lat, t, p))
                                elevGrid
                                latGrid
                                tempGrid
                                precipGrid

  in M.zipWith (\(e, lat, t, p) b -> ClimateCell e lat t p b)
               climateSansB
               biomeGrid
