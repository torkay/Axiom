{-# LANGUAGE DataKinds #-}

module Main (main) where

import Axiom.World (World(..), Phase(..))

main :: IO ()
main = do
  let w = EmptyWorld :: World 'Empty
  putStrLn "World initialized: Empty phase"
