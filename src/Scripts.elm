module Scripts exposing (dedupe, initialScript, normalization, normalizer, scripts, sylDict, syllabaryList, syllabizer)

import Byblos as Byblos
import Elam as Elam
import Raetic as Raetic

import Dict exposing (Dict)
import List
import Regex
import ScriptDefs exposing (..)
import Specialchars exposing (..)
import Set exposing (Set)
import String
import Tokens
import WritingDirections exposing (..)


scripts : List Script
scripts =
    [ Byblos.byblos, Elam.elam, Raetic.raetic ]


initialScript =
    Elam.elam


-- Digest the mapping from letters to "spoken sound" into a dictionary


sylDict : String -> Dict.Dict Token String
sylDict strMap =
    let
        lines =
            String.lines strMap

        addRepl : String -> Char -> Dict.Dict Token String -> Dict.Dict Token String
        addRepl target source state =
            Dict.insert source target state

        addLine line state =
            let
                sylls =
                    String.words line

                target =
                    Maybe.withDefault "" (List.head sylls)

                sources : List Token
                sources =
                    List.concat <| List.map Tokens.toList (Maybe.withDefault [] (List.tail sylls))
            in
            if List.isEmpty sylls then
                state

            else
                List.foldr
                    (addRepl target)
                    state
                    sources
    in
    List.foldl addLine Dict.empty lines



-- Function that replaces letters with their "spoken sound" based on a
-- mapping given as string. Each line defines a mapping from letters to spoken
-- sound. The first word of each line is the spoken sound, separated from
-- the letters that are expected to sound like that.
-- Based on the mapping
--     why Yy
--     oh Oo
-- this function would turn "Y o y" into "why oh why".


syllabizer : String -> String -> String
syllabizer strMap =
    let
        map =
            sylDict strMap

        replacer char =
            Maybe.withDefault (String.fromChar char) (Dict.get char map)
    in
    String.toList >> List.map replacer >> String.concat



-- Syllabary definitions
--
-- The many letter variants are grouped into a syllabary with one letter
-- chosen as representative of the whole group. We want to make changes to
-- the syllabary a cheap operation, so the interpretation of which letters
-- mean the same thing can be changed quickly.
--
-- Letter are separated by whitespaces, letters following another letter without
-- a space are grouped with that letter
-- List of letter groupings made from a syllabary string.


syllabaryList : String -> List ( Token, List Token )
syllabaryList syllabary =
    let
        letterGroup letterString =
            case Tokens.toList letterString of
                main :: ext ->
                    ( main, ext )

                _ ->
                    ( '?', [] )

        -- should not be reachable?
    in
    List.map letterGroup (String.words syllabary)



-- Sanitize the syllabary string to include all tokens but no duplicates


dedupe : List Token -> (Token -> Bool) -> String -> ( String, String )
dedupe tokens indexed syllabary =
    let
        dedup letter ( seen, dedupSyllabary ) =
            if Set.member letter seen then
                ( seen, dedupSyllabary )

            else if indexed letter then
                ( Set.insert letter seen, dedupSyllabary ++ String.fromChar letter )

            else
                ( seen, dedupSyllabary ++ String.fromChar letter )

        ( presentLetters, dedupedSyllabary ) =
            List.foldl dedup ( Set.empty, "" ) (String.toList syllabary)

        missingLetters =
            Set.diff (Set.fromList tokens) presentLetters
    in
    ( dedupedSyllabary, String.join " " (List.map String.fromChar (Set.toList missingLetters)) )



-- When searching the corpus (and optionally when displaying it) we want to treat all
-- characters in an letter group as the same character. This function builds a
-- dictionary that maps all alternate versions of a letter to the main letter.


normalization : List Token -> String -> Dict.Dict Token Token
normalization tokens syllabary =
    let
        allLetters =
            Set.fromList tokens

        ins group dict =
            case String.toList group of
                main :: extras ->
                    List.foldl (insLetter main) (Dict.insert main main dict) extras

                _ ->
                    dict

        insLetter main ext dict =
            Dict.insert ext main dict
    in
    List.foldl ins Dict.empty (String.words syllabary)


normalizer : Dict.Dict Token Token -> String -> String
normalizer normMap =
    let
        repl letter =
            Maybe.withDefault letter (Dict.get letter normMap)
    in
    String.map repl
