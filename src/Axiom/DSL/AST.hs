{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE StrictData #-}
module Axiom.DSL.AST where

import Data.Text (Text)
import GHC.Generics (Generic)

-- | A Universal Law with a name and an expression
data Law = Law Text Expr
  deriving (Show, Eq, Generic)

-- | Expressions in the DSL
data Expr
  = Var Text          -- ^ Variable reference
  | Const Int         -- ^ Integer constant
  | Add Expr Expr     -- ^ Addition
  | If Condition Expr Expr  -- ^ Conditional expression
  deriving (Show, Eq, Generic)

-- | Conditions for if-then-else
data Condition
  = Equals Expr Expr      -- ^ Equality comparison
  | GreaterThan Expr Expr -- ^ Greater-than comparison
  deriving (Show, Eq, Generic)
