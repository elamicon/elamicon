module Tokens exposing (..)

import ScriptDefs exposing (..)

-- Turn a string into a list of tokens
toList : String -> List Token
toList = String.toList 

replace : Token -> Token -> String -> String
replace a b = String.split (String.fromChar a) >> String.join (String.fromChar b)

