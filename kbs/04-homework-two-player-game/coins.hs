{-
  Playing a game of Coins.
-}
module Main where


import System.Environment (getArgs)

import Data.Char
import Data.List


type Board = [Bool]
type IndexedBoard = (Int, Bool)

type Take = [Bool]
type IndexedTake = (Int, Bool)

data Turn = Me | Opponent
    deriving (Show, Eq)

data Node = Node
          { parent :: Node
          , board :: Board
          , turn :: Turn
          }
          | Nil
    deriving (Show, Eq)

makeChild :: Node -> Board -> Node
makeChild p b =
    Node { parent = p, board = b, turn = neg . turn $ p }
  where 
    neg Me = Opponent
    neg Opponent = Me

getChildren :: Node -> [Node]
getChildren p =
    let boards = takeCoins $ board p
    in  map (makeChild p) boards
  where
    takeCoins b =
      let boardLen = length b
          cycleLen = boardLen + 3 - 1

          cycledBd = take cycleLen . cycle $ b
          cycledIndices = 
            take cycleLen . cycle $ take boardLen . cycle $ iterate (1 +) 0
          cycleListIndexed = zip cycledIndices cycledBd

          possibleTakes = unfoldr getTakes cycleListIndexed

          validTakes = concatMap (\t -> 
              concatMap (\i -> 
                unfoldr (getValidTakes i) t
              ) [1,2,3]
            ) possibleTakes
      in  nub $ unfoldr (nextChildBoard b) validTakes

spanMinus :: 
  (IndexedBoard -> Bool) -> 
  [IndexedBoard] ->
  ([IndexedTake], [IndexedTake])
spanMinus b ls =
  (takeWhile b ls, dropWhile (not . b) $ dropWhile b ls)

getTakes ::
  [IndexedBoard] -> 
  Maybe ([IndexedTake], [IndexedTake])
getTakes ls
  | null ls   = Nothing
  | otherwise = Just $ spanMinus snd ls

getValidTakes :: 
  Int -> 
  [IndexedTake] -> 
  Maybe ([IndexedTake], [IndexedTake])
getValidTakes i ls
  | null ls   = Nothing
  | otherwise = Just (take i ls, drop 1 ls)

appendUpdateWith :: 
  [IndexedTake] ->
  Board ->
  Board
appendUpdateWith updateIndices ls =
    snd . unzip $
      map (updateOrLeaveAt updateIndices) (zip (iterate (1 +) 0) ls)
  where updateOrLeaveAt indices (i, e) =
          case find ((==i) . fst) indices of
            Nothing      -> (i, e)
            Just (_, e') -> (i, not e')

nextChildBoard :: 
  Board ->
  [[IndexedTake]] ->
  Maybe (Board, [[IndexedTake]])
nextChildBoard b toTake
  | null toTake = Nothing
  | otherwise   = Just (appendUpdateWith (head toTake) b, drop 1 toTake)

      
threeNode :: Node
threeNode = Node { parent=Nil, board=replicate 3 True, turn=Me }

fourNode :: Node
fourNode = Node { parent=Nil, board=replicate 4 True, turn=Me }

fiveNode :: Node
fiveNode = Node { parent=Nil, board=replicate 5 True, turn=Me }


evaluate :: Node -> Int -> Int
evaluate nd maxMoves =
    let depth = moves nd
    in  case turn nd of
          Me -> (-1) * (maxMoves - depth)
          Opponent -> maxMoves - depth
  where moves b =
          case parent b of
            Nil -> 0
            p   -> 1 + moves p 


{-
  Alpha-Beta pruning
-}
negInf :: Int
negInf = -99999

posInf :: Int
posInf = 99999

alphaBeta :: Node -> Int -> Int -> Int -> (Node, Int)
alphaBeta n maxMoves alpha beta =
  case getChildren n of
    []       -> (n, evaluate n maxMoves)
    children -> bestChild (reverse children) (turn n) maxMoves alpha beta

bestChild :: [Node] -> Turn -> Int -> Int -> Int -> (Node, Int)
bestChild []     _ _        _     _    = error "No children"
bestChild (x:[]) _ maxMoves alpha beta = alphaBeta x maxMoves alpha beta
bestChild (x:xs) t maxMoves alpha beta = 
    let v = alphaBeta x maxMoves alpha beta
    in  prune v
  where prune v
          | t == Me       && snd v >= beta ||
            t == Opponent && snd v <= alpha = v
          | otherwise =
              let alpha' = if t == Me then max (snd v) alpha else alpha
                  beta'  = if t == Opponent then min (snd v) beta  else beta
              in best v (bestChild xs t maxMoves alpha' beta') t

best :: (Node, Int) -> (Node, Int) -> Turn -> (Node, Int)
best (n1, val1) (n2, val2) t
  | val1 >= val2 && t == Me ||
    val1 <= val2 && t == Opponent = (n1, val1)
  | otherwise = (n2, val2)


getBestMove :: [Bool] -> (Int, Int, Int)
getBestMove startBoard =
    let startNode = Node{parent = Nil, board = startBoard, turn = Me}
        (winBoard, moves) =
          alphaBeta startNode (length startBoard) negInf posInf
        secondMove = getSecondMove winBoard
        coinsTaken = length . filter (==False) $ board secondMove
    in  (startIdx secondMove, coinsTaken, moves)
  -- The first move comes from the first child
  where getSecondMove nd =
          case parent nd of
            p -> case parent p of
                   Nil -> nd
                   _   -> getSecondMove p

        startIdx nd =
          case find ((==False) . snd) $ zip (iterate (1 +) 0) (board nd) of
            Nothing -> 0
            Just a  -> fst a


main :: IO ()
main = do
  args <- getArgs
  case args of
    [coins_count] -> case validate coins_count of
                   Left err -> error err
                   Right count -> printResult $ getBestMove (countToBoard count)
    _         -> putStrLn usage
  where printResult (idx, count, moves) =
          putStrLn $ "{ " ++ show idx ++ ", " ++ 
                             show count ++ ", " ++ 
                             show moves ++ " }"
        usage = "Usage: coins <coins_count>"

countToBoard :: Int -> [Bool]
countToBoard = flip replicate True

validate :: String -> Either String Int
validate n
  | isNumber' n && read n > (0 :: Int) = Right (read n)
  | otherwise = Left "There must be a positive number of coins."

isNumber' :: String -> Bool
isNumber' = all isDigit
