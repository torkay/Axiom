{-# LANGUAGE StrictData #-}
{-|
Module: Axiom.CLI.Options
Description: Command-line argument parsers for Axiom CLI
-}

module Axiom.CLI.Options
  ( Command(..)
  , GenerateOpts(..)
  , SimulateOpts(..)
  , ExportOpts(..)
  , Format(..)
  , opts
  ) where

import Options.Applicative

-- | Top-level command type
data Command
  = Generate GenerateOpts
  | Simulate SimulateOpts
  | Export ExportOpts
  deriving Show

-- | Options for world generation
data GenerateOpts = GenerateOpts
  { genSeed :: Int
  , genSize :: (Int, Int)      -- ^ (width, height)
  , genLawsFile :: Maybe FilePath
  , genOutput :: FilePath
  } deriving Show

-- | Options for simulation
data SimulateOpts = SimulateOpts
  { simYears :: Int
  , simWorldFile :: FilePath  -- ^ Load serialized world
  , simOutput :: FilePath
  } deriving Show

-- | Options for export
data ExportOpts = ExportOpts
  { exportFormat :: Format
  , exportOutput :: FilePath
  , exportInput :: FilePath
  } deriving Show

-- | Export format type
data Format = JSON | ASCII
  deriving (Show, Read)

-- | Parse generate command
generateParser :: Parser GenerateOpts
generateParser = GenerateOpts
  <$> option auto
      ( long "seed"
     <> metavar "INT"
     <> help "Random seed for world generation"
     <> value 42
      )
  <*> option auto
      ( long "size"
     <> metavar "(WIDTH,HEIGHT)"
     <> help "World grid size (e.g., (256,256))"
     <> value (256, 256)
      )
  <*> optional (strOption
      ( long "laws"
     <> metavar "FILE"
     <> help "Optional Universal Laws file (DSL)"
      ))
  <*> strOption
      ( long "output"
     <> short 'o'
     <> metavar "FILE"
     <> help "Output file for generated world"
     <> value "world.json"
      )

-- | Parse simulate command
simulateParser :: Parser SimulateOpts
simulateParser = SimulateOpts
  <$> option auto
      ( long "years"
     <> metavar "INT"
     <> help "Number of years to simulate"
     <> value 100
      )
  <*> strOption
      ( long "world"
     <> short 'w'
     <> metavar "FILE"
     <> help "Input world file (JSON)"
      )
  <*> strOption
      ( long "output"
     <> short 'o'
     <> metavar "FILE"
     <> help "Output file for simulation result"
     <> value "world-sim.json"
      )

-- | Parse export command
exportParser :: Parser ExportOpts
exportParser = ExportOpts
  <$> option auto
      ( long "format"
     <> short 'f'
     <> metavar "FORMAT"
     <> help "Export format (JSON or ASCII)"
     <> value JSON
      )
  <*> strOption
      ( long "output"
     <> short 'o'
     <> metavar "FILE"
     <> help "Output file"
      )
  <*> argument str
      ( metavar "INPUT"
     <> help "Input world file"
      )

-- | Main command parser with subcommands
commandParser :: Parser Command
commandParser = subparser
  ( command "generate"
    (info (Generate <$> generateParser)
          (progDesc "Generate a new world"))
 <> command "simulate"
    (info (Simulate <$> simulateParser)
          (progDesc "Run historical simulation"))
 <> command "export"
    (info (Export <$> exportParser)
          (progDesc "Export world in different formats"))
  )

-- | Top-level parser with help
opts :: ParserInfo Command
opts = info (commandParser <**> helper)
  ( fullDesc
 <> progDesc "Axiom: Deterministic world generation engine"
 <> header "axiom - causal world-gen with DSL and simulation"
  )
