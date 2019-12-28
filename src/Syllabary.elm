module Syllabary exposing (Syllabary, Type, fromString, filter, allTokens, normalize)

import Dict exposing (Dict)
import List
import Regex
import ScriptDefs exposing (..)
import Specialchars exposing (..)
import Set exposing (Set)
import String
import Tokens
import WritingDirections exposing (..)

{-| In an undeciphered script it is unclear whether a token that doesn't
look exactly the same as another token belongs to the same type (has
the same meaning) or belongs to a different type. For example, the
letters 'd' and 'b' look very similar and for somebody not trained
in modern Latin fonts. They wouldn't be sure whether a difference is
stylistic (the token was written differently) or whether
the meaning is different (the token belongs to a different type).
Similarily, they wouldn't know that 'A' and 'a' belong to the
same type. And depending on context, we might even want to include Greek
'α' in the type so that searching for 'a' also works in Greek text.

Undeciphered scripts are catalogued with many token variants to allow
for the possibility that they belong to different types. Because an
important part of the decipherment is deciding which tokens belong
to a type, the many variants are grouped into types dynamically and the
grouping can be changed quickly.

Each Type has a (display) name and a Token that is representative for it.
-}
type alias Type =
    { name : String, representative : Token, tokens : List Token }


{-| We call a collection of Types a "syllabary". We use the term
for all lists of Types. For some scripts "alphabetary" would fit
better.

We want to make changes to the syllabary a cheap operation, so the
interpretation of which types mean the same thing can be changed quickly.

**Linguistic diversion:** Linguists distinguish between tokens and types and the
distinction is useful here. [More about it on Wikipedia][t].

[t] https://en.wikipedia.org/wiki/Type%E2%80%93token_distinction
-}
type alias Syllabary = List Type






{-| Syllabaries can be represented as a string by listing tokens together on a
line to form a group of types. The groups are separated by whitespace.

Example with Latin and Greek tokens:

    AaΑα
    BbΒβ

The type group can be named by starting the group with a name enclosed in
angle brackets. 

Example:

    〈Latin A〉Aa
    〈Latin B〉Bb

The first token is used as representative of the whole group. When there
is no name, the first token also serves as name.
 -}
leftBracket = '〈'
rightBracket = '〉'


{-| When reading a Syllabary from a String, also allow usage of basic angle
brackets when reading because the other brackets cannot be typed on a
standard keyboard layout.
-}
leftBrackets = Set.fromList [leftBracket, '<']
rightBrackets = Set.fromList [rightBracket, '>']


{-|
Types are only allowed in one group and are dropped from subsequent
groups if duplicate tokens show up.
-}
fromString : String -> Syllabary
fromString =
    let
        -- This is a cheap parser implementation that either appends to the
        -- list of tokens or switches to appending to the name when it
        -- encounters an opening bracket. It doesn't fail on unmatched brackets.
        --
        -- Note how the string is read from the back because appending
        -- to the front of a list is easier. Sorry for the hack.
        readChar c state =
            if Set.member c leftBrackets then
                { state | inBrackets = False }
            else
                if state.inBrackets then
                    { state | name = c :: state.name }
                else
                    if Set.member c rightBrackets then
                        { state | inBrackets = True }
                    else
                        if not (Set.member c state.seen) then
                            { state
                            | tokens = c :: state.tokens
                            , seen = Set.insert c state.seen
                            }
                        else
                            state
        
        parse = String.foldr readChar { inBrackets = False
                                      , tokens = []
                                      , name = []
                                      , seen = Set.empty
                                      } 
        
        toTypeGroup line =
            let
                { tokens, name } = parse line
            in
            case (tokens, name) of
                (t :: _, []) -> 
                    -- When the group doesn't have a name, use the first token
                    -- as name.
                    Just 
                        { name = String.fromChar t
                        , representative = t
                        , tokens = tokens
                        }

                (t :: _, _) ->
                    Just 
                        { name = String.fromList (name)
                        , representative = t
                        , tokens =  tokens
                        }
    
                _ -> 
                    -- When there are no indexed tokens on that line, ignore it.
                    Nothing

    in
    String.lines >> List.filterMap toTypeGroup


{-|
Filter a syllabary to only include accepted tokens.
Groups with no indexed tokens are dropped.

Example:

    indexed = \t -> Set.member t (Set.fromList ["A", "a", "B", "b"])
    filter indexed (fromString "Aa \nBb\nCc")

The resulting syllabary is without the "C" type.
Note how the stray space character will be dropped because it's not an
indexed token.
-}
filter : (Token -> Bool) -> Syllabary -> Syllabary
filter accept =
    let
        filterType t =
            let
                filteredTokens = List.filter accept t.tokens
                rep = if accept t.representative 
                        then Just t.representative
                        else List.head filteredTokens
            in
                case (filteredTokens, rep) of
                    ([], _) -> 
                        Nothing

                    (ts, Just r) ->
                        Just { t | tokens = ts, representative = r }

                    _ ->
                        Nothing

    in
    List.filterMap filterType


allTokens : Syllabary -> Set Token
allTokens syllabary =
    let
        addTokens type_ ts =
            Set.union ts (Set.fromList type_.tokens)
    in
    List.foldl addTokens Set.empty syllabary


{-| When searching the corpus (and optionally when displaying it) we want to treat all
characters in an letter group as the same character. This function builds a
dictionary that maps all alternate versions of a type to the main type.

This function maps all types to the representative type in the syllabary.
Other characters not in the syllabary are left as-is.
-}
normalize : Syllabary -> String -> String
normalize syllabary = 
    let
        ins group dict =
            List.foldl (insLetter group.representative) dict group.tokens

        insLetter main ext =
            Dict.insert ext main

        normalization =
            List.foldl ins Dict.empty syllabary

        repl letter =
            Maybe.withDefault letter (Dict.get letter normalization)
    in
    String.map repl
