{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE StrictData #-}
{-|
Module: Axiom.Export.ASCII
Description: ASCII map rendering for world visualization

Renders climate grid as ASCII character map with biome legend.
-}

module Axiom.Export.ASCII
  ( renderASCII
  , exportWorldASCII
  ) where

import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import Axiom.Types.Biome (BiomeType(..))
import Axiom.Climate.Climate (ClimateCell(..))
import qualified Data.Massiv.Array as M

-- | Render climate grid as ASCII map
-- Uses Load constraint to allow computing the array into manifest form
renderASCII :: (M.Source r ClimateCell, M.Load r M.Ix2 ClimateCell)
            => M.Array r M.Ix2 ClimateCell -> Text
renderASCII climateGrid = T.unlines (rows <> [legend])
  where
    M.Sz2 height width = M.size climateGrid
    -- Compute the array as boxed to make it manifest (allows efficient indexing)
    computed = M.computeAs M.B climateGrid
    rows = [renderRow y | y <- [0..height-1]]
    renderRow y = T.concat [tileChar (computed M.! M.Ix2 y x) | x <- [0..width-1]]
    tileChar cell = case cellBiome cell of
      TropicalRainforest  -> "T"
      TropicalSavanna     -> "S"
      Desert              -> "~"
      TemperateRainforest -> "R"
      TemperateForest     -> "t"
      Grassland           -> "."
      Taiga               -> "^"
      Tundra              -> "*"
    legend = "\nLegend: T=Tropical Rainforest, S=Savanna, ~=Desert, R=Temperate Rainforest, t=Temperate Forest, .=Grassland, ^=Taiga, *=Tundra"

-- | Export world as ASCII map to file
exportWorldASCII :: (M.Source r ClimateCell, M.Load r M.Ix2 ClimateCell)
                 => M.Array r M.Ix2 ClimateCell -> FilePath -> IO ()
exportWorldASCII grid path = TIO.writeFile path (renderASCII grid)
