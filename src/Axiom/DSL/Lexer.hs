{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE StrictData #-}
module Axiom.DSL.Lexer
  ( Parser
  , sc
  , lexeme
  , symbol
  , identifier
  , reserved
  , reservedWords
  ) where

import Text.Megaparsec
import Text.Megaparsec.Char
import qualified Text.Megaparsec.Char.Lexer as L
import Data.Void
import Data.Text (Text)
import qualified Data.Text as T
import Data.Char (isLetter)

-- | Concrete parser type for performance (avoids polymorphic overhead)
type Parser = Parsec Void Text

-- | Space consumer: handles whitespace, line comments, and block comments
sc :: Parser ()
sc = L.space
  space1                          -- consume whitespace
  (L.skipLineComment "--")        -- line comments: -- comment
  (L.skipBlockComment "{-" "-}")  -- block comments: {- comment -}

-- | Lexeme wrapper: parse and consume trailing whitespace
lexeme :: Parser a -> Parser a
lexeme = L.lexeme sc

-- | Symbol: parse specific string and consume trailing whitespace
symbol :: Text -> Parser Text
symbol = L.symbol sc

-- | Reserved keywords that cannot be used as identifiers
reservedWords :: [Text]
reservedWords = ["law", "if", "then", "else"]

-- | Parse a reserved keyword
reserved :: Text -> Parser ()
reserved w = (lexeme . try) (string w *> notFollowedBy alphaNumChar)

-- | Parse an identifier (must not be a reserved word)
-- Uses takeWhileP for performance (100x faster than many/satisfy)
-- Identifiers: start with letter, followed by letters, digits, or underscores
identifier :: Parser Text
identifier = lexeme (try (p >>= check))
  where
    p = T.cons <$> satisfy isLetter <*> takeWhileP (Just "identifier") isIdentChar
    isIdentChar c = isLetter c || c == '_' || (c >= '0' && c <= '9')
    check x = if x `elem` reservedWords
              then fail $ "keyword " ++ show x ++ " cannot be used as identifier"
              else return x
