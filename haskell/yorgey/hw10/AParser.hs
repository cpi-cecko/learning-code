{- CIS 194 HW 10
   due Monday, 1 April
-}

module AParser where

import           Control.Applicative

import           Data.Char

-- A parser for a value of type a is a function which takes a String
-- represnting the input to be parsed, and succeeds or fails; if it
-- succeeds, it returns the parsed value along with the remainder of
-- the input.
newtype Parser a = Parser { runParser :: String -> Maybe (a, String) }

-- For example, 'satisfy' takes a predicate on Char, and constructs a
-- parser which succeeds only if it sees a Char that satisfies the
-- predicate (which it then returns).  If it encounters a Char that
-- does not satisfy the predicate (or an empty input), it fails.
satisfy :: (Char -> Bool) -> Parser Char
satisfy p = Parser f
  where
    f [] = Nothing    -- fail on the empty input
    f (x:xs)          -- check if x satisfies the predicate
                        -- if so, return x along with the remainder
                        -- of the input (that is, xs)
        | p x       = Just (x, xs)
        | otherwise = Nothing  -- otherwise, fail

-- Using satisfy, we can define the parser 'char c' which expects to
-- see exactly the character c, and fails otherwise.
char :: Char -> Parser Char
char c = satisfy (== c)

{- For example:

*Parser> runParser (satisfy isUpper) "ABC"
Just ('A',"BC")
*Parser> runParser (satisfy isUpper) "abc"
Nothing
*Parser> runParser (char 'x') "xyz"
Just ('x',"yz")

-}

-- For convenience, we've also provided a parser for positive
-- integers.
posInt :: Parser Integer
posInt = Parser f
  where
    f xs
      | null ns   = Nothing
      | otherwise = Just (read ns, rest)
      where (ns, rest) = span isDigit xs

------------------------------------------------------------
-- Your code goes below here
------------------------------------------------------------

instance Functor Parser where
    fmap f pa = Parser $ \str -> fmap (first f) (runParser pa str)

first :: (a -> b) -> (a, c) -> (b, c)
first f (a, c) = (f a, c)

instance Applicative Parser where
    pure a = Parser $ \str -> Just (a, str)

    p1 <*> p2 = Parser f
      where f = \str -> case runParser p1 str of
                            Nothing -> Nothing
                            Just (g, str') -> fmap (first g) (runParser p2 str')

-- | @abParser@ parses the first two chars of a string and returns them in a 
--   tuple if they match 'a' and 'b'
abParser :: Parser (Char, Char)
abParser = (,) <$> char 'a' <*> char 'b'

-- | @abParser_@ acts like @abParser@ but discards its parsed result.
abParser_ :: Parser ()
abParser_ =  void2 <$> char 'a' <*> char 'b'

-- | @intPair@ parser two integer values separated by space.
intPair :: Parser [Integer]
intPair = pairList <$> posInt <* satisfy (==' ') <*> posInt
  where pairList = (\a b -> a : [b])

instance Alternative Parser where
    empty = Parser (\_ -> Nothing)
    p1 <|> p2 = Parser (\str -> runParser p1 str <|> runParser p2 str)

-- | @intOrUppercase@ parser an integer or an uppercase char
intOrUppercase :: Parser ()
intOrUppercase = void <$> posInt <|> void <$> (satisfy isUpper)

-- | @void@ discards its argument and returns ()
void :: a -> ()
void _ = ()

-- | @void2@ discards both arguments and returns ()
void2 :: a -> b -> ()
void2 _ _ = ()
