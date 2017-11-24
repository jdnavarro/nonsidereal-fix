module Main where

import Prelude hiding (readFile, writeFile)
import Data.Bifunctor (second)
import System.Environment (getArgs)

import Data.Text (pack, unpack)
import System.FilePath.Posix (replaceBaseName, takeBaseName)

import Text.XML
  ( Document(..)
  , Element(..)
  , Name
  , Node(NodeContent, NodeElement)
  , def
  , readFile
  , rsPretty
  , writeFile
  )
import Text.XML.Cursor
  ( ($/), (&/)
  , content
  , element
  , fromNode
  )

main :: IO ()
main = do
    args <- getArgs
    case args of
      (fp : _) -> do
        Document prologue root epilogue <- readFile def fp
        let root' = targets root
        writeFile def { rsPretty = False } (addBaseName fp "-fix")
          $ Document prologue root' epilogue
      _ -> putStrLn "Please provide input XML as the first argument."
  where
    addBaseName :: FilePath -> String -> FilePath
    addBaseName fp str = replaceBaseName fp $ takeBaseName fp ++ str

targets :: Element -> Element
targets (Element name attrs children) =
    Element name attrs . uncurry (++)
                       . second (withHead nonSidereals)
                       $ break isTargets children
  where
    isTargets :: Node -> Bool
    isTargets (NodeElement (Element "targets" _ _)) = True
    isTargets _ = False

    -- Poors man lens
    withHead :: (a -> a) -> [a] -> [a]
    withHead f (x : xs) = f x : xs
    withHead _ x = x

nonSidereals :: Node -> Node
nonSidereals (NodeElement (Element name attrs children)) =
    NodeElement . Element name attrs $ nonSidereal <$> children
nonSidereals n = n

nonSidereal :: Node -> Node
nonSidereal n@(NodeElement (Element "nonsidereal" attrs children)) =
    NodeElement . Element "sidereal" attrs $ ephemeris children
  where
    ephemeris :: [Node] -> [Node]
    ephemeris (x : y : z : _) = [x, y, z] ++
      -- Assuming "name" is always the first node.
      [ NodeElement $ Element "degDeg" mempty
        [ NodeElement $ Element "ra" mempty
          [NodeContent . pack . show $ avg "ra"]
        , NodeElement $ Element "dec" mempty
          [NodeContent . pack . show $ avg "dec"]
        ]
      ]
    ephemeris ns = ns

    avg :: Name -> Double
    avg tag = sum coords / fromIntegral (length coords)
      where
        coords = fmap (read . unpack)
               $ fromNode n
               $/ element "ephemeris"
               &/ element "degDeg"
               &/ element tag
               &/ content

nonSidereal n = n

filterElements :: [Node] -> [Node]
filterElements = filter isElement
  where
    isElement (NodeElement _) = True
    isElement _ = False
