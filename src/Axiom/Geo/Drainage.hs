module Axiom.Geo.Drainage
  ( buildDrainageGraph
  , extractRivers
  , findOutlets
  , cellToNode
  , nodeToCell
  ) where

import qualified Data.Graph.Inductive.Graph as G
import Data.Graph.Inductive.PatriciaTree (Gr)
import Data.Graph.Inductive.Query.DFS (dfs)
import qualified Data.Massiv.Array as M
import Data.Massiv.Array (Array, Ix2(..), U, Sz(Sz2), (!))
import Axiom.Types.Hydrology
  ( DrainageNetwork
  , River(..)
  , CellData(..)
  , FlowData(..)
  , FlowDirection(..)
  )
import Axiom.Geo.Flow (FlowGrid, AccumulationGrid, ElevationGrid, directionToOffset)
import qualified Data.Map.Strict as Map
import Data.List (nub)

-- | Build drainage network graph from flow data
buildDrainageGraph :: ElevationGrid -> FlowGrid -> AccumulationGrid -> DrainageNetwork
buildDrainageGraph elevs flowGrid accumGrid =
  let sz@(Sz2 rows cols) = M.size elevs
      allCells = [r :. c | r <- [0..rows-1], c <- [0..cols-1]]

      -- Create nodes: (nodeId, CellData)
      nodes = [ (cellToNode sz cell, Cell cell (elevs ! cell) (accumGrid ! cell))
              | cell <- allCells
              ]

      -- Create edges: (fromNodeId, toNodeId, FlowData)
      edges = [ (cellToNode sz cell, cellToNode sz downstream, Flow 1.0)
              | cell <- allCells
              , let dir = flowGrid ! cell
              , dir /= NoFlow
              , let (dr, dc) = directionToOffset dir
              , let (r :. c) = cell
              , let downstream = (r + dr) :. (c + dc)
              ]

  in G.mkGraph nodes edges

-- | Convert grid position to unique node ID
cellToNode :: Sz Ix2 -> Ix2 -> Int
cellToNode (Sz2 _ cols) (r :. c) = r * cols + c

-- | Convert node ID back to grid position
nodeToCell :: Sz Ix2 -> Int -> Ix2
nodeToCell (Sz2 _ cols) nodeId =
  let r = nodeId `div` cols
      c = nodeId `mod` cols
  in r :. c

-- | Extract rivers from drainage network based on accumulation threshold
extractRivers :: AccumulationGrid -> DrainageNetwork -> Int -> [River]
extractRivers accumGrid graph threshold =
  let sz = M.size accumGrid
      allCells = [r :. c | r <- [0..rows-1], c <- [0..cols-1]]
        where Sz2 rows cols = sz

      -- Find high-accumulation cells (river cells)
      riverCells = filter (\cell -> accumGrid ! cell > threshold) allCells

      -- Trace each river from high-accumulation cell to outlet
      rivers = concatMap (traceRiver sz graph accumGrid) riverCells

      -- Deduplicate rivers that share paths
  in nub rivers

-- | Trace a river path from a cell to its outlet
traceRiver :: Sz Ix2 -> DrainageNetwork -> AccumulationGrid -> Ix2 -> [River]
traceRiver sz graph accumGrid startCell =
  let nodeId = cellToNode sz startCell
      -- Trace downstream to outlet
      downstreamPath = traceDownstream sz graph startCell
      -- Trace upstream to sources
      upstreamPaths = traceUpstream sz graph accumGrid startCell
  in if null downstreamPath && null upstreamPaths
     then []
     else
       -- For each upstream path, create a river from source to outlet
       [ River
           { path = upPath ++ [startCell] ++ downstreamPath
           , Axiom.Types.Hydrology.length = length upPath + 1 + length downstreamPath
           , sourcePos = if null upPath then startCell else head upPath
           , mouthPos = if null downstreamPath then startCell else last downstreamPath
           }
       | upPath <- if null upstreamPaths then [[]] else upstreamPaths
       ]

-- | Trace downstream from a cell to outlet (follows outgoing edges)
traceDownstream :: Sz Ix2 -> DrainageNetwork -> Ix2 -> [Ix2]
traceDownstream sz graph cell =
  let nodeId = cellToNode sz cell
      successors = G.suc graph nodeId
  in if null successors
     then []  -- This is an outlet
     else let nextNode = head successors  -- Each cell has at most 1 outgoing edge
              nextCell = nodeToCell sz nextNode
          in nextCell : traceDownstream sz graph nextCell

-- | Trace upstream from a cell to sources (follows incoming edges)
traceUpstream :: Sz Ix2 -> DrainageNetwork -> AccumulationGrid -> Ix2 -> [[Ix2]]
traceUpstream sz graph accumGrid cell =
  let nodeId = cellToNode sz cell
      predecessors = G.pre graph nodeId
      predCells = map (nodeToCell sz) predecessors
  in if null predecessors
     then [[]]  -- This is a source
     else concatMap (\predCell ->
            let upstreamPaths = traceUpstream sz graph accumGrid predCell
            in map (predCell :) upstreamPaths
          ) predCells

-- | Find outlet cells (cells with no outgoing edges)
findOutlets :: DrainageNetwork -> [Int]
findOutlets graph =
  [ node
  | node <- G.nodes graph
  , G.outdeg graph node == 0
  ]
