{-|
Module: Axiom.Climate.Temperature
Description: Physics-based temperature calculation from elevation and latitude

Temperature decreases with elevation (lapse rate) and with distance from equator (solar angle).
Uses internationally verified standards:
- Environmental lapse rate: -6.5°C/km (ICAO standard)
- Solar angle formula: insolation ∝ sin(solar_angle) for latitude-based temperature
-}

module Axiom.Climate.Temperature
  ( -- * Constants
    lapseRate
    -- * Temperature functions
  , baseTemperature
  , temperature
  , temperatureField
  ) where

import qualified Data.Massiv.Array as M
import Data.Massiv.Array (Array, U, Ix2)

-- | Standard environmental lapse rate: -6.5°C per km (ICAO standard).
-- Temperature decreases by 6.5°C for every 1000m of elevation gain.
lapseRate :: Double
lapseRate = -6.5  -- °C/km

-- | Calculate sea-level temperature from latitude using solar angle formula.
--
-- The solar angle determines insolation (solar radiation) at different latitudes.
-- Formula models: insolation ∝ sin(solar_angle)
--
-- Temperature ranges:
-- - Equator (0°): ~27°C
-- - Poles (±90°): ~-20°C
--
-- >>> baseTemperature 0.0
-- 27.0
-- >>> baseTemperature 90.0
-- -20.0
-- >>> baseTemperature (-90.0)
-- -20.0
baseTemperature :: Double  -- ^ Latitude in degrees (-90 to 90)
                -> Double  -- ^ Temperature in °C at sea level
baseTemperature lat =
  let latRad = lat * pi / 180  -- Convert degrees to radians
      -- Solar angle effect: higher latitudes receive less direct sunlight
      -- 47°C range from equator to poles
  in 27.0 - (47.0 * abs latRad / (pi/2))

-- | Calculate temperature at given elevation and latitude.
--
-- Combines two effects:
-- 1. Base temperature from latitude (solar angle)
-- 2. Elevation adjustment using lapse rate
--
-- Both factors are essential for realistic climate:
-- - High mountains at equator are cold (elevation effect)
-- - Sea level at poles is cold (latitude effect)
--
-- >>> temperature 0 0    -- Sea level at equator
-- 27.0
-- >>> temperature 3000 0  -- 3km elevation at equator
-- 7.5
-- >>> temperature 0 90    -- Sea level at pole
-- -20.0
temperature :: Double  -- ^ Elevation in meters
            -> Double  -- ^ Latitude in degrees
            -> Double  -- ^ Temperature in °C
temperature elevation latitude =
  let baseTemp = baseTemperature latitude
      elevationKm = elevation / 1000.0
  in baseTemp + (lapseRate * elevationKm)

-- | Calculate temperature field for entire grid using massiv.
--
-- Applies temperature calculation element-wise to elevation and latitude grids.
-- Uses strict unboxed arrays (Array U) to avoid lazy evaluation performance issues.
--
-- >>> let elevGrid = M.fromList M.Seq [2 :. 2] [0, 1000, 2000, 3000]
-- >>> let latGrid = M.fromList M.Seq [2 :. 2] [0, 0, 45, 45]
-- >>> temperatureField elevGrid latGrid
-- -- Returns grid of temperatures calculated for each (elevation, latitude) pair
temperatureField :: Array U Ix2 Double  -- ^ Elevation grid (meters)
                 -> Array U Ix2 Double  -- ^ Latitude grid (degrees)
                 -> Array U Ix2 Double  -- ^ Temperature grid (°C)
temperatureField elevGrid latGrid =
  M.computeAs M.U $ M.zipWith temperature elevGrid latGrid
