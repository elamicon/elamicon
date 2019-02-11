module Scripts exposing (..)

import Dict exposing (Dict)
import String
import List
import Set exposing (Set)
import Regex

import AstralString

import WritingDirections exposing (..)
import ScriptDefs exposing (..)

import Elam as Elam
import Cypro as Cypro

scripts : List Script
scripts = [ Elam.elam ]

initialScript = Elam.elam


-- Digest the mapping from letters to "spoken sound" into a dictionary
sylDict : String -> Dict.Dict String String
sylDict strMap =
    let
        lines = String.lines strMap
        addRepl : String -> String -> (Dict.Dict String String) -> (Dict.Dict String String)
        addRepl target source state =
            Dict.insert source target state
        addLine line state =
            let
                sylls = String.words line
                target = Maybe.withDefault "" (List.head sylls)
                sources = List.concat <| List.map AstralString.toList (Maybe.withDefault [] (List.tail sylls))
            in
                if List.isEmpty sylls
                then state
                else List.foldr
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
        map = sylDict strMap
        replacer char = Maybe.withDefault char (Dict.get char map)
    in AstralString.map replacer




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
syllabaryList : String -> List (String, List String)
syllabaryList syllabary =
    let
        letterGroup letterString =
            case (AstralString.toList letterString) of
                main :: ext -> (main, ext)
                _ -> ("?", []) -- should not be reachable?
    in
        List.map letterGroup (String.words syllabary)

-- Sanitize the syllabary string to include all tokens but no duplicates
dedupe : List Token -> (Token -> Bool) -> String -> (String, String)
dedupe tokens indexed syllabary =
    let
        dedup letter (seen, dedupSyllabary) =
            if Set.member letter seen
            then
                (seen, dedupSyllabary)
            else
                if indexed letter
                then
                    (Set.insert letter seen, dedupSyllabary ++ letter)
                else
                    (seen, dedupSyllabary ++ letter)

        (presentLetters, dedupedSyllabary) = List.foldl dedup (Set.empty, "") (AstralString.toList syllabary)
        missingLetters = Set.diff (Set.fromList tokens) presentLetters
    in
        (dedupedSyllabary, String.join " " (Set.toList missingLetters))


-- When searching the corpus (and optionally when displaying it) we want to treat all
-- characters in an letter group as the same character. This function builds a
-- dictionary that maps all alternate versions of a letter to the main letter.
normalization : List Token -> String -> Dict.Dict String String
normalization tokens syllabary =
    let allLetters = Set.fromList tokens
        ins group dict =
            case (AstralString.toList group) of
                main :: extras -> List.foldl (insLetter main) (Dict.insert main main dict) extras
                _ -> dict
        insLetter main ext dict = Dict.insert ext main dict
    in List.foldl ins Dict.empty (String.words syllabary)


normalizer: Dict.Dict String String -> String -> String
normalizer normalization =
    let
        repl letter = Maybe.withDefault letter (Dict.get letter normalization)
    in AstralString.map repl
