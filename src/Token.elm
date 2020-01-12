module Token exposing (..)

import Set

{-| A single letter in the script
-}
type alias Token =
    Char

type alias NamedToken =
    { name : String.String, token : Char }

fromNamed : List NamedToken -> List Token
fromNamed nts = List.map .token nts


{-| Create list of NamedTokens with the token itself as name.

Some scripts don't have names for each token.
-}
selfNamed : List Token -> List NamedToken
selfNamed = List.map (\t -> { token = t, name = String.fromChar t })


-- Turn a string into a list of tokens
toList : String -> List Token
toList = String.toList 

replace : Token -> Token -> String -> String
replace a b = String.split (String.fromChar a) >> String.join (String.fromChar b)

