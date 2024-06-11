module State exposing (..)

import Url
import Syllabary
import Set
import Script
import Scriptlist
import Browser
import Browser.Navigation
import WritingDirections
import Url.Parser exposing (fragment)

type alias Pos =
    ( String, Int, Int )

type alias Model =
    { script : Script.Script
    , dir : Maybe WritingDirections.Dir
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
        dirStr = Maybe.map WritingDirections.dirStr model.dir

        groups =
            if model.selectedGroups == Set.fromList (List.map .id model.script.groups) then
                Nothing
            else
                Just (model.selectedGroups |> Set.toList |> String.join ",")
    in
        [ Just ("script=" ++ model.script.id)
        , Maybe.map (\d -> "dir=" ++ d) dirStr
        , Maybe.map (\g -> "groups=" ++ g) groups
        , if model.phoneticize then Just "phoneticize" else Nothing
        ]
        |> List.filterMap identity
        |> String.join "&"

type UrlParam
    = KeyValueParam String String
    | KeyParam String

updateStateFromUrlFragment : String -> Model -> Model
updateStateFromUrlFragment fragment model =
    let
        fragmentParams =
            fragment
                |> String.split "&"
                |> List.map (String.split "=")
                |> List.filterMap (\parts ->
                    case parts of
                        [ key, value ] ->
                            Just (KeyValueParam key value)
                        [ key ] ->
                            Just (KeyParam key)
                        _ ->
                            Nothing
                )
        updateModelWithParam param m =
            case param of
                KeyValueParam "script" value ->
                    case Scriptlist.fromName value of
                        Just script ->
                            { m | script = script }
                        Nothing ->
                            m
                KeyValueParam "dir" value ->
                    case WritingDirections.dirFromString value of
                        Just dir ->
                            { m | dir = Just dir }
                        Nothing ->
                            m
                KeyValueParam "groups" value ->
                    { m | selectedGroups = value |> String.split "," |> Set.fromList }
                KeyParam "phoneticize" ->
                    { m | phoneticize = True }
                _ ->
                    m
    in
    List.foldl updateModelWithParam model fragmentParams
