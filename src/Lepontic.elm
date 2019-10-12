module Lepontic exposing (lepontic)

import Dict
import String
import List
import Set
import Regex


import WritingDirections exposing (..)
import ScriptDefs exposing (..)
import Specialchars exposing (..)
import Tokens 
import LeponticTokens

rawTokens = Tokens.toList LeponticTokens.tokens

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

codepointSyllabary =
    { id = "splitting"
    , name = "Codepoint order"
    , syllabary = String.join " " (List.map String.fromChar tokens)
    }

syllabaries : List SyllabaryDef
syllabaries = [ codepointSyllabary ]


fragments : List FragmentDef
fragments = [ ]

lepontic : Script
lepontic =
    { id = "lepontic"
    , name = "Lepontic Alphabet"
    , group = "North Italic and Runic Alphabets"
    , headline = "Collection of Sign Variants in Lepontic, Camunic, and Brembonic Inscriptions"
    , title = "Leponticon"
    , font = "NorthItalic"
    , description = """
#### Content
The collection of Lepontic sign variants contains signs from inscriptions which are understood – be it on linguistic or palaeographic grounds – as Lepontic, Cisalpine Gaulish or Camunic, or appear on the rock inscriptions from the sources of the Brembo river. Sign variants that occur only in Camunic have the siglum LepCam, sign variants that occur only in the Brembo inscriptions have LepBrem, all others have Lep.
"""
    , sources = """
#### Main source
[Lexicon Leponticum (LexLep)](https://www.univie.ac.at/lexlep/wiki/Main_Page). Institut für Sprachwissenschaft, Universität Wien.

#### Further Sources
- **Casini, Stefania & Motta, Filippo (2011):** Alcune iscrizioni preromane inedite da Milano. Notizie Archeologiche Bergomensi, 19, 2011, S. 459-469.
- **Casini, Stefania, Motta, F. & Fossati, A. (2014):** Un santuario celtico alle fonti del Brembo? Le iscrizioni in alfabeto di Lugano incise su roccia a Carona (Bergamo), in: Les Celtes et le Nord de l’Italie (Premier et Second Âges du fer). Actes du XXXVIe colloque international de l’AFEAF (Vérone, 17-20 mai 2012), Société archéologique de l’Est, Dijon. S. 103-120.
- **Casini, Stefania; Fossati, Angelo & Motta, Filippo (2014):** Nuove iscrizioni in alfabeto di Lugano sul masso Camisana1 di Carona (Bergamo). Notizie Archeologiche Bergomensi 22, S. 179-203.
- **Maras, Daniele F. (2014):** "Breve storia della scrittura celtica d'Italia: L'area Golasecchiana". Zixu 1, pp. 73-94.
- **Marchesini, Simona & Stifter, David (2018):** "Inscriptions from Italo-Celtic burials in the Seminario Maggiore (Verona)", in: Jacopo Tabolli (ed.), From Invisible to Visible. New Methods and Data for the Archaeology of Infant and Child Burials in Pre-Roman Italy and Beyond [= Studies in Mediterranean Archaeology 149], Nicosia: 2018.
- **Morandi, Alessandro (1998):** "Epigrafia camuna. Osservazioni su alcuni aspetti della documentazione". Antiquité - Oudheid, Revue belge de philologie et d'histoire 76, pp. 99-124.
- **FdN (Alfabetario di Foppe di Nadro) = Tibiletti Bruno, Maria G. (1990):** "Nuove iscrizioni camune". Quaderni Camuni 49/50, pp. 33-171.
- **PC 10 (Alfabetario di Piancogno) = Tibiletti Bruno, Maria G. (1992):** "Gli alfabetari", Quaderni Camuni 60, pp. 309-380. 
    """
    , tokens = tokens
    , seperatorChars = ""
    , indexed = indexed
    , searchExamples = searchExamples
    , syllables = syllables
    , syllableMap = syllableMap
    , syllabaries = syllabaries
    , initialSyllabary = codepointSyllabary
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
