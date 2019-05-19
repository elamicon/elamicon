module ScriptDefs exposing (Decoration, FragmentDef, GroupDef, Script, SpecialCharDef, SyllabaryDef, Token, Type)

import Dict exposing (Dict)
import Regex
import Set exposing (Set)
import WritingDirections exposing (..)


type alias Token =
    String


type alias SpecialCharDef =
    { displayChar : String, char : String, description : String }


type alias SyllabaryDef =
    { id : String, name : String, syllabary : String }


type alias GroupDef =
    { short : String, name : String, recorded : Bool }


type alias FragmentDef =
    { id : String, group : String, dir : Dir, text : String, plate : Maybe String }


type alias Decoration =
    ( String, String )


type alias Type =
    Set Token


type alias Script =
    { id : String
    , name : String
    , headline : String
    , title : String
    , description : String
    , sources : String
    , tokens : List Token
    , seperatorChars : String
    , specialChars : List SpecialCharDef
    , guessMarkers : String
    , guessMarkDir : Dir -> String -> String
    , indexed : Token -> Bool
    , searchExamples : List ( String, String )
    , syllables : Dict String (List String)
    , syllableMap : String
    , syllabaries : List SyllabaryDef
    , initialSyllabary : SyllabaryDef
    , groups : List GroupDef
    , fragments : List FragmentDef
    , decorations :
        { headline : Decoration
        , title : Decoration
        , info : Decoration
        , signs : Decoration
        , sandbox : Decoration
        , settings : Decoration
        , grams : Decoration
        , search : Decoration
        , inscriptions : Decoration
        , collapse : Decoration
        }
    }
