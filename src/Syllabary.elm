module Syllabary exposing (Syllabary, Type, fromString, filter, allTokens, normalize)

import Dict exposing (Dict)
import List
import Regex
import Script exposing (..)
import Specialchars exposing (..)
import Set exposing (Set)
import String
import Token exposing (..)
import WritingDirections exposing (..)

{-| A **Syllabary** is an ordered list of **Types**.

We call this data structure a "syllabary". For some scripts
"alphabetary" would fit better.

**Definition:** Linguists distinguish between **tokens** and **types**.
For example, in the name "Barbara" three **types** are used (B, A, and R)
but there are seven **tokens** (Bbaaarr). In the context of syllabaries,
**token** means a letter variant that got its own rendering. In this usage,
ａ and 𝖆 are not the same **token** in Unicode. But they may be taken to be
the same **type** when searching. A **type** means a collection of
**tokens** that are assumed to mean the same thing. [More about types on
Wikipedia][t].
 
[t] https://en.wikipedia.org/wiki/Type%E2%80%93token_distinction
-}
type alias Syllabary = List Type


{-| Each **Type** has a display **name** and a **Token** that is the
**representative** for the **Type**. **tokens** is a list of **Tokens**
that are in this **Type**.

Undeciphered scripts are catalogued with many letter variants because
it is unclear which letter variants mean the same thing. Example: Assuming you
don't know about the Latin alphabet, how would you know whether the letters
ａ, 𝐚, 𝑎, 𝒂, 𝒶, 𝓪, 𝔞, 𝕒, 𝖆, ⓐ, á, à, ạ, and å mean something different or
are merely stylistic differences? If we were searching a text-corpus, we
may want to group them together. But if we don't know the script, it is
hard to know where to draw the line.

In an undeciphered script it is unclear whether a token that doesn't
look exactly the same as another token belongs to the same type (has
the same meaning) or belongs to a different type. For example, the
letters 'd' and 'b' look very similar for somebody not trained
in modern Latin fonts. They couldn't know whether a difference is
stylistic (the token was written differently) or whether
the meaning is different (the token belongs to a different type).
Similarily, they wouldn't know that 'A' and 'a' belong to the
same **type**. And depending on context, we might even want to include Greek
'α' in the type so that searching for 'a' also works in Greek text.

An important part of the decipherment is deciding which tokens belong
to a type, the many variants are grouped into types dynamically and the
grouping can be changed quickly.
-}
type alias Type =
    { name : String, representative : Token, tokens : List Token }


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


{-| Read text representation of a syllabary

We want to make changes to the syllabary a cheap operation, so the
interpretation of which tokens belong to the same type can be changed quickly.
This is why there may be multiple syllabaries per script to choose from. The
syllabary can be edited to try new combinations.

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
Groups with no indexed tokens left are dropped by the filter.

Example:

    indexed = \t -> Set.member t (Set.fromList ["A", "a", "B", "b"])
    filter indexed (fromString "Aa \nBb\nCc")

The resulting syllabary is without the "C" type.
Note how the stray space character will also be dropped because it's not an
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


{-| Extract tokens from a Syllabary.
-}
allTokens : Syllabary -> Set Token
allTokens syllabary =
    let
        addTokens type_ ts =
            Set.union ts (Set.fromList type_.tokens)
    in
    List.foldl addTokens Set.empty syllabary


{-| Normalize text by replacing all tokens found in the Syllabary
with the representative token.

When searching the corpus (and maybe when displaying it) we want to treat all
tokens as the same token. This function builds a dictionary that maps all
alternate versions of a type to the representative type.

Tokens not in the syllabary are left as-is.
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
