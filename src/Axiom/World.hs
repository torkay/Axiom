{-# LANGUAGE GADTs #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE KindSignatures #-}

module Axiom.World
  ( World(..)
  , Phase(..)
  ) where

import Axiom.Geo.Elevation (ElevationMap)

-- | Phase kind for type-safe world state progression
data Phase = Empty | HasElevation | Complete

-- | GADT representing world at different stages of generation
data World (p :: Phase) where
  EmptyWorld :: World 'Empty
  WithElevation :: ElevationMap -> World 'Empty -> World 'HasElevation
