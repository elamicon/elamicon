module Settings exposing (settings)

import Set
import Dict
import Dict.Extra
import Json.Decode
import WritingDirections

import Html exposing (button, div, text, label, small, option, h3)
import Html.Attributes exposing (value, selected, class, title)
import Html.Events exposing (onInput, onClick, on)

import State exposing (..)
import Scripts exposing (scripts)
import Script exposing (Script)
import Html exposing (br)


scriptDecoder : Json.Decode.Decoder Script
scriptDecoder =
    Html.Events.targetValue
        |> Json.Decode.andThen
            (\valStr ->
                case List.head <| List.filter (.id >> (==) valStr) scripts of
                    Just script ->
                        Json.Decode.succeed script

                    Nothing ->
                        Json.Decode.fail ("script " ++ valStr ++ "unknown")
            )


dirDecoder : Json.Decode.Decoder (Maybe WritingDirections.Dir)
dirDecoder =
    Html.Events.targetValue
        |> Json.Decode.andThen
            (\valStr ->
                case valStr of
                    "Original" ->
                        Json.Decode.succeed Nothing

                    "LTR" ->
                        Json.Decode.succeed (Just WritingDirections.LTR)

                    "RTL" ->
                        Json.Decode.succeed (Just WritingDirections.RTL)

                    _ ->
                        Json.Decode.fail ("dir " ++ valStr ++ "unknown")
            )


boolDecoder : Json.Decode.Decoder Bool
boolDecoder =
    Html.Events.targetValue
        |> Json.Decode.andThen
            (\valStr ->
                case valStr of
                    "true" ->
                        Json.Decode.succeed True

                    "false" ->
                        Json.Decode.succeed False

                    _ ->
                        Json.Decode.fail ("dir " ++ valStr ++ "unknown")
            )


settings model =
    let
        groupedScripts : List (String, List Script)
        groupedScripts = Dict.toList (Dict.Extra.groupBy (.group) scripts)
        selectionDropdown =
            div []
                [ label []
                    [ text "Choose script "
                    , scriptSelect
                    ]
                ]
        scriptSelect =
            Html.select
                [ on "change" (Json.Decode.map SetScript scriptDecoder) ]
                (List.concat (List.map scriptOptionGroup groupedScripts))
        scriptOptionGroup (groupName, scripts) =
            (option [Html.Attributes.disabled True] [(text groupName)])
            :: (List.map scriptOption scripts)

        scriptOption script =
            option
                [ value script.id, selected (model.script.id == script.id) ]
                [ text script.name ]
        dirOptAttrs val dir =
            [ value val, selected (dir == model.dir) ]

        breakOptAttrs val break =
            [ value val, selected (break == model.fixedBreak) ]

        boolOptAttrs val sel =
            [ value val, selected sel ]

        settingsOpen =
            not (Set.member "settings" model.collapsed)

        settingsButton =
            button
                [ class "settings-button"
                , onClick (Toggle "settings")
                , title (if settingsOpen then "Close Settings" else "Open Settings")
                ]
                [ text (if settingsOpen then "✕" else "🛠") ]

        settingsBox =
            div [ class "settings-box" ]
                [ h3 [] [ text "Settings" ]
                , selectionDropdown
                ,   div []
                    [ label []
                        [ text "Writing direction "
                        , Html.select [ on "change" (Json.Decode.map SetDir dirDecoder) ]
                            [ option (dirOptAttrs "Original" Nothing) [ text "original ⇔" ]
                            , option (dirOptAttrs "LTR" (Just WritingDirections.LTR)) [ text "everything ⇒ from left ⇒ to right" ]
                            , option (dirOptAttrs "RTL" (Just WritingDirections.RTL)) [ text "everything ⇐ to left ⇐ from right" ]
                            ]
                        ]
                    ]
                , div []
                    [ label []
                        [ text "Line breaks: "
                        , Html.select [ on "change" (Json.Decode.map SetBreaking boolDecoder) ]
                            [ option (breakOptAttrs "true" True) [ text "original" ]
                            , option (breakOptAttrs "false" False) [ text "remove" ]
                            ]
                        ]
                    ]
                , div []
                    [ label []
                        [ text "Sign forms: "
                        , Html.select [ on "change" (Json.Decode.map SetNormalize boolDecoder) ]
                            [ option (boolOptAttrs "false" (not model.normalize)) [ text "according to original inscription" ]
                            , option (boolOptAttrs "true" model.normalize) [ text "normalize per the syllabary" ]
                            ]
                        ]
                    ]
                , div []
                    [ label []
                        [ text "Sign with assumed sound value: "
                        , Html.select [ on "change" (Json.Decode.map SetPhoneticize boolDecoder) ]
                            [ option (boolOptAttrs "false" (not model.phoneticize)) [ text "keep original sign" ]
                            , option (boolOptAttrs "true" model.phoneticize) [ text "replace with sound value" ]
                            ]
                        ]
                    ]
                , div []
                    [ label []
                        ([ text "Remove these signs "
                            , Html.input [ class model.script.id, value model.removeChars, onInput SetRemoveChars ] []
                            , text " from the corpus."
                            ]
                            ++ (if not (String.isEmpty model.removeChars) then
                                    [ br [] []
                                    , small [] [ text "Caution: Sign enumeration within line changes as signs are removed!" ]
                                    ]
                                else
                                    []
                                )
                        )
                    ]
                ]
    in
    div [ class "settings-container" ]
        (
            settingsButton :: if settingsOpen then
                [ settingsBox ]
            else
                []
        )
