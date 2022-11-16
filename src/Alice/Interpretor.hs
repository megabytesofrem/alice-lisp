{-# LANGUAGE EmptyCase #-}
{-# LANGUAGE ImportQualifiedPost #-}

module Alice.Interpretor where

import Alice.Parser (Atom (..))
import Control.Monad.State

data Interpreter = Interpreter {vars :: [Int]}

data Symbol
    = FunctionCall String Atom -- (+ 1 2)
    | Let String Atom Atom -- (let x 5 (+ x 1))

-- We work in the State monad for the interpretor stuff
-- Later on, this will use a MTL transformer stack of IO and State since
-- the interpretor needs to print stuff to the screen too
newtype InterpretorState = State Interpreter

-- Special case let bindings
interpretList :: Atom -> Atom
interpretList a@(List as) = case head as of
    Symbol "let" -> a
    _ -> a

interpret :: Atom -> Atom
interpret a = case a of
    Int i -> a
    Symbol s -> a
    String s -> a
    List as -> interpretList a

doInterpret :: Atom -> Atom
doInterpret = interpret