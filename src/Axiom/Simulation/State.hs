{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE StrictData #-}
module Axiom.Simulation.State
  ( WorldState(..)
  , Civilization(..)
  , HistoricalEvent(..)
  , CivID
  , Simulation
  , initialWorldState
  ) where

import qualified Data.Map.Strict as Map
import Data.Map.Strict (Map)
import Control.Monad.State.Strict (State)
import GHC.Generics (Generic)
import Data.Text (Text)
import Data.Aeson (ToJSON(..), FromJSON(..), genericToEncoding, defaultOptions)

-- | Unique identifier for civilizations
type CivID = Int

-- | A civilization with population, technology level, and location
data Civilization = Civilization
  { civPopulation :: !Int       -- ^ Population count
  , civTechnology :: !Int       -- ^ Technology level (0+)
  , civLocation   :: !(Int, Int) -- ^ Tile coordinates (x, y)
  } deriving (Show, Eq, Generic)

instance ToJSON Civilization where
  toEncoding = genericToEncoding defaultOptions

instance FromJSON Civilization

-- | Historical events that occur during simulation
data HistoricalEvent
  = TechMilestone CivID Int Text  -- ^ Civilization reached tech level with description
  | PopulationThreshold CivID Int -- ^ Civilization reached population milestone
  deriving (Show, Eq, Generic)

instance ToJSON HistoricalEvent where
  toEncoding = genericToEncoding defaultOptions

instance FromJSON HistoricalEvent

-- | The complete world state during simulation
data WorldState = WorldState
  { civilizations :: !(Map CivID Civilization) -- ^ All civilizations
  , currentYear   :: !Int                      -- ^ Current simulation year
  , events        :: ![HistoricalEvent]        -- ^ Historical events (most recent first)
  } deriving (Show, Eq, Generic)

instance ToJSON WorldState where
  toEncoding = genericToEncoding defaultOptions

instance FromJSON WorldState

-- | The simulation monad: State transformer over WorldState
type Simulation a = State WorldState a

-- | Create an initial world state with one starting civilization
initialWorldState :: WorldState
initialWorldState = WorldState
  { civilizations = Map.singleton 1 (Civilization 1000 1 (128, 128))
  , currentYear = 0
  , events = []
  }
