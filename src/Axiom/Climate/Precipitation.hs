{-|
Module: Axiom.Climate.Precipitation
Description: Precipitation adjustment based on elevation effects

Adjusts base precipitation (from noise) using orographic precipitation model:
- Precipitation increases up to mid-elevation (~2000m) as moisture rises and cools
- Precipitation decreases above mid-elevation as air dries out
- Models rain shadow effect without full wind simulation
-}

module Axiom.Climate.Precipitation
  ( -- * Precipitation functions
    adjustPrecip
  , precipitationField
  ) where

import qualified Data.Massiv.Array as M
import Data.Massiv.Array (Array, U, Ix2)

-- | Adjust precipitation based on elevation using orographic model.
--
-- Orographic precipitation: moisture-laden air rises up mountains, cools,
-- condenses (rain/snow on windward side), then descends dry (rain shadow).
--
-- Simplified model (without wind direction):
-- - Precipitation increases from sea level to mid-elevation (~2000m): +50%
-- - Precipitation decreases above mid-elevation as air dries
--
-- >>> adjustPrecip 100 0       -- Sea level
-- 100.0
-- >>> adjustPrecip 100 2000    -- Mid-elevation
-- 150.0
-- >>> adjustPrecip 100 4000    -- High elevation
-- 120.0
adjustPrecip :: Double  -- ^ Base precipitation (cm/year) from noise
             -> Double  -- ^ Elevation (meters)
             -> Double  -- ^ Adjusted precipitation (cm/year)
adjustPrecip basePrecip elevation =
  let midElev = 2000.0  -- Meters - typical mid-elevation for max precipitation
      factor = if elevation < midElev
               then 1.0 + (elevation / midElev) * 0.5  -- +50% at mid-elevation
               else 1.5 - ((elevation - midElev) / midElev) * 0.3  -- decrease above
  in basePrecip * factor

-- | Calculate precipitation field for entire grid using massiv.
--
-- Applies elevation-based precipitation adjustment element-wise to grids.
-- Uses strict unboxed arrays (Array U) to avoid lazy evaluation performance issues.
--
-- >>> let basePrecipGrid = M.fromList M.Seq [2 :. 2] [100, 100, 100, 100]
-- >>> let elevGrid = M.fromList M.Seq [2 :. 2] [0, 1000, 2000, 4000]
-- >>> precipitationField basePrecipGrid elevGrid
-- -- Returns grid with adjusted precipitation at each elevation
precipitationField :: Array U Ix2 Double  -- ^ Base precipitation grid (cm/year)
                   -> Array U Ix2 Double  -- ^ Elevation grid (meters)
                   -> Array U Ix2 Double  -- ^ Adjusted precipitation grid (cm/year)
precipitationField basePrecipGrid elevGrid =
  M.computeAs M.U $ M.zipWith adjustPrecip basePrecipGrid elevGrid
