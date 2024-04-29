module State exposing (..)

import Url
import Syllabary
import Set
import Script
import Scripts
import Browser
import Browser.Navigation
import WritingDirections
import Url.Parser exposing (fragment)

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
    , phoneticize : Bool
    , normalizer : String -> String
    , normalize : Bool
    , removeChars : String
    , sandbox : String
    , sandboxReplace : Bool
    , sandboxReplacement : String
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
    | SetSandboxReplace Bool
    | SetSandboxReplacement String
    | ChooseSyllabary String
    | SetSyllabary String
    | SetSyllableMap String
    | SetPhoneticize Bool
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

urlFragmentFromState : Model -> String
urlFragmentFromState model =
    let
        dirStr =
            case model.dir of
                Nothing ->
                    Nothing
                Just dir ->
                    Just (dir |> WritingDirections.dirStr)

        groups =
            if model.selectedGroups == Set.fromList (List.map .id model.script.groups) then
                Nothing
            else
                Just (model.selectedGroups |> Set.toList |> String.join ",")
    in
        [ Maybe.map (\s -> "script=" ++ s) (Just model.script.id)
        , Maybe.map (\d -> "dir=" ++ d) dirStr
        , Maybe.map (\g -> "groups=" ++ g) groups
        ]
        |> List.filterMap identity
        |> String.join "&"

updateStateFromUrlFragment : String -> Model -> Model
updateStateFromUrlFragment fragment model =
    let
        fragmentParams : List (String, String)
        fragmentParams =
            fragment
                |> String.split "&"
                |> List.map (String.split "=")
                |> List.filterMap (\parts ->
                    case parts of
                        [ key, value ] ->
                            Just (key, value)
                        _ ->
                            Nothing
                )
        updateModelWithParam (key, value) m =
            case key of
                "script" ->
                    case Scripts.fromName value of
                        Just script ->
                            { m | script = script }
                        Nothing ->
                            m
                "dir" ->
                    case WritingDirections.dirFromString value of
                        Just dir ->
                            { m | dir = Just dir }
                        Nothing ->
                            m
                "groups" ->
                    { m | selectedGroups = value |> String.split "," |> Set.fromList }
                _ ->
                    m
    in
    List.foldl updateModelWithParam model fragmentParams
