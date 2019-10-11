module Raetic exposing (raetic)

import Dict
import String
import List
import Set
import Regex


import WritingDirections exposing (..)
import ScriptDefs exposing (..)
import Specialchars exposing (..)
import Tokens 

rawTokens = Tokens.toList <| String.trim """

"""
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
    , syllabary = """





























"""
    }


codepointSyllabary =
    { id = "splitting"
    , name = "Codepoint order"
    , syllabary = String.join " " (List.map String.fromChar tokens)
    }

syllabaries : List SyllabaryDef
syllabaries = [ letterGroupSyllabary, codepointSyllabary ]


-- We grouped the fragments according to where they were found
-- Recorded means that there is a sound archaelogical paper trail
groups : List GroupDef
groups = List.map (\f -> { short = f, name = f, recorded = True}) <| Set.toList (Set.fromList (List.map .group fragments))

fragments : List FragmentDef
fragments = [ ]

raetic : Script
raetic =
    { id = "raetic"
    , name = "Raetic Alphabet"
    , group = "North Italic and Runic Alphabets"
    , headline = "Collection of Sign Variants in Raetic Inscriptions"
    , title = "Raeticon"
    , font = "NorthItalic"
    , description = """
Work in progress. Check back soon!
"""
    , sources = """
This sub-corpus includes, with minor changes, all the sign variants ocurring in [Thesaurus Inscriptionum Raeticarum](https://www.univie.ac.at/raetica/wiki/Main_Page), which on its part collects the letter forms of the Sondrio Alphabet, Magré Alphabet, Sanzeno Alphabet and others. We are grateful to the authors of the TIR for meticulously collecting the Raetic inscriptions.
    """
    , tokens = tokens
    , seperatorChars = ""
    , indexed = indexed
    , searchExamples = searchExamples
    , syllables = syllables
    , syllableMap = syllableMap
    , syllabaries = syllabaries
    , initialSyllabary = letterGroupSyllabary
    , groups = groups
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
