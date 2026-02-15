{-# LANGUAGE DataKinds #-}

module Main (main) where

import Axiom.World (World(..))
import qualified Axiom.Geo.Elevation as Elev

main :: IO ()
main = do
  -- Generate elevation map with seed 42
  let elevMap = Elev.generate 42

  -- Sample center point
  let centerElev = Elev.sample elevMap (256, 256)
  putStrLn $ "Generated 512x512 elevation map, center elevation: " ++ show centerElev

  -- Create World with elevation (demonstrates GADT type progression)
  let _worldWithElev = WithElevation elevMap EmptyWorld
  putStrLn "World advanced to HasElevation phase"
