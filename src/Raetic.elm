module Raetic exposing (raetic)

import Dict
import String
import List
import Set
import Regex


import WritingDirections exposing (..)
import Script exposing (..)
import Specialchars exposing (..)
import Token 
import Generated.Raetic
import Imported.RaeticInscriptions

rawTokens = Token.fromNamed Generated.Raetic.tokens

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
      , syllabary = Generated.Raetic.syllabary
      }
    , { id = "codepoints"
      , name = "Codepoint order"
      , syllabary = String.join "\n" (List.map String.fromChar tokens)
      }
    ]


-- We grouped the fragments according to where they were found
-- Recorded means that there is a sound archaelogical paper trail
groups : List GroupDef
groups = List.map (\f -> { short = f, name = f, recorded = True}) <| Set.toList (Set.fromList (List.map .group fragments))

fragments : List FragmentDef
fragments = Imported.RaeticInscriptions.inscriptions

raetic : Script
raetic =
    { id = "raetic"
    , name = "Raetic Alphabet"
    , group = "North Italic and Runic Alphabets"
    , headline = "Collection of Sign Variants in Raetic Inscriptions"
    , title = "Raeticon"
    , font = "NorthItalic"
    , description = """
#### Introduction

This sub-corpus includes, with minor changes, all the sign variants ocurring in [Thesaurus Inscriptionum Raeticarum](https://www.univie.ac.at/raetica/wiki/Main_Page), which on its part collects the letter forms of the Sondrio Alphabet, Magré Alphabet, Sanzeno Alphabet and others. We are grateful to the authors of the TIR for meticulously collecting the Raetic inscriptions and for making this great resource available to the public.

Raetic denominates, as in TIR, all North Italic inscriptions that are neither written in the Este alphabet (Venetic), nor in the Lugano alphabet (Lepontic), nor in the Sondrio / Val Camonica alphabet (Camunic), nor are clearly Etruscan. It contains all inscriptions hitherto known, including those of doubtful assignment to the script in question. Geographical and/or palaeographical division into sub-groups such as "Sondrio Alphabet", "Magré Alphabet" etc., which are claimed in literature, are to be taken a grain of salt given evidence available today.


#### Terminology used for labelling the sign variants

**Writing direction:** sin = sinistroverse; dex = dextroverse; sin/dex = used in this exact shape (i.e. without mirroring the sign) in both writing directions.
**Sub-numeration of the signs:** For Raetic and Lepontic, the sub-numeration is taken from the respective main sources. Supplementary sign variants added by us and not present in the main source have been labelled with further sub-numbers.
We have labelled the sign variants with sub-numbers according to the frequency of occurrence, i.e.: Raet A₁ is the most frequent Raetic sign variant with the sound value A, Raet A₂ is the second most frequent Raetic sign variant with the sound value A etc. (There are exceptions from this basic rule, due to the iterative compilation of the sub-corpora.)


#### Sigla

Inscription sigla (such as RN-1) are taken from, and kept in sync with, TIR. In
addition, the inscriptions are grouped into what TIR terms "alphabets". They are
shown as superscript to the sigla, example: <sup>MAG</sup>AK-1.1. The superscripts
used are:

* **MAG** for Magrè
* **SAN** for Sanzeno
* **VEN** for Venetic
* **UNK** for unknown, which comprises most small inscriptions


"""
    , sources = """
#### Main source
[Thesaurus Inscriptionum Raeticarum](https://www.univie.ac.at/raetica/wiki/Main_Page)

#### Further sources
None.
    """
    , tokens = Generated.Raetic.tokens
    , seperatorChars = ""
    , indexed = indexed
    , searchExamples = searchExamples
    , syllables = syllables
    , syllableMap = syllableMap
    , syllabaries = syllabaries
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
