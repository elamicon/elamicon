module State exposing (..)

import Url
import Syllabary
import Set
import Script
import Browser
import Browser.Navigation
import WritingDirections

type alias Pos =
    ( String, Int, Int )

type alias Model =
    { script : Script.Script
    , dir : Maybe WritingDirections.Dir
    , fixedBreak : Bool
    , selected : Maybe Pos
    , syllabaryId : Maybe String
    , syllabary : Syllabary.Syllabary
    , syllabaryString : String
    , missingSyllabaryChars : String
    , syllableMap : String
    , syllabizer : String -> String
    , syllabize : Bool
    , normalizer : String -> String
    , normalize : Bool
    , removeChars : String
    , sandbox : String
    , search : String
    , searchBidirectional : Bool
    , linesplitSearch : Bool
    , selectedGroups : Set.Set String
    , collapsed : Set.Set String
    , showAllResults : Bool
    , url : Url.Url
    , key : Browser.Navigation.Key
    }

type Msg
    = Select ( String, Int, Int )
    | SetScript Script.Script
    | SetBreaking Bool
    | SetDir (Maybe WritingDirections.Dir)
    | SetNormalize Bool
    | SetSandbox String
    | ChooseSyllabary String
    | SetSyllabary String
    | SetSyllableMap String
    | SetSyllabize Bool
    | SetRemoveChars String
    | AddChar String
    | SetSearch String
    | ShowAllResults
    | BidirectionalSearch Bool
    | LinesplitSearch Bool
    | SelectGroup String Bool
    | Toggle String
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | NoOp
