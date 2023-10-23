#!/usr/bin/env runghc

{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}

import Data.Default (def)
import Data.Function ((&))
import Data.Text (Text)
import Data.Text qualified as T
import Data.Text.IO qualified as T
import Debug.Trace
import Text.Pandoc (runPure, writeLaTeX)
import Text.Pandoc.Builder
import Text.Pandoc.JSON
import Text.Pandoc.Shared (stringify)
import Text.Pandoc.Walk (Walkable, query)
import Text.Printf
import Text.RawString.QQ
import Text.Show.Unicode

macroToText :: (Text, Text, Int) -> Text
macroToText (a, b, c) = T.pack $ printf "%s: ['{%s}', %d]," a (T.replace "\\" "\\\\" b) c

macrosToScript :: [(Text, Text, Int)] -> Text
macrosToScript x =
  T.pack $
    printf
      [r|<script>
  window.MathJax = {
    tex: {
      macros: {
%s
      }
    }
  };
</script>
  |]
      (T.unlines (map macroToText x))

renderMathMacro :: Walkable Inline a => a -> Text
renderMathMacro = query go
 where
  go :: Inline -> Text
  go Space = " "
  go (Str x) = x
  go (RawInline (Format "tex") x) = x
  go (Code _ x) = x

getMathMacro :: MetaValue -> (Text, Text, Int)
getMathMacro (MetaList [MetaInlines x, MetaInlines y, MetaInlines z]) = (stringify x, renderMathMacro y, read $ T.unpack $ stringify z)

-- where
--  tex = writeLaTeX def (doc $ para $ fromList y) & runPure & either (error . ushow) id

getMathMacros :: Meta -> [(Text, Text, Int)]
getMathMacros m =
  let
    a = lookupMeta "math_macros" m
    res = case a of
      Just (MetaList xs) -> map getMathMacro xs
      _ -> []
   in
    res

addFilter :: Meta -> Meta
addFilter m =
  let
    a = getMathMacros m
    script = macrosToScript a
   in
    setMeta "header-includes" (fromList [RawBlock "html" script]) m

main = toJSONFilter addFilter
