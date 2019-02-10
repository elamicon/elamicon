module ScriptDefs exposing (..)

import Dict exposing (Dict)
import Set exposing (Set)
import Regex

import WritingDirections exposing (..)

type alias Token = String
type alias SpecialCharDef = { displayChar : String, char : String, description : String }
type alias SyllabaryDef = { id : String, name : String, syllabary : String }
type alias GroupDef = { short : String, name : String, recorded : Bool }
type alias FragmentDef = { id : String, group : String, dir : Dir, text : String }

type alias Type = Set Token
type alias Script =
    { id : String
    , name : String
    , description: String
    , tokens : List Token
    , specialChars : List SpecialCharDef
    , guessMarkers : String
    , indexed : Token -> Bool
    , syllables : Dict String (List String)
    , syllableMap : String
    , syllabaries : List SyllabaryDef
    , initialSyllabary : SyllabaryDef
    , groups : List GroupDef
    , fragments : List FragmentDef
    }
