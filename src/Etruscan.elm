module Etruscan exposing (etruscan)

import Dict
import String
import List
import Set
import Regex


import WritingDirections exposing (..)
import ScriptDefs exposing (..)
import Specialchars exposing (..)
import Tokens 
import EtruscanTokens

rawTokens = Tokens.toList EtruscanTokens.tokens

ignoreChars = Set.insert fractureMarker guessMarkers
tokens = List.filter (\c -> not (Set.member c ignoreChars)) rawTokens

-- These letters are counted as character positions
indexedTokens = Set.fromList (wildcardChar :: tokens)
indexed char = Set.member char indexedTokens

searchExamples =
    [ ("[]", "Search occurrences of  followed by either  or ")
    , ("(.)\\1", "Look for sign repetitions (geminates) like ")
    , ("([^])\\1", "Look for sign repetitions (geminates) excluding placeholder ")
    , ("(.).\\1", "Sign repetitions with an arbitrary sign in-between ()")
    , ("[]", "Show all occurrences of  and ")
    ]

-- We don't know enough about the language to venture guesses about
-- syllables for the tokens.
syllables = Dict.empty

syllableMap = String.trim """
"""

letterGroupSyllabary =
    { id = "group"
    , name = "By Letter"
    , syllabary = String.trim """













 

























        """
    }

codepointSyllabary =
    { id = "splitting"
    , name = "Codepoint order"
    , syllabary = String.join " " (List.map String.fromChar tokens)
    }

syllabaries : List SyllabaryDef
syllabaries = [ letterGroupSyllabary, codepointSyllabary ]


fragments : List FragmentDef
fragments = [ ]

etruscan : Script
etruscan =
    { id = "etruscan"
    , name = "Etruscan Alphabet"
    , group = "North Italic and Runic Alphabets"
    , headline = "Collection of Sign Variants in Etruscan Inscriptions"
    , title = "Etruricon"
    , font = "NorthItalic"
    , description = """
"""
    , sources = """
    """
    , tokens = tokens
    , seperatorChars = ""
    , indexed = indexed
    , searchExamples = searchExamples
    , syllables = syllables
    , syllableMap = syllableMap
    , syllabaries = syllabaries
    , initialSyllabary = letterGroupSyllabary
    , groups = []
    , fragments = fragments
    , decorations = { headline = ("", "")
                    , title = ("", "")
                    , info = ("", "")
                    , signs = ("", "")
                    , sandbox = ("", "")
                    , settings = ("", "")
                    , grams = ("", "")
                    , search = ("", "")
                    , inscriptions = ("", "")
                    , collapse = ("", "")
                    }
    }
