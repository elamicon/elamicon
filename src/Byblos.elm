module Byblos exposing (byblos)

import Dict
import String
import List
import Set

import AstralString

import WritingDirections exposing (..)
import ScriptDefs exposing (..)

-- Glyphs courtesy Douros
rawTokens = AstralString.toList <| String.trim """

"""

specialChars = []

ignoreChars = Set.fromList <| List.map .char specialChars
tokens = List.filter (\c -> not (Set.member c ignoreChars)) rawTokens
tokenSet = Set.fromList tokens

-- These letters are counted as character positions
-- Letter 'X' is used in places where the character has not been mapped yet.
indexedTokens = Set.fromList ([ "X" ] ++ tokens)
indexed char = Set.member char indexedTokens

syllables : Dict.Dict String (List String)
syllables = Dict.fromList []

syllableMap = String.trim """
"""


initialSyllabary : SyllabaryDef
initialSyllabary =
    { id = "search"
    , name = "Ordered and grouped by looks"
    , syllabary = String.trim
        """
   
           
     
           
          
          
        
         
              
     
      
     
   
      
              
      
        
      
  
 
  
  
        """
    }

syllabaries : List SyllabaryDef
syllabaries =
    [ initialSyllabary
    ,   { id = "splitting"
        , name = "Codepoint order"
        , syllabary = String.join " " tokens
        }
    ]


-- We grouped the fragments according to where they were found
-- Recorded means that there is a sound archaelogical paper trail
groups : List GroupDef
groups = List.map (\f -> { short = f, name = f, recorded = True}) <| Set.toList (Set.fromList (List.map .group fragments))

-- Tags:
--
-- lisible: inscription is reasonably readable from imagery available to us
-- posdet: there is evidence to determine top and bottom
-- posdet-pal: there is paleographic evidence to determine top and bottom
-- rev: revised signs from the Douros corpus

-- Signs:
-- _ preceding a sign signifies difficult to read
-- = preceding a sign signifies hardly readable
-- % signifies a fracture


tagsToGroup { id, tags, dir, plate, text } = { id = id, group = Maybe.withDefault "NOGROUP" (List.head tags), dir = dir, plate = plate, text = String.trim text }

-- Using Douros 2014 as base
fragments : List FragmentDef
fragments = List.map tagsToGroup
    [
    ]

byblos : Script
byblos =
    { id = "byblos"
    , name = "Byblos"
    , headline = "Online Corpus of Byblos Inscriptions OCBI"
    , title = "Byblicon"
    , description = """
Work in progress. Check back soon!
"""
    , sources = ""
    , tokens = tokens
    , specialChars = specialChars
    , guessMarkers = ""
    , indexed = indexed
    , syllables = syllables
    , syllableMap = syllableMap
    , syllabaries = syllabaries
    , initialSyllabary = initialSyllabary
    , groups = groups
    , fragments = fragments
    , decorations = { headline = ("", "")
                    , title = ("", "")
                    , info = ("", "")
                    , signs = ("", "")
                    , sandbox = ("", "")
                    , settings = ("", "")
                    , grams = ("", "")
                    , search = ("", "")
                    , inscriptions = ("", "")
                    , collapse = ("", "")
                    }
    }
