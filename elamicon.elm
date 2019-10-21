port module Main exposing (main)

import Array
import Dict
import Dict.Extra
import Grams
import Browser
import Browser.Navigation
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, onInput, targetValue)
import Json.Decode
import List
import Markdown
import Markdown.Config exposing (..)
import Regex
import ScriptDefs exposing (..)
import Scripts exposing (..)
import Specialchars exposing (..)
import Search
import Set
import String
import String exposing (fromInt)
import Url
import WritingDirections exposing (..)

main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }


type alias Pos =
    ( String, Int, Int )


type alias Model =
    { script : Script
    , dir : Maybe Dir
    , fixedBreak : Bool
    , selected : Maybe Pos
    , syllabaryId : Maybe String
    , syllabary : String
    , missingSyllabaryChars : String
    , syllableMap : String
    , syllabizer : String -> String
    , syllabize : Bool
    , normalizer : String -> String
    , normalize : Bool
    , removeChars : String
    , sandbox : String
    , search : String
    , bidirectionalSearch : Bool
    , linesplitSearch : Bool
    , selectedGroups : Set.Set String
    , collapsed : Set.Set String
    , showAllResults : Bool
    , url : Url.Url
    , key : Browser.Navigation.Key
    }

-- Select a script based on the URL fragment
scriptFromUrl : Url.Url -> Maybe Script
scriptFromUrl url =
    case url.fragment of
        Nothing -> Nothing
        Just scriptId ->
            case List.filter (\s -> s.id == scriptId) Scripts.scripts of
                [] -> Nothing
                script :: _ -> Just script

init : () -> Url.Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        script = Maybe.withDefault Scripts.initialScript (scriptFromUrl url)
        initialModel =
            { script = script
            , dir = Nothing
            , fixedBreak = True
            , selected = Nothing
            , normalizer = identity
            , normalize = False
            , removeChars = ""
            , syllabaryId = Nothing
            , syllabary = ""
            , missingSyllabaryChars = ""
            , syllableMap = script.syllableMap
            , syllabizer = Scripts.syllabizer script.syllableMap
            , syllabize = False
            , sandbox = ""
            , search = ""
            , showAllResults = False
            , bidirectionalSearch = True
            , linesplitSearch = False
            , selectedGroups = Set.empty
            , collapsed = Set.fromList [ "info", "gramStats", "syllabary", "playground", "settings", "search" ]
            , url = url
            , key = key
            }
    in
       ( scriptUpdate script initialModel, Cmd.none )


type Msg
    = Select ( String, Int, Int )
    | SetScript Script
    | SetBreaking Bool
    | SetDir (Maybe Dir)
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


scriptUpdate : Script -> Model -> Model
scriptUpdate new model =
    let
        selectedGroups =
            Set.fromList (List.map .short new.groups)
    in
        switchSyllabary new.initialSyllabary
            { model
                | script = new
                , selectedGroups = selectedGroups
                , syllableMap = new.syllableMap
                , search = ""
            }


setSyllabary : String -> Model -> Model
setSyllabary new model =
    let
        ( deduped, missing ) =
            Scripts.dedupe model.script.tokens model.script.indexed new

        newNormalizer =
            Scripts.normalizer (Scripts.normalization model.script.tokens deduped)
    in
    { model
        | syllabary = deduped
        , normalizer = newNormalizer
        , missingSyllabaryChars = missing
    }


switchSyllabary : SyllabaryDef -> Model -> Model
switchSyllabary new model =
    let
        ( deduped, missing ) =
            Scripts.dedupe model.script.tokens model.script.indexed new.syllabary

        newNormalizer =
            Scripts.normalizer (Scripts.normalization model.script.tokens deduped)

        updated =
            setSyllabary new.syllabary model
    in
    { updated
        | syllabaryId = Just new.id
    }

regex pat = Maybe.withDefault Regex.never (Regex.fromString pat)

zeroWidthSpace =
    "\u{200B}"

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetScript script ->
            ( scriptUpdate script model
            , Browser.Navigation.pushUrl model.key ("#" ++ script.id)
            )

        SetSandbox str ->
            ( { model | sandbox = str }, Cmd.none )

        AddChar char ->
            ( { model
                | sandbox = model.sandbox ++ char
                , collapsed = Set.remove "playground" model.collapsed
              }
            , Cmd.none
            )

        Select pos ->
            ( { model | selected = Just pos }, Cmd.none )

        SetBreaking breaking ->
            ( { model | fixedBreak = breaking }, Cmd.none )

        SetNormalize normalize ->
            ( { model | normalize = normalize }, Cmd.none )

        SetRemoveChars chars ->
            ( { model | removeChars = chars }, Cmd.none )

        SetDir dir ->
            ( { model | dir = dir }, Cmd.none )

        ChooseSyllabary id ->
            ( case List.head <| List.filter (.id >> (==) id) model.script.syllabaries of
                Just syl ->
                    switchSyllabary syl model

                Nothing ->
                    model
            , Cmd.none
            )

        SetSyllabary new ->
            ( setSyllabary new model, Cmd.none )

        SetSyllableMap new ->
            ( { model | syllableMap = new, syllabizer = Scripts.syllabizer new }, Cmd.none )

        SetSyllabize syllabize ->
            ( { model | syllabize = syllabize }, Cmd.none )

        SetSearch new ->
            let
                charRange lower upper = List.map Char.fromCode (
                                            List.range (Char.toCode lower)
                                                       (Char.toCode upper))

                -- Set of characters used in regexes
                -- All latin chars are included to allow character classes.
                regexMeta = String.toList "()[]^$|-*.?=!<>\\"
                allowedRegexChars = Set.fromList (regexMeta
                                               ++ ['⏎']
                                               ++ charRange '0' '9'
                                               ++ charRange 'a' 'z'
                                               ++ charRange 'A' 'Z')

                -- When copying strings from the fragments into the search
                -- field, irrelevant whitespace and markers might get copied
                -- as well. To prevent these search-breaking chars, we only
                -- keep indexed chars in the search pattern.
                -- This means that irrelevant chars vanish as they are typed!
                -- Maybe it would be better to just ignore the chars when
                -- searching but leave them alone in the search-field?
                indexedOrRegex c = model.script.indexed c
                                   || Set.member c allowedRegexChars
                cleanSearch = String.filter indexedOrRegex new
            in
            ( { model | search = cleanSearch, showAllResults = False }, Cmd.none )

        ShowAllResults ->
            ( { model | showAllResults = True }, Cmd.none )

        BidirectionalSearch new ->
            ( { model | bidirectionalSearch = new }, Cmd.none )

        LinesplitSearch new ->
            ( { model | linesplitSearch = new }, Cmd.none )

        SelectGroup group include ->
            ( { model
                | selectedGroups =
                    (if include then
                        Set.insert

                     else
                        Set.remove
                    )
                        group
                        model.selectedGroups
              }
            , Cmd.none
            )

        Toggle section ->
            ( { model
                | collapsed =
                    (if Set.member section model.collapsed then
                        Set.remove

                     else
                        Set.insert
                    )
                        section
                        model.collapsed
              }
            , Cmd.none
            )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Browser.Navigation.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Browser.Navigation.load href )

        UrlChanged url ->
            let
                new = Maybe.withDefault Scripts.initialScript (scriptFromUrl url)
            in
                ( scriptUpdate new { model | url = url } , Cmd.none )


dirStr dir =
    case dir of
        RTL ->
            "RTL"

        _ ->
            "LTR"


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


dirDecoder : Json.Decode.Decoder (Maybe Dir)
dirDecoder =
    Html.Events.targetValue
        |> Json.Decode.andThen
            (\valStr ->
                case valStr of
                    "Original" ->
                        Json.Decode.succeed Nothing

                    "LTR" ->
                        Json.Decode.succeed (Just LTR)

                    "RTL" ->
                        Json.Decode.succeed (Just RTL)

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


type SearchPattern
    = None
    | Invalid
    | Pattern Regex.Regex
    | Fuzzy Int String



-- Thirty-two numerals ought to be enough for everybody (Marcus Licinius Crassus)


romanNumerals =
    Array.fromList
        [ ""
        , "Ⅰ"
        , "Ⅱ"
        , "Ⅲ"
        , "Ⅳ"
        , "Ⅴ"
        , "Ⅵ"
        , "Ⅶ"
        , "Ⅷ"
        , "Ⅸ"
        , "Ⅹ"
        , "Ⅺ"
        , "Ⅻ"
        , "Ⅻ"
        , "ⅩⅢ"
        , "ⅩⅣ"
        , "ⅩⅤ"
        , "ⅩⅥ"
        , "ⅩⅦ"
        , "ⅩⅧ"
        , "ⅩⅨ"
        , "ⅩⅩ"
        , "ⅩⅪ"
        , "ⅩⅫ"
        , "ⅩⅫ"
        , "ⅩⅩⅢ"
        , "ⅩⅩⅣ"
        , "ⅩⅩⅤ"
        , "ⅩⅩⅥ"
        , "ⅩⅩⅦ"
        , "ⅩⅩⅧ"
        , "ⅩⅩⅨ"
        , "ⅩⅩⅩ"
        , "ⅩⅩⅪ"
        , "ⅩⅩⅫ"
        , "ⅩⅩⅩⅢ"
        , "ⅩⅩⅩⅣ"
        , "ⅩⅩⅩⅤ"
        , "ⅩⅩⅩⅥ"
        , "ⅩⅩⅩⅦ"
        , "ⅩⅩⅩⅧ"
        , "ⅩⅩⅩⅨ"
        , "ⅩⅬ"
        , "ⅩⅬⅠ"
        ]


roman num =
    Maybe.withDefault "" <| Array.get num romanNumerals


view : Model -> Browser.Document Msg
view model =
    let
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

        scriptClass =
            class model.script.id

        selectedFragments =
            List.filter (\f -> Set.member f.group model.selectedGroups) model.script.fragments

        -- Normalize letters if this is enabled
        normalize =
            if model.normalize then
                model.normalizer

            else
                identity

        -- Build filter that removes undesired chars
        removeCharSet =
            Set.fromList <| String.toList model.removeChars

        keepChar c =
            Set.member c removeCharSet |> not

        charFilter =
            String.filter keepChar

        -- When the search splits along lines, make the newlines count
        linesplitInsertion =
            if model.linesplitSearch
                then String.join "⏎\n" << String.split "\n"
                else identity

        -- When splitting by line, the linebreak is made to count as char
        indexed =
            if model.linesplitSearch
            then \c -> c == '⏎' || model.script.indexed c
            else model.script.indexed

        -- Process fragment text for display
        cleanse =
            String.trim >> linesplitInsertion >> normalize >> charFilter

        cleanedFragments =
            List.map (\f -> { f | text = cleanse f.text }) selectedFragments

        decorate decorationAccessor title =
            let
                ( decorLeft, decorRight ) =
                    decorationAccessor model.script.decorations
            in
            decorLeft ++ " " ++ title ++ " " ++ decorRight

        collapsibleTitle section title decorationAccessor =
            let
                collapsed =
                    Set.member section model.collapsed

                attrs =
                    [ classList
                        [ ( "collapsible", True )
                        , ( "collapsed", collapsed )
                        ]
                    , onClick (Toggle section)
                    ]

                ( decorUp, decorDown ) =
                    model.script.decorations.collapse

                toggle =
                    if collapsed then
                        decorUp

                    else
                        decorDown
            in
            [ h2 attrs
                [ text (decorate decorationAccessor title)
                , span [ class "toggle" ] [ text toggle ]
                ]
            ]

        -- build is called lazily when the section is expanded
        ifExpanded : String -> (() -> List a) -> List a
        ifExpanded section build =
            if Set.member section model.collapsed then
                []

            else
                build ()

        syllabary =
            collapsibleTitle "syllabary" "Character Picker" .signs
                ++ ifExpanded "syllabary" syllabaryView

        syllabaryView =
            \_ ->
                [ ol [ dirAttr LTR, classList [ ( "syllabary", True ) ] ]
                    (List.map syllabaryEntry (Scripts.syllabaryList (charFilter model.syllabary))
                        ++ List.map specialEntry specialchars
                    )
                ]

        syllabaryEntry : (Char, List Char) -> Html Msg
        syllabaryEntry ( principal, ext ) =
            let
                shownExt =
                    if model.normalize then
                        []

                    else
                        List.map String.fromChar ext

                maybeSyls = Dict.get
                    principal
                    model.script.syllables

                syls = Maybe.withDefault [] maybeSyls

                letterEntry entryClass char =
                    div [ classList [ ( model.script.id, True ), ( entryClass, True ) ], onClick (AddChar char) ] [ text char ]

                syllableEntry syl =
                    div [ class "syl" ] [ text syl ]
            in
            li [ class "letter" ]
                ([ letterEntry "main" (String.fromChar principal) ]
                    ++ (if shownExt /= [] || List.length syls > 0 then
                            [ div [ class "menu" ] (List.map (letterEntry "ext") shownExt ++ List.map syllableEntry syls) ]

                        else
                            []
                       )
                    ++ List.map (letterEntry "ext") shownExt
                    ++ [ div [ class "clear" ] [] ]
                )

        specialEntry { displayChar, char, description } =
            li [ class "letter" ]
                [ div [ classList [ ( model.script.id, True ), ( "main", True ) ], onClick (AddChar (String.fromChar char)), title description ] [ text (guessMarkDir LTR displayChar) ] ]

        gramStats strings =
            let
                onlyIndexed =
                    charFilter >> model.normalizer >> String.filter indexed

                tallyGrams =
                    List.filter (List.isEmpty >> not) <| List.map Grams.tally <| Grams.read 7 <| List.map onlyIndexed strings

                tallyEntry gram ts =
                    let
                        boringClass =
                            if gram.count < 2 then
                                [ class "boring" ]

                            else
                                []
                    in
                    tr boringClass
                        -- Use a span so that when the text is copied it
                        -- doesn't cause a new line like a div would.
                        [ td [ class "count" ] [ text <| String.fromInt gram.count ]
                        , td [] [ text gram.seq ]
                        ]
                        :: ts

                ntally n tallyGram =
                    li [] [ table [ class "tallyGram" ] (List.foldr tallyEntry [] tallyGram) ]
            in
            if List.isEmpty tallyGrams then
                div [] []

            else
                div []
                    [ h3 [] [ text "N-gram statistics" ]
                    , ul [ class "tallyGrams" ] (List.indexedMap ntally tallyGrams)
                    ]

        markdownOptions =
            { defaultOptions
                | rawHtml =
                    Sanitize
                        { defaultSanitizeOptions
                            | allowedHtmlElements = defaultSanitizeOptions.allowedHtmlElements ++ [ "sub", "sup" ]
                        }
            }

        info =
            collapsibleTitle "info" "Intro & Sources" .info
                ++ ifExpanded "info" (\_ -> Markdown.toHtml (Just markdownOptions) (model.script.description ++ model.script.sources))

        playground =
            collapsibleTitle "playground" "Sandbox" .sandbox
                ++ ifExpanded "playground"
                    (\_ ->
                        [ textarea
                            [ class model.script.id
                            , dirAttr LTR
                            , on "input" (Json.Decode.map SetSandbox Html.Events.targetValue)
                            , onInput SetSandbox
                            , value (guessMarkDir LTR model.sandbox)
                            ]
                            []
                        , gramStats [ model.sandbox ]
                        ]
                    )

        settings =
            let
                dirOptAttrs val dir =
                    [ value val, selected (dir == model.dir) ]

                breakOptAttrs val break =
                    [ value val, selected (break == model.fixedBreak) ]

                boolOptAttrs val sel =
                    [ value val, selected sel ]

                syllabaryButton syl =
                    let
                        classes =
                            classList [ ( "active", Just syl.id == model.syllabaryId ) ]

                        handler =
                            onClick (ChooseSyllabary syl.id)

                        attrs =
                            [ type_ "button", handler, classes ]
                    in
                    li [] [ button attrs [ text syl.name ] ]

                syllabarySelection =
                    ol [ class "syllabarySelection" ] (List.map syllabaryButton model.script.syllabaries)

                groupSelectionEntry group =
                    div []
                        [ label []
                            ([ input [ type_ "checkbox", checked (Set.member group.short model.selectedGroups), Html.Events.onCheck (SelectGroup group.short) ] []
                             , text group.name
                             ]
                                ++ (if group.recorded then
                                        []

                                    else
                                        [ span [ class "recordWarn", title "Undocumented finds" ] [ text "⚠" ] ]
                                   )
                            )
                        ]

                groupSelection =
                    List.map groupSelectionEntry model.script.groups
            in
            collapsibleTitle "settings" "Settings" .settings
                ++ ifExpanded "settings"
                    (\_ ->
                        [ div []
                            [ label []
                                [ text "Writing direction"
                                , Html.select [ on "change" (Json.Decode.map SetDir dirDecoder) ]
                                    [ option (dirOptAttrs "Original" Nothing) [ text "original ⇔" ]
                                    , option (dirOptAttrs "LTR" (Just LTR)) [ text "everything ⇒ from left ⇒ to right" ]
                                    , option (dirOptAttrs "RTL" (Just RTL)) [ text "everything ⇐ to left ⇐ from right" ]
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
                                , Html.select [ on "change" (Json.Decode.map SetSyllabize boolDecoder) ]
                                    [ option (boolOptAttrs "false" (not model.syllabize)) [ text "keep original sign" ]
                                    , option (boolOptAttrs "true" model.syllabize) [ text "replace with sound value" ]
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
                                            [ small [] [ text "Caution: Sign enumeration within line changes as signs are removed!" ] ]

                                        else
                                            []
                                       )
                                )
                            ]
                        , div []
                            ([ h4 [] [ text "Dynamic Syllabary" ]
                             , syllabarySelection
                             , Html.textarea [ class model.script.id, value model.syllabary, onInput SetSyllabary ] []
                             ]
                                ++ (if not (String.isEmpty model.missingSyllabaryChars) then
                                        [ div [] [ text "The following signs are not listed in the syllabary: ", text model.missingSyllabaryChars ] ]

                                    else
                                        []
                                   )
                            )
                        , div []
                            [ label []
                                [ h4 [] [ text "Assumed sound values" ]
                                , Html.textarea [ scriptClass, value model.syllableMap, onInput SetSyllableMap ] []
                                ]
                            ]
                        , div [ class "groups" ]
                            (h4 [] [ text "Groups" ] :: groupSelection)
                        ]
                    )

        -- We want the regex to match all letters of a group, so both the pattern
        -- and the fragments are normalized before matching
        searchPattern =
            let
                normalized =
                    model.normalizer model.search

                fuzziness =
                    String.uncons normalized
            in
            case fuzziness of
                Nothing ->
                    None

                Just ( head, tail ) ->
                    case head |> String.fromChar |> String.toInt of
                        Just fuzz ->
                            Fuzzy fuzz tail

                        Nothing ->
                            case Regex.fromString normalized of
                                Just pattern ->
                                    Pattern pattern

                                Nothing ->
                                    Invalid

        search =
            let
                applyBidirectional =
                    if model.bidirectionalSearch then
                        Search.bidirectional

                    else
                        identity
            in
            case searchPattern of
                Pattern pat ->
                    Just <| model.normalizer >> applyBidirectional (Search.regex pat)

                Fuzzy fuzz query ->
                    Just <| model.normalizer >> applyBidirectional (Search.fuzzy fuzz query)

                _ ->
                    Nothing

        searchView =
            let
                maxResults =
                    if model.showAllResults then
                        0

                    else
                        100

                contextLen =
                    3

                results =
                    Maybe.map (Search.extract indexed maxResults contextLen cleanedFragments) search

                buildResultLine result =
                    let
                        -- half-width space
                        hwspace =
                            "\u{2009}"

                        -- half-width non-breaking space
                        hwnbspace =
                            "\u{202F}"

                        ( startLineNr, startCharNr ) =
                            result.start

                        ( endLineNr, endCharNr ) =
                            result.end

                        matchTitle =
                            String.concat <|
                                [ roman startLineNr
                                , hwnbspace
                                , fromInt startCharNr
                                ]
                                    ++ (if startLineNr /= endLineNr || startCharNr /= endCharNr then
                                            (if startLineNr /= endLineNr then
                                                [ hwnbspace, "–", hwspace, roman endLineNr, hwnbspace ]

                                             else
                                                [ "–" ]
                                            )
                                                ++ [ fromInt endCharNr ]

                                        else
                                            []
                                       )

                        fragment =
                            result.fragment

                        index =
                            Tuple.first result.location

                        ref =
                            href <| String.concat [ "#", fragment.id, fromInt index ]

                        -- Remove spaces and ensure the guessmarks are oriented left
                        removeWhitespace = String.words >> String.concat
                        fixGuessmarkDir = guessMarkDir LTR
                        typeset =
                            removeWhitespace >> fixGuessmarkDir
                    in
                    li [ class "result" ]
                        [ div [ class "id" ]
                            [ Html.sup [ class "group" ] [ text fragment.group ]
                            , text (fragment.id ++ " ")
                            , span [ class "pos" ] [ text matchTitle ]
                            ]
                        , div [ class "match" ]
                            [ span [ class "before" ] [ text (typeset result.before) ]
                            , a [ class "highlight", ref ] [ text (typeset result.match) ]
                            , span [ class "after" ] [ text (typeset result.after) ]
                            ]
                        ]

                resultLines : List (Html Msg)
                resultLines =
                    case results of
                        Just res ->
                            List.map buildResultLine res.items

                        Nothing ->
                            []

                statsBase =
                    \_ ->
                        case results of
                            Just res ->
                                res.raw

                            Nothing ->
                                List.map .text selectedFragments

                stats =
                    \_ -> [ gramStats (statsBase ()) ]

                searchExamplesList examples =
                    let
                        def ( t, e ) =
                            [ dt [] [ text t ], dd [] [ text e ] ]
                    in
                    dl [] (List.concatMap def examples)
            in
            collapsibleTitle "gramStats" "Frequency Analysis" .grams
                ++ ifExpanded "gramStats" stats
                ++ collapsibleTitle "search" "Search" .search
                ++ ifExpanded "search"
                    (\_ ->
                        [ label [] (
                            [ text "Search "
                            , div [ class "searchInput" ]
                                ([ Html.input [ scriptClass, dirAttr LTR, value model.search, onInput SetSearch ] []
                                 ]
                                    ++ (if searchPattern == Invalid then
                                            [ div [ class "invalidPattern" ] [ text "Invalid pattern" ] ]

                                        else
                                            []
                                       )
                                )
                            , label []
                                [ input [ type_ "checkbox", checked model.bidirectionalSearch, Html.Events.onCheck BidirectionalSearch ] []
                                , text "also search in reverse direction"
                                ]
                            , label []
                                [ input [ type_ "checkbox", checked model.linesplitSearch, Html.Events.onCheck LinesplitSearch ] []
                                , text "split search at new lines"
                                ]
                            ]
                            ++ (if model.linesplitSearch then
                                    [ div [] [ text "Use the character [⏎] to search across lines. Just copy the ⏎ character to the search-input to use it. For example, write ", span [ class "searchCodeExample" ] [ text "line⏎?break" ], text " to allow (but not require) the word linebreak to be split across lines."] ]

                                else
                                    []
                               )
                        )]
                            ++ (case results of
                                    Just res ->
                                        if List.length res.items == 0 then
                                            [ div [ class "noresult" ] [ text "No results" ] ]

                                        else
                                            [ ol [ class "result" ] resultLines ]
                                                ++ (if res.more then
                                                        [ text (String.concat [ "Only showing ", fromInt maxResults, " of ", fromInt (List.length res.raw), " results. " ])
                                                        , button [ type_ "button", onClick ShowAllResults ] [ text "Show all!" ]
                                                        ]

                                                    else
                                                        []
                                                   )

                                    Nothing ->
                                        [ div [ class "searchExamples" ]
                                            [ h3 [] [ text "Examples of search patterns" ]
                                            , searchExamplesList model.script.searchExamples
                                            ]
                                        ]
                               )
                    )

        fragmentView fragment =
            let
                syllabize =
                    if model.syllabize then
                        model.syllabizer

                    else
                        identity

                -- Insert a zero-width space after the "" separator so that long
                -- lines can be broken by the browser
                seperatorMatch =
                    Maybe.withDefault Regex.never (
                        Regex.fromString ("[" ++ model.script.seperatorChars ++ "]"))

                breakAfterSeparator =
                    Regex.replace seperatorMatch (\l -> l.match ++ zeroWidthSpace)

                textMod = String.trim
                       >> breakAfterSeparator
                       >> guessMarkDir (effectiveDir fragment.dir)

                -- Find matches in the fragment
                matches =
                    case search of
                        Just s ->
                            s (String.filter indexed fragment.text)

                        Nothing ->
                            []

                guessmarkClass char =
                    if Set.member char guessMarkers then
                        [ class "guessmark" ]

                    else
                        []

                -- Depending on the tablet's writing direction and the chosen
                -- normalization of writing direction, we set dir = LTR or RTL.
                -- For fragments written top-down we use the "tdr" class and
                -- set writing-mode in CSS.
                fragmentAttrs =
                    [ classList
                        [ ( "fragment", True )
                        , ( "tdr", effectiveDir fragment.dir == TDR )
                        ]
                    , dirAttr fragment.dir
                    ]

                -- Fold helper building a list element from a text line
                -- The tricky bit here is to keep indexed character position so
                -- we can track highlighted searches which may span across
                -- lines.
                line chars ( prevLines, lineIdx ) =
                    let
                        lineNr =
                            List.length prevLines

                        charPos char ( tailElems, idx ) =
                            let
                                within ( index, length ) =
                                    (idx >= index) && (idx < index + length)

                                highlightClass =
                                    if List.any within matches then
                                        [ class "highlight" ]

                                    else
                                        []

                                titleAttr =
                                    [ title (String.concat [ fromInt (lineNr + 1), ".", fromInt (idx - lineIdx + 1) ]) ]

                                idAttr =
                                    [ id <| String.concat [ fragment.id, fromInt idx ] ]

                                charStr = String.fromChar char
                            in
                            if indexed char then
                                ( a (highlightClass ++ titleAttr ++ idAttr) [ text (syllabize charStr) ] :: tailElems, idx + 1 )

                            else
                                ( span (guessmarkClass char) [ text charStr ] :: tailElems, idx )

                        ( elems, endIdx ) =
                            String.toList chars |> List.foldl charPos ( [], lineIdx )

                        elemLine =
                            li [ class "line", lineDirAttr lineNr fragment.dir ] (List.reverse elems)
                    in
                    ( elemLine :: prevLines, endIdx )

                -- Build line entries from text
                lines =
                    List.reverse (Tuple.first (List.foldl line ( [], 0 ) (String.lines (textMod fragment.text))))

                thumb =
                    case fragment.plate of
                        Nothing ->
                            []

                        Just url ->
                            [ a [ href url, target "_blank", class "img" ] [ img [ src (url ++ ".thumb") ] [] ] ]
            in
            div [ classList [ ( "plate", True ), ( "fixedBreak", model.fixedBreak ), ( model.script.id, True ) ], dirAttr fragment.dir ]
                [ h3 []
                    ([ span [ dir "LTR" ]
                        -- labels are always written LTR
                        [ sup [ class "group" ] [ text fragment.group ]
                        , text fragment.id
                        ]
                     ]
                        ++ thumb
                    )
                , ol fragmentAttrs lines
                ]

        contact =
            div [ class "footer" ]
                [ h2 [] [ text "Contact the research team" ]
                , text "For detailed information about "
                , text model.script.title
                , text ", and possibilities for collaboration please contact "
                , strong [] [ text "michael.maeder[ätt]isw.unibe.ch" ]
                , text ". "
                , text "We can help you with tips on how to contribute to the decipherment and tell you what we've discovered so far."
                , br [] []
                , br [] []
                , text " Thank you for your interest and have fun puzzling over the inscriptions. Your "
                , text model.script.title
                , text " team, Institut für Sprachwissenschaft, Universität Bern."
                , br [] []
                , a [ href "https://center-for-decipherment.ch/" ]
                    [ text "center-for-decipherment.ch" ]
                ]

        footer =
            div [ class "footer" ]
                [ text "This site was produced with "
                , a [ href "https://fontforge.github.io/" ]
                    [ text "FontForge" ]
                , text ", "
                , a [ href "http://elm-lang.org/" ]
                    [ text "Elm" ]
                , text " and "
                , a [ href "https://unicode.org" ] [ text "Unicode ♥" ]
                , text ".  "
                , br [] []
                , a [ href ("fonts/" ++ model.script.font ++ "-Fonts.zip") ]
                    [ text ("Download the " ++ model.script.font ++ " fonts.") ]
                , text " "
                , br [] []
                , a [ href "https://github.com/elamicon/elamicon/" ]
                    [ text "The project on Github." ]
                ]

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
    in
        { title = model.script.headline
        , body =
            [ div [ class model.script.id ] (
                [ selectionDropdown
                , h1 [ class "secondary" ] [ text (decorate .headline model.script.headline) ]
                , h1 [] [ text (decorate .title model.script.title) ]
                ]
                ++ info
                ++ syllabary
                ++ playground
                ++ settings
                ++ searchView
                ++ [ h2 [] [ text (decorate .inscriptions "Inscriptions") ] ]
                ++ [ div [ dirAttr LTR ] (List.map fragmentView cleanedFragments) ]
                ++ [ contact, small [] [ footer ] ]
            )]
        }
