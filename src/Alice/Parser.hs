{-# LANGUAGE ImportQualifiedPost #-}

module Alice.Parser (
    Atom (..),
    doParse,
) where

import Control.Applicative (Alternative ((<|>)))
import Data.Void (Void)
import Text.Megaparsec
import Text.Megaparsec.Char
import Text.Megaparsec.Char.Lexer qualified as L

type Parser = Parsec Void String

-- AST for a Lisp expression
data Atom
    = Int Int
    | Symbol String
    | String String
    | List [Atom]
    deriving (Eq, Show)

sc :: Parser ()
sc = L.space space1 lineComment empty
  where
    lineComment = L.skipLineComment ";;"

lexeme :: Parser a -> Parser a
lexeme = L.lexeme sc

symbol :: String -> Parser String
symbol = L.symbol sc

-- * Parsers
sym :: Parser Atom
sym = Symbol <$> lexeme (some letterChar <|> (some . oneOf) symbols)
  where
    symbols = ['+', '-', '*', '/', '_', '#', '<', '>', '=', '!']

string :: Parser Atom
string = String <$> (char '"' *> manyTill L.charLiteral (char '"'))

number :: Parser Atom
number = Int <$> lexeme L.decimal

list :: Parser Atom
list = do
    symbol "("
    expr <- many atom
    symbol ")"
    pure $ List expr

atom :: Parser Atom
atom = number <|> sym <|> list

-- Run the parser on the input provided
doParse :: String -> Either String Atom
doParse input = do
    let result = parse atom "alicelisp" input
    case result of
        Left err -> Left $ show err
        Right val -> Right val
