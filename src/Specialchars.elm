module Specialchars exposing (..)

import Set
import Dict
import String
import List
import Tokens
import WritingDirections exposing (..)
import ScriptDefs exposing (..)

-- Characters that are hard to read on the originals are marked with "guessmarkers".
-- Guessmarkers are zero-width and overlap the previous charachter. There are two
-- markers because there are two writing directions.
guessMarkerL = ''
guessMarkerR = ''
guessMarkers = Set.fromList [ guessMarkerL,  guessMarkerR ]

-- Unreadable signs are represented by this special character.
wildcardChar = ''

-- To mark places where we assume the writing continues but is missing, we use
-- the fracture mark.
fractureMarker = ''

-- List of "special" characters
--
-- Most of the artifacts did not make it through time in mint condition. The
-- "special" characters can be used to mark glyphs that are unreadable or
-- are guesses.
type alias SpecialCharDef =
    { displayChar : String, char : Char, description : String }

specialchars : List SpecialCharDef
specialchars =
    [ { displayChar = String.fromChar wildcardChar
      , char = wildcardChar
      , description = "Wildcard for unreadable signs"
      }
    , { displayChar = String.fromList [ wildcardChar, guessMarkerL ]
      , char = guessMarkerL
      , description = "Marks signs that are hard to read"
      }
    , { displayChar = String.fromChar fractureMarker
      , char = fractureMarker
      , description = "Marks a fracture point (line is assumed to be incomplete)"
      }
    ]

-- Turn all guessmarkers in the writing direction so they don't overlap on
-- the wrong character
guessMarkDir dir =
    case dir of
        LTR -> Tokens.replace guessMarkerR guessMarkerL
        _ -> Tokens.replace guessMarkerL guessMarkerR