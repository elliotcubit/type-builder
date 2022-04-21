module Main where

import System.Environment
import Parser

main :: IO ()
main = do
  args <- getArgs
  if null args then putStrLn "usage: [exe] <service name> <file to data>" else parseFile (head args) (last args)
