#!/usr/bin/env runghc

{-#LANGUAGE OverloadedStrings#-}
import Text.Pandoc.JSON

addCenterToH1 :: Block -> Block
addCenterToH1 (Header 1 (id, cls, dict) i) = Header 1 (id, "center" : cls, dict) i
addCenterToH1 x = x

main = toJSONFilter addCenterToH1
