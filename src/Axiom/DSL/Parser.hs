{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE StrictData #-}
module Axiom.DSL.Parser
  ( parseLaws
  , universalLaws
  , law
  , expression
  ) where

import Text.Megaparsec
import qualified Text.Megaparsec.Char.Lexer as L
import Data.Text (Text)

import Axiom.DSL.AST
import Axiom.DSL.Lexer

-- | Parse a complete Universal Laws file
parseLaws :: Text -> Either String [Law]
parseLaws input = case parse universalLaws "" input of
  Left err -> Left (errorBundlePretty err)
  Right laws -> Right laws

-- | Top-level parser: consume initial whitespace, parse laws, expect EOF
universalLaws :: Parser [Law]
universalLaws = sc *> many law <* eof

-- | Parse a single law definition
-- Syntax: law <name>: <expression>
law :: Parser Law
law = do
  reserved "law"
  name <- identifier
  _ <- symbol ":"
  expr <- expression
  return $ Law name expr

-- | Parse an expression (entry point for expression parsing)
expression :: Parser Expr
expression = ifExpr <|> addExpr

-- | Parse an if-then-else expression
-- Syntax: if <condition> then <expr> else <expr>
ifExpr :: Parser Expr
ifExpr = do
  reserved "if"
  cond <- condition
  reserved "then"
  thenExpr <- expression
  reserved "else"
  elseExpr <- expression
  return $ If cond thenExpr elseExpr

-- | Parse addition expression (left-associative)
-- This handles both simple terms and addition chains
addExpr :: Parser Expr
addExpr = do
  first <- term
  rest first
  where
    rest expr = (do
      _ <- symbol "+"
      next <- term
      rest (Add expr next)) <|> return expr

-- | Parse a term (variable, constant, or parenthesized expression)
term :: Parser Expr
term = parens expression
   <|> Const <$> integer
   <|> Var <$> identifier

-- | Parse an integer constant
integer :: Parser Int
integer = lexeme L.decimal

-- | Parse a parenthesized expression
parens :: Parser a -> Parser a
parens = between (symbol "(") (symbol ")")

-- | Parse a condition
condition :: Parser Condition
condition = try equalsCondition <|> greaterThanCondition

-- | Parse equality condition
-- Syntax: <expr> == <expr>
equalsCondition :: Parser Condition
equalsCondition = do
  left <- term
  _ <- symbol "=="
  right <- term
  return $ Equals left right

-- | Parse greater-than condition
-- Syntax: <expr> > <expr>
greaterThanCondition :: Parser Condition
greaterThanCondition = do
  left <- term
  _ <- symbol ">"
  right <- term
  return $ GreaterThan left right
