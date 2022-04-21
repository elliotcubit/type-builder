module Parser(
  parseFile
) where

import Data.List(findIndex, intercalate, stripPrefix)
import Data.Char(toUpper, toLower)
import Data.Maybe(mapMaybe)

data FieldDescriptor = FieldDescriptor {fd_name :: String, fd_typ :: String} deriving (Show, Eq)
data Tree = Root {root_name :: String, root_children :: [Tree]}
          | Leaf {leaf_fd :: FieldDescriptor} 
          | Branch {branch_name :: String, branch_children :: [Tree]} deriving Show

isbs :: FieldDescriptor -> Tree -> Bool
isbs fd (Branch n _) = n == fd_name fd
isbs _ _ = False

-- Find element by FD and return found element + all elems excluding it
pop :: [Tree] -> FieldDescriptor -> (Maybe Tree, [Tree])
pop ts fd =
  case findIndex (isbs fd) ts of
    Just n -> (Just $ ts !! n, take n ts ++ drop (n+1) ts)
    Nothing -> (Nothing, ts)

tinsert :: Tree -> [FieldDescriptor] -> Tree

tinsert v path
  | null path = v

tinsert (Root n c) path
  | length path == 1 = Root n (Leaf (head path) : c)
  | otherwise = case pop c (head path) of
    (Just existing, other) -> Root n (tinsert existing (tail path) : other)
    (Nothing, other) -> Root n (tinsert (Branch (fd_name $ head path) []) (tail path) : other)

tinsert (Branch fd c) path
  | length path == 1 = Branch fd (Leaf (head path) : c)
  | otherwise = case pop c (head path) of
    (Just existing, other) -> Branch fd (tinsert existing (tail path) : other)
    (Nothing, other) -> Branch fd (tinsert (Branch (fd_name $ head path) []) (tail path) : other)

-- Inserting past a leaf changes it to an empty branch
tinsert (Leaf fd) path = tinsert (Branch (fd_name fd) []) path

pfield :: [String] -> Tree -> String

pfield _ (Leaf (FieldDescriptor n t)) = "\t" ++ canonField n ++ " " ++ t ++ " `json:\"" ++ n ++ "\"`\n"

pfield paths (Branch n _) = "\t" ++ canonField n ++ " " ++ ft ++ " `json:\"" ++ n ++ "\"`\n"
  where
  ft = buildFieldType paths n

-- >:(
pfield _ (Root _ _) = undefined

-- Take the path up to this point,
-- The tree, and return a stringified go struct for this level
ppT :: [String] -> Tree -> Maybe [String]
ppT paths (Root n c) = Just (s : concat (mapMaybe (ppT (paths ++ [n])) c)) where
  dec = "type " ++ buildFieldType paths n ++ " struct {\n"
  fields = concatMap (pfield (paths ++ [n])) $ reverse c
  s = dec ++ fields ++ "}"

ppT paths (Branch n c) = Just (s : concat (mapMaybe (ppT (paths ++ [n])) c)) where
  dec = "type " ++ buildFieldType paths n ++ " struct {\n"
  fields = concatMap (pfield (paths ++ [n])) $ reverse c
  s = dec ++ fields ++ "}"

ppT _ _ = Nothing

-- convType takes a type from the Search
-- page and converts it into a Golang type
convType :: String -> Maybe String
convType "text" = Just "string"
convType "ip" = Just "string"
convType "keyword" = Just "string"
convType "unsigned_long" = Just "uint64"
convType "long" = Just "int64"
convType "boolean" = Just "bool"
convType "integer" = Just "int"
convType _ = Nothing

wordsWhen :: (Char -> Bool) -> String -> [String]
wordsWhen p s = case dropWhile p s of
                  "" -> []
                  s' -> w : wordsWhen p s''
                        where (w, s'') = break p s'

cap :: String -> String
cap [] = []
cap (h:t) = toUpper h : map toLower t

canonField :: String -> String
canonField = concatMap cap . wordsWhen (=='_')

buildFieldType :: [String] -> String -> String
buildFieldType upto this = intercalate "_" (map canonField (upto ++ [this]))

pathsAndFd :: String -> String -> Maybe ([String], FieldDescriptor)
pathsAndFd t s = case convType t of
    Just nt -> Just (init w, FieldDescriptor (last w) nt)
    Nothing -> Nothing
    where w = wordsWhen (=='.') s

parseLine :: String -> String -> Maybe [FieldDescriptor]
parseLine s c =
  q where
    w = words c

    j = pathsAndFd (w !! 1) =<< stripPrefix ("services." ++ s ++ ".") (head w)

    q = case j of
      Just (sts, fd) -> Just $ map (`FieldDescriptor` "") sts ++ [fd]
      Nothing -> Nothing

buildTree :: String -> String -> Tree
buildTree s raw = foldl tinsert (Root s []) (mapMaybe (parseLine s) (lines raw))

parseFile :: String -> String -> IO ()
parseFile sname fname = do
  content <- readFile fname
  let tree = buildTree sname content
  case ppT [] tree of
    Just values -> putStrLn $ intercalate "\n\n" values
    Nothing -> putStrLn "something terrible happened"
