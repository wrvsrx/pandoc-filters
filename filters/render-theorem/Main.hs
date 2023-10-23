{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NoFieldSelectors #-}

import Control.Monad (unless, when)
import Data.ByteString.Base16
import Data.ByteString.UTF8 (fromString, toString)
import Data.Default (def)
import Data.Function ((&))
import Data.Functor ((<&>))
import Data.Map qualified as M
import Data.Maybe (fromMaybe)
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

data TheoremLike = TheoremLike
  { kind :: Text
  , attr :: Attr
  , name :: [Inline]
  , content :: [Block]
  }

nameMap :: M.Map Text Text
nameMap =
  M.fromList
    [ ("theorem", "Theorem")
    , ("example", "Example")
    , ("remark", "Remark")
    , ("algorithm", "Algorithm")
    , ("question", "Question")
    ]

data ParseTheoremLikeFailure = BlockIsNotDiv | DivIsNotTheoremKind | DivIsEmpty | TooManyTheoremClassInDiv | NameIsNotPara

pickTheorem :: M.Map Text Text -> Block -> Either ParseTheoremLikeFailure TheoremLike
pickTheorem m b = do
  (pid, cls, dict, blocks) <- case b of
    Div (pid, cls, dict) blocks -> Right (pid, cls, dict, blocks)
    _ -> Left BlockIsNotDiv
  kind <- case filter (`M.member` m) cls of
    [] -> Left DivIsNotTheoremKind
    [x] -> Right x
    _ -> Left TooManyTheoremClassInDiv
  (nameToParse, content) <- case blocks of
    x : xs -> Right (x, xs)
    [] -> Left DivIsEmpty
  name <- case nameToParse of
    Para x -> Right x
    _ -> Left NameIsNotPara
  Right $ TheoremLike kind (pid, cls, dict) name content

renderTheorem :: M.Map Text Text -> TheoremLike -> Block
renderTheorem m theorem =
  let renderedKind = fromMaybe (error "no such theorem type") (theorem.kind `M.lookup` m)
      renderedName = Para [Strong [Str renderedKind], Space, Str "(", Span ("", ["theorem-name"], []) theorem.name, Str ")"]
   in Div
        theorem.attr
        [ Div ("", ["theorem-head"], []) [renderedName]
        , Div ("", ["theorem-content"], []) theorem.content
        ]

theoremFilter :: M.Map Text Text -> Block -> Block
theoremFilter m b =
  let
    pickResult = pickTheorem m b
   in
    case pickResult of
      Left err -> b
      Right t -> renderTheorem m t

main = toJSONFilter (theoremFilter nameMap)
