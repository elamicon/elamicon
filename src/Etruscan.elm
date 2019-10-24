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
import Generated.Etruscan

rawTokens = Tokens.toList Generated.Etruscan.tokens

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
A
C
E
V
Z
H

I
K
L
M
N
P
Ś
Q
R
S
T
U
X
F









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
#### Introduction
The sign corpus of Etruscicon contains all sign variants from inscriptions certainly or possibly belonging to the Etruscan, Venetic or Lemnotic scripts. Signs that occur only in Venetic inscriptions are labelled "EtrVen", signs that occur only on Lemnos are labeled "EtrLem". Signs that occur only or also in Etruscan are labeled "Etr".
 
If no "Further source" reference (see below) is indicated in the sign name, the sign variant is attested in the main source.

#### Terminology used for labelling the sign variants
**Writing direction:** sin = sinistroverse; dex = dextroverse; sin/dex = used in this exact shape (i.e. without mirroring the sign) in both writing directions.
**Sub-numeration of the signs:** We have labelled the sign variants with sub-numbers according to the frequency of occurrence, i.e.: Etr A₁ is the most frequent Etruscan sign variant with the sound value A, Etr A₂ is the second most frequent Etruscan sign variant with the sound value A etc. (There are exceptions from this basic rule, due to the iterative compilation of the sub-corpora.)
"""
    , sources = """
#### Main Source
**Morandi, A. (2004):** Epigrafia e lingua dei Celti d’Italia. A cura di Paola Piana Agostinetti. Popoli e civiltà dell’Italia antica 12, 2 vol.: II. Roma 2004. Table at p. 476.

#### Further Sources
- **Bonfante, Giuliano & Bonfante, Larissa (2002):** The Etruscan Language. Manchester: Manchester University Press.
- **Buffa, Mario (1935):** Nuova Raccolta di Iscrizioni Etrusche. Firenze: Rinascimento del Libro.
- **CIE: Corpus Inscriptionum Etruscarum** academiis litterarum borussica et saxonica (1893-2017)
- **De Simone, Carlo (1996):** I Tirreni a Lemnos: evidenza linguistica e tradizioni storiche. Firenze: Olschki.
- **Lejeune, Michel (1974):** Manuel de la langue vénète. Heidelberg: C. Winter.
- **Prosdocimi, Aldo L. & Scardigli, Piergiuseppe (1976):** "Negau", in: Vittore Pisani, Ciro Santoro (Eds), Italia linguistica nuova ed antica. Studi linguistici in memoria di Oronzo Parlangèli, Galatina. S. 179–229.
- **Rix, Helmut (1998):** Rätisch und Etruskisch. Innsbruck: Institut für Sprachwissenschaft der Universität.
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
