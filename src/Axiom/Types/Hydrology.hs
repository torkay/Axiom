module Axiom.Types.Hydrology
  ( FlowDirection(..)
  , CellData(..)
  , FlowData(..)
  , DrainageNetwork
  , Basin(..)
  , River(..)
  ) where

import Data.Massiv.Array (Ix2)
import Data.Graph.Inductive.Graph (Gr)

-- | Flow direction to one of 8 neighbors
data FlowDirection = N | NE | E | SE | S | SW | W | NW | NoFlow
  deriving (Eq, Show, Ord)

-- | Cell data for drainage network nodes
data CellData = Cell
  { cellPos :: Ix2
  , elevation :: Double
  , accumulation :: Int  -- Number of upstream cells
  } deriving (Eq, Show)

-- | Flow data for drainage network edges
data FlowData = Flow
  { flowVolume :: Double
  } deriving (Eq, Show)

-- | Drainage network as graph (Node = cell, Edge = flow direction)
type DrainageNetwork = Gr CellData FlowData

-- | Basin identified by outlet position and member cells
data Basin = Basin
  { outletPos :: Ix2
  , memberCells :: [Ix2]
  , area :: Int
  } deriving (Eq, Show)

-- | River extracted from high flow accumulation
data River = River
  { path :: [Ix2]  -- Ordered from source to mouth
  , length :: Int
  , sourcePos :: Ix2
  , mouthPos :: Ix2
  } deriving (Eq, Show)
