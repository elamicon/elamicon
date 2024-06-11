module Script exposing (Decoration, FragmentDef, GroupDef, Script, SpecialCharDef, SyllabaryDef, emptySyllabary, Type)

import Dict exposing (Dict)
import Set exposing (Set)
import WritingDirections exposing (..)
import Token exposing (..)


{-| A special character used by the script

**displayChar** is the string used to display the character on its own.
**char** is the codepoint for this special char used by the text corpus.
**description** is a string that explains usage.
-}
type alias SpecialCharDef =
    { displayChar : String, char : Char, description : String }


{-| A syllabary version for the script.

**id** is the internal identifier for this syllabary version. Example "search".
**name** is a display name such as "broad lumping for searching".
**syllabary** is the syllabary in string-format.
-}
type alias SyllabaryDef =
    { id : String, name : String, syllabary : String }


emptySyllabary = { id = "empty", name = "Empty", syllabary = "" }


-- Details about a group
--   id: ID of the group
--   name: Descriptive name for the group
--   extra: extra information about the group
type alias GroupDef =
    { id : String
    , name : String
    , extra : String }


-- Fragement of the text body
--  id: catalogue ID, unique within the corpus.
--  group: group ID.
--  source: where the fragment comes from
--  dir: Writing direction. This may be a guess.
--  text: Text body. The character order is always in the expected
--        read order. So an inscription that should look like "123" when
--        displayed but is read from the right must be written "321" in the
--        corpus.
--  plate: Optional name of a file with details
type alias FragmentDef =
    { id : String
    , group : String
    , source : String
    , dir : Dir
    , text : String
    , plate : Maybe String
    , link : Maybe String }


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
    , description : String
    , sources : String
    , tokens : List NamedToken
    , seperatorChars : String
    , indexed : Token -> Bool
    , searchExamples : List ( String, String )
    , searchBidirectionalPreset : Bool
    , syllables : Dict Token String
    , syllableMap : String
    , syllabaries : List SyllabaryDef
    , groups : List GroupDef
    , fragments : List FragmentDef
    , inscriptionOverviewLink : Maybe String
    , decorations :
        { headline : Decoration
        , title : Decoration
        , info : Decoration
        , signs : Decoration
        , sandbox : Decoration
        , syllabary : Decoration
        , grams : Decoration
        , search : Decoration
        , inscriptions : Decoration
        , collapse : Decoration
        }
    }
