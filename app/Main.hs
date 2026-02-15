{-|
Module: Main
Description: Axiom CLI entry point
-}

module Main where

import Axiom.CLI.Options (opts)
import Axiom.CLI.Commands (runCommand)
import Options.Applicative (execParser)

main :: IO ()
main = do
  cmd <- execParser opts
  runCommand cmd
