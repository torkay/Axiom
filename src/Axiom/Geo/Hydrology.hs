module Axiom.Geo.Hydrology
  ( priorityFlood
  , fillDepressions
  ) where

import qualified Data.Massiv.Array as M
import Data.Massiv.Array (Array, Ix2(..), U, Sz(Sz2))
import Data.PSQueue (PSQ)
import qualified Data.PSQueue as Q
import qualified Data.Set as Set

type ElevationGrid = Array U Ix2 Double

-- | Fill depressions using Priority-Flood algorithm (Barnes et al. 2014)
-- O(m log² m) where m is number of cells
priorityFlood :: ElevationGrid -> ElevationGrid
priorityFlood grid =
  let sz = M.size grid
      border = borderCells sz
      initQueue = foldr (\pos q -> Q.insert pos (grid M.! pos) q) Q.empty border
      initProcessed = Set.fromList border
      (finalGrid, _) = processQueue grid initQueue initProcessed sz
  in finalGrid

-- | Alias for clarity
fillDepressions :: ElevationGrid -> ElevationGrid
fillDepressions = priorityFlood

-- | Process the priority queue until empty
processQueue :: ElevationGrid -> PSQ Ix2 Double -> Set.Set Ix2 -> Sz Ix2 -> (ElevationGrid, Set.Set Ix2)
processQueue grid queue processed sz
  | Q.null queue = (grid, processed)
  | otherwise =
      case Q.minView queue of
        Nothing -> (grid, processed)
        Just (pos Q.:-> elev, rest) ->
          let neighbors = getNeighbors pos sz
              unprocessed = filter (`Set.notMember` processed) neighbors
              (newGrid, newQueue, newProcessed) =
                foldl (processNeighbor elev) (grid, rest, processed) unprocessed
          in processQueue newGrid newQueue newProcessed sz

-- | Process a single neighbor cell
processNeighbor :: Double -> (ElevationGrid, PSQ Ix2 Double, Set.Set Ix2) -> Ix2 -> (ElevationGrid, PSQ Ix2 Double, Set.Set Ix2)
processNeighbor currentElev (grid, queue, processed) neighborPos =
  let neighborElev = grid M.! neighborPos
      -- Raise neighbor elevation if it's lower than current (fill depression)
      raisedElev = max neighborElev currentElev
      -- Update the grid by creating a new array with the modified value
      updatedGrid = M.makeArrayR M.U (M.getComp grid) (M.size grid) $ \idx ->
                      if idx == neighborPos then raisedElev else grid M.! idx
      newQueue = Q.insert neighborPos raisedElev queue
      newProcessed = Set.insert neighborPos processed
  in (updatedGrid, newQueue, newProcessed)

-- | Get all border cells (edges of the grid)
borderCells :: Sz Ix2 -> [Ix2]
borderCells (Sz2 rows cols) =
  let topBottom = [r :. c | r <- [0, rows - 1], c <- [0..cols - 1]]
      leftRight = [r :. c | r <- [1..rows - 2], c <- [0, cols - 1]]
  in topBottom ++ leftRight

-- | Get valid 8-connected neighbors
getNeighbors :: Ix2 -> Sz Ix2 -> [Ix2]
getNeighbors (r :. c) (Sz2 rows cols) =
  let deltas = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]
      candidates = [(r + dr) :. (c + dc) | (dr, dc) <- deltas]
      inBounds (row :. col) = row >= 0 && row < rows && col >= 0 && col < cols
  in filter inBounds candidates
