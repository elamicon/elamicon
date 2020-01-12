module Runic exposing (runic)

import Dict
import String
import List
import Set
import Regex


import WritingDirections exposing (..)
import Script exposing (..)
import Specialchars exposing (..)
import Token 
import Generated.Runic

rawTokens = Token.fromNamed Generated.Runic.tokens

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

syllabaries : List SyllabaryDef
syllabaries = 
    [ { id = "typegroups"
      , name = "Typegroups"
      , syllabary = Generated.Runic.syllabary
      }
    , { id = "codepoints"
      , name = "Codepoint order"
      , syllabary = String.join "\n" (List.map String.fromChar tokens)
      }
    ]
    



fragments : List FragmentDef
fragments = [ ]

runic : Script
runic =
    { id = "runic"
    , name = "Runes (Elder Futhark)"
    , group = "North Italic and Runic Alphabets"
    , headline = "Collection of Sign Variants in the Elder Futhark"
    , title = "Runicon"
    , font = "NorthItalic"
    , description = """
#### Introduction
All the sign variants of the Runes of the oldest period (150 – 700 A.D) are depicted according to Odenstedt 1990.

#### Terminology used for labelling the sign variants
**Writing direction:** sin = sinistroverse; dex = dextroverse; sin/dex = used in this exact shape (i.e. without mirroring the sign) in both writing directions.
**Sub-numeration of the signs:** We have labelled the sign variants with sub-numbers according to the frequency of occurrence, i.e.: Run A₁ is the most frequent Elder Futhark Rune with the sound value A, Run A₂ is the second most frequent Elder Futhark Rune with the sound value A etc. (There are exceptions from this basic rule, due to the iterative compilation of the sub-corpora.)
"""
    , sources = """
#### Main Source
Odenstedt, Bengt (1990): On the Origin and Early History of the Runic Script: Typology and Graphic Variation in the Older Futhark. Acta Academiae Regiae Gustavi Adolphi 59. Uppsala.

#### Further Sources:
None
"""
    , tokens = Generated.Runic.tokens
    , seperatorChars = ""
    , indexed = indexed
    , searchExamples = searchExamples
    , syllables = syllables
    , syllableMap = syllableMap
    , syllabaries = syllabaries
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
