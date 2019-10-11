module ScriptDefs exposing (Decoration, FragmentDef, GroupDef, Script, SpecialCharDef, SyllabaryDef, Token, Type)

import Dict exposing (Dict)
import Regex
import Set exposing (Set)
import WritingDirections exposing (..)

type alias Token =
    Char

type alias SpecialCharDef =
    { displayChar : String, char : Char, description : String }


type alias SyllabaryDef =
    { id : String, name : String, syllabary : String }


-- Details about a group
--   short: ID of the group
--   name: Descriptive name for the group
--   recorded: whether there is an archaelogical paper trail fro
--             fragments in this group.
type alias GroupDef =
    { short : String, name : String, recorded : Bool }


-- Fragement of the text body
--  id: catalogue ID, unique within the corpus.
--  group: group ID.
--  dir: Writing direction. This may be a guess.
--  text: Text body. The character order is always in the expected
--        read order. So an inscription that should look like "123" when
--        displayed but is read from the right must be written "321" in the
--        corpus.
--  plate: Optional name of a file with details
type alias FragmentDef =
    { id : String, group : String, dir : Dir, text : String, plate : Maybe String }


type alias Decoration =
    ( String, String )


type alias Type =
    Set Token


type alias Script =
    { id : String
    , name : String
    , group : String
    , headline : String
    , title : String
    , font : String
    , description : String
    , sources : String
    , tokens : List Token
    , seperatorChars : String
    , indexed : Token -> Bool
    , searchExamples : List ( String, String )
    , syllables : Dict Token (List String)
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
