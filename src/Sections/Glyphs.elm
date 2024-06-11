module Sections.Glyphs exposing (html)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import WritingDirections exposing (..)
import State
import Set
import Dict
import Specialchars
import Syllabary

html model =
    let
        -- Build filter that removes undesired chars
        removeCharSet =
            Set.fromList <| String.toList model.removeChars

        effectiveDir original =
            case model.dir of
                Nothing ->
                    original

                Just dir ->
                    dir

        lineDirAttr nr original =
            Html.Attributes.dir
                (dirStr
                    (case effectiveDir original of
                        BoustroR ->
                            if modBy 2 nr == 0 then
                                RTL

                            else
                                LTR

                        _ ->
                            effectiveDir original
                    )
                )

        dirAttr original =
            lineDirAttr 0 original

        keepChar c =
            Set.member c removeCharSet |> not

        names = Dict.fromList <| List.map (\t -> (String.fromChar t.token, t.name)) model.script.tokens

        syllabaryEntry t =
            let
                shownExt =
                    if model.normalize then
                        []

                    else
                        List.map String.fromChar t.tokens

                maybeSyl = Dict.get
                    t.representative
                    model.script.syllables

                syls = case maybeSyl of
                    Just syl ->
                        [ syl ]
                    Nothing ->
                        []

                -- Some entries in the syllabary have long names.
                -- Use linguist's convention of wrapping the names in brackets.
                signWrap s = if String.length s > 1 then "〈" ++ s ++ "〉" else s

                letterEntry entryClass sign add =
                    div [ classList [ ( model.script.id, True ), ( entryClass, True ) ]
                        , onClick (State.AddChar add)
                        , title (Maybe.withDefault "" <| Dict.get add names)
                        ] [ text (signWrap sign) ]

                syllableEntry syl =
                    div [ class "syl" ] [ text syl ]
            in
            li [ class "letter" ]
                (letterEntry "main" t.name (String.fromChar t.representative)
                    :: (if shownExt /= [] || List.length syls > 0 then
                            [ div [ class "menu" ] (List.map (\ext -> letterEntry "ext" ext ext) shownExt ++ List.map syllableEntry syls) ]

                        else
                            []
                       )
                    ++ List.map (\ext -> letterEntry "ext" ext ext) shownExt
                    ++ [ div [ class "clear" ] [] ]
                )

        specialEntry { displayChar, char, description } =
            li [ class "letter" ]
                [ div [ classList [ ( model.script.id, True ), ( "main", True ) ], onClick (State.AddChar (String.fromChar char)), title description ] [ text (Specialchars.guessMarkDir LTR displayChar) ] ]

    in
        [ ol [ dirAttr LTR, classList [ ( "syllabary", True ) ] ]
            (List.map syllabaryEntry (Syllabary.filter keepChar model.syllabary)
                ++ List.map specialEntry Specialchars.specialchars
            )
        ]
