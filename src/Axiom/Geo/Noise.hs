module Axiom.Geo.Noise
  ( terrainNoise
  , terrainConfig
  ) where

import Numeric.Noise qualified as Noise

-- | Fractal configuration for multi-scale terrain generation
-- 6 octaves with lacunarity 2.0 and gain 0.5 produces realistic terrain
terrainConfig :: Noise.FractalConfig Double
terrainConfig = Noise.FractalConfig
  { Noise.octaves = 6            -- 6 layers of detail
  , Noise.lacunarity = 2.0       -- Each octave 2x frequency
  , Noise.gain = 0.5             -- Each octave 0.5x amplitude
  , Noise.weightedStrength = 0.0 -- Independent octave amplitudes
  }

-- | Generate terrain noise using fractal composition of Perlin noise
-- Returns coherent noise value in range [-1.0, 1.0]
-- Takes a seed for deterministic generation, then x and y coordinates
{-# INLINE terrainNoise #-}
terrainNoise :: Noise.Seed -> Double -> Double -> Double
terrainNoise seed x y = Noise.noise2At (Noise.fractal2 terrainConfig Noise.perlin2) seed x y
