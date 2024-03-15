module DeirAlla exposing (deiralla)

import Dict
import String
import List
import Set
import Regex


import WritingDirections exposing (..)
import Script exposing (..)
import Specialchars exposing (..)
import Token
import Generated.DeirAlla

rawTokens = Token.fromNamed Generated.DeirAlla.tokens

ignoreChars = Set.insert fractureMarker guessMarkers
tokens = List.filter (\c -> not (Set.member c ignoreChars)) rawTokens

-- These letters are counted as character positions
indexedTokens = Set.fromList (wildcardChar :: tokens)
indexed char = Set.member char indexedTokens

searchExamples =
    [
    ]

syllables = Dict.empty

syllableMap = String.trim """
"""

syllabaries : List SyllabaryDef
syllabaries =
    [ { id = "typegroups"
      , name = "Typegroups"
      , syllabary = Generated.DeirAlla.syllabary
      }
    , { id = "codepoints"
      , name = "Codepoint order"
      , syllabary = String.join "\n" (List.map String.fromChar tokens)
      }
    ]


-- Recorded means that there is a sound archaelogical paper trail
groups : List GroupDef
groups = List.map (\f -> { short = f, name = f, recorded = True}) <| Set.toList (Set.fromList (List.map .group fragments))

fragments : List FragmentDef
fragments = []

deiralla : Script
deiralla =
    { id = "deiralla"
    , name = "Deir Alla"
    , group = "Ancient Near Eastern Scripts"
    , headline = "Deir Alla Alphabet"
    , title = "Deir Alla"
    , description = ""
    , sources = ""
    , tokens = Generated.DeirAlla.tokens
    , seperatorChars = ""
    , indexed = indexed
    , searchBidirectionalPreset = False
    , searchExamples = searchExamples
    , syllables = syllables
    , syllableMap = syllableMap
    , syllabaries = syllabaries
    , groups = groups
    , fragments = fragments
    , inscriptionOverviewLink = Nothing
    , decorations = { headline = ("", "")
                    , title = ("", "")
                    , info = ("", "")
                    , signs = ("", "")
                    , sandbox = ("", "")
                    , settings = ("", "")
                    , grams = ("", "")
                    , search = ("", "")
                    , inscriptions = ("", "")
                    , collapse = ("", "")
                    }
    }
