module AstralString exposing (..)

import Regex

-- The Astral Planes of Unicode are not supported in JS and consequently
-- not supported in Elm. The functions here support Astral characters.

oneChar = Regex.regex "[^\\uD800-\\uDFFF]|[\\uD800-\\uDBFF][\\uDC00-\\uDFFF]|[\\uD800-\\uDFFF]"

-- Turn a String into a list of Characters. Because some characters may
-- not be in the BMP the result is a list of Strings and not Chars.
toList : String -> List String
toList =
    Regex.find Regex.All oneChar >> List.map .match

-- for completeness
fromList : List String -> String
fromList = String.concat

filter : (String -> Bool) -> String -> String
filter f = toList >> List.filter f >> fromList

map : (String -> String) -> String -> String
map f = toList >> List.map f >> fromList

length : String -> Int
length =
    Regex.find Regex.All oneChar >> List.length

reverse : String -> String
reverse =
    toList >> List.reverse >> fromList
