{-# LANGUAGE TypeFamilies #-}

module Axiom.Types.Hydrology
  ( FlowDirection(..)
  , CellData(..)
  , FlowData(..)
  , DrainageNetwork
  , Basin(..)
  , River(..)
  ) where

import Data.Massiv.Array (Ix2)
import qualified Data.Massiv.Array as M
import Data.Graph.Inductive.PatriciaTree (Gr)
import qualified Data.Vector.Unboxed as VU
import qualified Data.Vector.Generic as VG
import qualified Data.Vector.Generic.Mutable as VGM
import Data.Word (Word8)

-- | Flow direction to one of 8 neighbors
data FlowDirection = N | NE | E | SE | S | SW | W | NW | NoFlow
  deriving (Eq, Show, Ord)

-- Encode FlowDirection as Word8 for unboxed storage
flowToWord8 :: FlowDirection -> Word8
flowToWord8 N  = 0
flowToWord8 NE = 1
flowToWord8 E  = 2
flowToWord8 SE = 3
flowToWord8 S  = 4
flowToWord8 SW = 5
flowToWord8 W  = 6
flowToWord8 NW = 7
flowToWord8 NoFlow = 8

word8ToFlow :: Word8 -> FlowDirection
word8ToFlow 0 = N
word8ToFlow 1 = NE
word8ToFlow 2 = E
word8ToFlow 3 = SE
word8ToFlow 4 = S
word8ToFlow 5 = SW
word8ToFlow 6 = W
word8ToFlow 7 = NW
word8ToFlow _ = NoFlow

-- Unbox instance via newtype wrapper
newtype instance VU.MVector s FlowDirection = MV_FlowDirection (VU.MVector s Word8)
newtype instance VU.Vector FlowDirection = V_FlowDirection (VU.Vector Word8)

instance VGM.MVector VU.MVector FlowDirection where
  basicLength (MV_FlowDirection mv) = VGM.basicLength mv
  {-# INLINE basicLength #-}
  basicUnsafeSlice i n (MV_FlowDirection mv) = MV_FlowDirection $ VGM.basicUnsafeSlice i n mv
  {-# INLINE basicUnsafeSlice #-}
  basicOverlaps (MV_FlowDirection mv1) (MV_FlowDirection mv2) = VGM.basicOverlaps mv1 mv2
  {-# INLINE basicOverlaps #-}
  basicUnsafeNew n = MV_FlowDirection <$> VGM.basicUnsafeNew n
  {-# INLINE basicUnsafeNew #-}
  basicInitialize (MV_FlowDirection mv) = VGM.basicInitialize mv
  {-# INLINE basicInitialize #-}
  basicUnsafeRead (MV_FlowDirection mv) i = word8ToFlow <$> VGM.basicUnsafeRead mv i
  {-# INLINE basicUnsafeRead #-}
  basicUnsafeWrite (MV_FlowDirection mv) i x = VGM.basicUnsafeWrite mv i (flowToWord8 x)
  {-# INLINE basicUnsafeWrite #-}

instance VG.Vector VU.Vector FlowDirection where
  basicLength (V_FlowDirection v) = VG.basicLength v
  {-# INLINE basicLength #-}
  basicUnsafeSlice i n (V_FlowDirection v) = V_FlowDirection $ VG.basicUnsafeSlice i n v
  {-# INLINE basicUnsafeSlice #-}
  basicUnsafeIndexM (V_FlowDirection v) i = word8ToFlow <$> VG.basicUnsafeIndexM v i
  {-# INLINE basicUnsafeIndexM #-}
  basicUnsafeFreeze (MV_FlowDirection mv) = V_FlowDirection <$> VG.basicUnsafeFreeze mv
  {-# INLINE basicUnsafeFreeze #-}
  basicUnsafeThaw (V_FlowDirection v) = MV_FlowDirection <$> VG.basicUnsafeThaw v
  {-# INLINE basicUnsafeThaw #-}

instance VU.Unbox FlowDirection

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
