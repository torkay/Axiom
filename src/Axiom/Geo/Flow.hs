module Axiom.Geo.Flow
  ( computeD8Flow
  , flowAccumulation
  , FlowGrid
  , AccumulationGrid
  , ElevationGrid
  , directionToOffset
  ) where

import qualified Data.Massiv.Array as M
import Data.Massiv.Array (Array, Ix2(..), U, Sz(Sz2), (!))
import Axiom.Types.Hydrology (FlowDirection(..))
import Data.List (maximumBy)
import Data.Ord (comparing)
import qualified Data.Map.Strict as Map
import Data.Map.Strict (Map)
import qualified Data.Set as Set

type ElevationGrid = Array U Ix2 Double
type FlowGrid = Array U Ix2 FlowDirection
type AccumulationGrid = Array U Ix2 Int

-- | Epsilon tolerance for elevation comparisons (based on typical DEM vertical accuracy)
epsilon :: Double
epsilon = 0.01

-- | Compute D8 flow direction using steepest descent algorithm
-- (O'Callaghan & Mark 1984)
computeD8Flow :: ElevationGrid -> FlowGrid
computeD8Flow elevs =
  M.makeArrayR M.U M.Par (M.size elevs) $ \ix ->
    let currentElev = elevs ! ix
        neighbors = getNeighborsWithDir ix (M.size elevs)
        drops = [(dir, currentElev - (elevs ! nix)) | (dir, nix) <- neighbors]
    in if null drops
       then NoFlow
       else let (maxDir, maxDrop) = maximumBy (comparing snd) drops
            in if maxDrop > epsilon then maxDir else NoFlow

-- | Get all 8 neighbors with their flow directions
getNeighborsWithDir :: Ix2 -> Sz Ix2 -> [(FlowDirection, Ix2)]
getNeighborsWithDir (r :. c) sz@(Sz2 rows cols) =
  let candidates =
        [ (N,  (r - 1) :. c)
        , (NE, (r - 1) :. (c + 1))
        , (E,  r :. (c + 1))
        , (SE, (r + 1) :. (c + 1))
        , (S,  (r + 1) :. c)
        , (SW, (r + 1) :. (c - 1))
        , (W,  r :. (c - 1))
        , (NW, (r - 1) :. (c - 1))
        ]
      inBounds (row :. col) = row >= 0 && row < rows && col >= 0 && col < cols
  in filter (inBounds . snd) candidates

-- | Convert flow direction to grid offset
directionToOffset :: FlowDirection -> (Int, Int)
directionToOffset N  = (-1, 0)
directionToOffset NE = (-1, 1)
directionToOffset E  = (0, 1)
directionToOffset SE = (1, 1)
directionToOffset S  = (1, 0)
directionToOffset SW = (1, -1)
directionToOffset W  = (0, -1)
directionToOffset NW = (-1, -1)
directionToOffset NoFlow = (0, 0)

-- | Compute flow accumulation using topological sort approach
-- Avoids recursion to prevent stack overflow on long river paths
flowAccumulation :: FlowGrid -> AccumulationGrid
flowAccumulation flowGrid =
  let sz = M.size flowGrid
      allCells = [r :. c | r <- [0..rows-1], c <- [0..cols-1]]
        where Sz2 rows cols = sz

      -- Build adjacency map (cell -> downstream neighbor)
      flowMap = Map.fromList
        [ (cell, downstreamCell)
        | cell <- allCells
        , let dir = flowGrid ! cell
        , dir /= NoFlow
        , let (dr, dc) = directionToOffset dir
        , let (r :. c) = cell
        , let downstreamCell = (r + dr) :. (c + dc)
        ]

      -- Topological sort (Kahn's algorithm)
      sorted = topologicalSort flowMap allCells

      -- Initialize accumulation: each cell contributes 1 (itself)
      initAccum = Map.fromList [(cell, 1) | cell <- allCells]

      -- Process cells in reverse topological order (sources first)
      finalAccum = foldl (processCell flowGrid) initAccum (reverse sorted)

      -- Convert map back to array
  in M.makeArrayR M.U M.Seq sz $ \ix ->
       Map.findWithDefault 1 ix finalAccum

-- | Process a single cell for accumulation
processCell :: FlowGrid -> Map Ix2 Int -> Ix2 -> Map Ix2 Int
processCell flowGrid accumMap cell =
  let dir = flowGrid ! cell
  in if dir == NoFlow
     then accumMap
     else let (dr, dc) = directionToOffset dir
              (r :. c) = cell
              downstream = (r + dr) :. (c + dc)
              currentAccum = Map.findWithDefault 1 cell accumMap
              downstreamAccum = Map.findWithDefault 1 downstream accumMap
          in Map.insert downstream (downstreamAccum + currentAccum) accumMap

-- | Topological sort using Kahn's algorithm
-- Returns cells ordered from outlets to sources
topologicalSort :: Map Ix2 Ix2 -> [Ix2] -> [Ix2]
topologicalSort flowMap allCells =
  let -- Build reverse adjacency (downstream -> upstreams)
      reverseMap = buildReverseMap flowMap allCells

      -- Find cells with no incoming edges (outlets)
      outlets = [cell | cell <- allCells, cell `Map.notMember` reverseMap]

      -- Process queue
      go :: [Ix2] -> Set.Set Ix2 -> [Ix2] -> [Ix2]
      go [] _ result = result
      go (cell:queue) visited result
        | cell `Set.member` visited = go queue visited result
        | otherwise =
            let upstreams = Map.findWithDefault [] cell reverseMap
                newQueue = queue ++ upstreams
                newVisited = Set.insert cell visited
                newResult = result ++ [cell]
            in go newQueue newVisited newResult

  in go outlets Set.empty []

-- | Build reverse adjacency map (downstream -> list of upstreams)
buildReverseMap :: Map Ix2 Ix2 -> [Ix2] -> Map Ix2 [Ix2]
buildReverseMap flowMap allCells =
  let edges = [(downstream, cell) | (cell, downstream) <- Map.toList flowMap]
      addEdge m (downstream, upstream) =
        Map.insertWith (++) downstream [upstream] m
  in foldl addEdge Map.empty edges
