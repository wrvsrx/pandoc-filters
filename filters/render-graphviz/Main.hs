{-# LANGUAGE OverloadedStrings #-}

import Control.Monad (unless, when)
import Crypto.Hash.SHA256 (hash)
import Data.ByteString.Base16
import Data.ByteString.UTF8 (fromString, toString)
import Data.Default (def)
import Data.Function ((&))
import Data.Functor ((<&>))
import Data.Text (Text)
import Data.Text qualified as T
import Data.Text.IO qualified as T
import Debug.Trace
import GHC.Read qualified as T
import System.Directory (createDirectoryIfMissing, doesFileExist)
import System.FilePath ((</>))
import System.Process (CreateProcess (..), proc, readCreateProcess, readProcess)
import Text.Pandoc (runPure, writeLaTeX)
import Text.Pandoc.Builder
import Text.Pandoc.JSON
import Text.Pandoc.Shared (stringify)
import Text.Pandoc.Walk (Walkable, query)
import Text.Printf

cacheDir = ".cache"

renderGraphviz :: Block -> IO Block
renderGraphviz x@(CodeBlock (iden, cls_a, pair_b) t_) =
  let
    text = do
      if not (null cls_a) then Just () else Nothing
      if head cls_a == "dot" then Just () else Nothing
      return t_
   in
    case text of
      Just t
        | "graphviz" `elem` tail cls_a -> do
            svgCnt <- readProcess "dot" ["-T", "svg"] (T.unpack t) <&> T.pack
            let
              block = Div ("", [], [("style", "text-align: center")]) [RawBlock (Format "html") svgCnt]
            return block
        | "tikz" `elem` tail cls_a -> do
            let
              hashResult = (toString . encode . hash . fromString . T.unpack) t
              cacheName = hashResult <> ".svg"
              cachePath = cacheDir </> cacheName
              pdflatexProcess = (proc "pdflatex" []){cwd = Just cacheDir}
              pdf2svgProcess = (proc "pdf2svg" ["texput.pdf", cacheName]){cwd = Just cacheDir}
            createDirectoryIfMissing False cacheDir
            e <- doesFileExist cachePath
            unless e $ do
              s <- readProcess "dot2tex" ["--autosize", "--nominsize", "--crop"] (T.unpack t) <&> T.pack
              _ <- readCreateProcess pdflatexProcess (T.unpack s)
              _ <- readCreateProcess pdf2svgProcess ""
              return ()
            -- svgCnt <- T.readFile cachePath
            let
              block = Div ("", [], [("style", "text-align: center")]) [Para [Image ("", ["center"], []) [] (T.pack cachePath, "")]]
            return block
        | True -> return x
      Nothing -> return x
renderGraphviz x = return x
main = toJSONFilter renderGraphviz
